# Push notifications for appointments

The app saves the user’s FCM token in Firestore at `user_profiles/{userId}` with field `fcmToken`. Use this token in Cloud Functions to send:

1. **Booking confirmation** – when an appointment is created  
2. **Appointment reminder** – at (or shortly before) the appointment time  

---

## 1. Booking confirmation (on create)

When a document is created in `appointments`, send a push to the user who booked.

**Firestore trigger:** `onCreate` on `appointments`

**Steps:**

1. Read `userId` from the new appointment document.  
2. Load `user_profiles/{userId}` and get `fcmToken`.  
3. Call Firebase Admin Messaging to send a notification to that token.

**Example (Node.js Cloud Functions v2):**

```js
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { getMessaging } = require("firebase-admin/messaging");
const { getFirestore } = require("firebase-admin/firestore");

exports.onAppointmentCreated = onDocumentCreated(
  { document: "appointments/{appointmentId}" },
  async (event) => {
    const snap = event.data;
    if (!snap) return;
    const data = snap.data();
    const userId = data.userId;
    const doctorName = data.doctorName || "Consultant";
    const appointmentDate = data.appointmentDate?.toDate?.();
    const appointmentTime = data.appointmentTime || "";

    const userDoc = await getFirestore().collection("user_profiles").doc(userId).get();
    const fcmToken = userDoc?.data()?.fcmToken;
    if (!fcmToken) return;

    await getMessaging().send({
      token: fcmToken,
      notification: {
        title: "Appointment confirmed",
        body: `Your appointment with ${doctorName} on ${formatDate(appointmentDate)} at ${appointmentTime} is confirmed.`,
      },
      data: { type: "appointment_booked", appointmentId: event.params.appointmentId },
    });
  }
);

function formatDate(d) {
  if (!d) return "";
  return d.toISOString().slice(0, 10);
}
```

---

## 2. Appointment reminder (at appointment time)

Send a push when it’s time for the appointment (or X minutes before).

**Option A – Scheduled function (e.g. every 15 minutes)**

1. Run a scheduled function (e.g. every 15 min).  
2. Query `appointments` where:
   - `appointmentDate` is today (or the date range you care about), and  
   - `appointmentTime` is in the “reminder window” (e.g. now to now+15 min).  
   You may need to store a combined `appointmentDateTime` or compute it from `appointmentDate` + `appointmentTime` in the function.  
3. For each matching appointment, get `userId` → `user_profiles/{userId}.fcmToken` and send a reminder notification.

**Option B – Cloud Scheduler + Firestore query**

- Use Cloud Scheduler to trigger a function every 5–15 minutes.  
- In that function, compute “current time” and “reminder window” (e.g. next 15 min), then query appointments whose date+time falls in that window (you may need a composite field or a separate collection for scheduling).  
- Send one notification per user (dedupe by appointment id if you run frequently).

**Example reminder payload:**

```js
{
  token: fcmToken,
  notification: {
    title: "Appointment reminder",
    body: `Your appointment with ${doctorName} is at ${appointmentTime}.`,
  },
  data: { type: "appointment_reminder", appointmentId: "..." },
}
```

---

## Flutter side (already in the app)

- **NotificationService** initializes FCM and local notifications.  
- On startup, **refreshTokenForCurrentUser()** saves the FCM token to `user_profiles/{userId}` (using `LocalStorageService.getUserId()`).  
- After phone auth success, **saveTokenForUser(userId)** is called so the new user’s token is stored.  
- Foreground messages are shown via **flutter_local_notifications** in **setupForegroundHandler()**.  

Ensure your Firebase project has **Cloud Messaging** enabled and that the app is configured for FCM (e.g. `google-services.json` / `GoogleService-Info.plist`). For background/terminated handling, the default FCM handlers are used; optional: handle `FirebaseMessaging.onMessageOpenedApp` to navigate to “My Appointments” when the user taps the notification.
