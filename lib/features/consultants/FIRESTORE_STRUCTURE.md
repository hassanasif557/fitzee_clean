# Firestore structure for Consultants & Appointments

## Collections

### `doctors`
Each document = one doctor.

| Field | Type | Description |
|-------|------|-------------|
| name | string | Doctor name |
| speciality | string | e.g. "Cardiology", "General" (used for filter) |
| rating | number | 0–5 |
| reviews | number | Review count |
| pricePerHour | number | Price per hour |
| imageUrl | string | Avatar URL |
| yearsExperience | number | |
| patients | number | |
| bio | string | |
| aiEnabled | boolean | |
| **availableTimes** | array of string | **Legacy.** e.g. `["09:00", "09:30"]` – used when `availability` is empty |
| **availability** | array of map | **Preferred.** Per-day slots. See below. |

**availability** item:
```json
{
  "dayOfWeek": 1,
  "slots": ["09:00", "09:30", "10:00", "10:30"]
}
```
- `dayOfWeek`: 1 = Monday, 7 = Sunday (same as `DateTime.weekday`).
- `slots`: time strings for that day. Users can only book these slots on dates that fall on this weekday.

**Composite index (optional, for filter):**  
Collection: `doctors`, fields: `speciality` (Ascending).  
Only needed if you query by `speciality`; Firestore may prompt you to create it when you first run the query.

---

### `appointments`
Each document = one booked appointment.

| Field | Type | Description |
|-------|------|-------------|
| doctorId | string | Document id from `doctors` |
| doctorName | string | Denormalized for display |
| userId | string | User who booked |
| appointmentDate | **Timestamp** | **Start of day (midnight)** for the appointment date, so we can query by date |
| appointmentTime | string | Slot time, e.g. "09:00" |
| price | number | |
| status | string | e.g. "confirmed", "cancelled" |
| paymentStatus | string | e.g. "paid", "unpaid" |
| createdAt | Timestamp | When the booking was made |

**Required composite index:**  
Collection: `appointments`  
Fields: `doctorId` (Ascending), `appointmentDate` (Ascending)  

Create in Firebase Console → Firestore → Indexes, or add to `firestore.indexes.json`:
```json
{
  "indexes": [
    {
      "collectionGroup": "appointments",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "doctorId", "order": "ASCENDING" },
        { "fieldPath": "appointmentDate", "order": "ASCENDING" }
      ]
    }
  ],
  "fieldOverrides": []
}
```

---

## Queries used by the app

1. **Doctors (optional filter):**  
   `doctors` where `speciality` == value (or no filter for “All”).
2. **User’s appointments:**  
   `appointments` where `userId` == uid, orderBy `appointmentDate` ascending.
3. **Booked slots for a doctor on a date:**  
   `appointments` where `doctorId` == id and `appointmentDate` in [startOfDay, endOfDay).  
   Then read `appointmentTime` from each doc to get booked slots; available = doctor’s slots for that weekday minus booked.

---

## Push notifications (FCM)

- **On booking:** When an `appointments` document is created, send a push to the user (e.g. via Cloud Function triggered by `onCreate`). You need the user’s FCM token (e.g. stored in `users/{userId}` or a subcollection).
- **Reminder:** At appointment time (or X minutes before), send a push. Options:  
  - Scheduled Cloud Function (e.g. every 15 min) that queries `appointments` for `appointmentDate` + `appointmentTime` in the next window and sends to each user’s token.  
  - Or store reminder job server-side when the appointment is created.
