import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'package:fitzee_new/core/routes/app_router.dart' as routes;
import 'local_storage_service.dart';

/// Handles FCM token, push notifications, and scheduled daily reminders (breakfast, lunch, dinner, exercise, appointments, daily log).
/// Taps open the app to the relevant screen via [consumePendingRoute].
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Optional: handle background message
}

/// Reminder type ids (used as notification ids). Must be unique.
class _ReminderId {
  static const int breakfast = 1001;
  static const int lunch = 1002;
  static const int dinner = 1003;
  static const int exercise = 1004;
  static const int appointments = 1005;
  static const int dailyLog = 1006;
}

class NotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();
  static const String _userProfilesCollection = 'user_profiles';

  static bool _initialized = false;
  static String? _pendingRoute;

  /// Route to open when user taps a notification. Consume once (returns and clears).
  static String? consumePendingRoute() {
    final r = _pendingRoute;
    _pendingRoute = null;
    return r;
  }

  /// Call once after Firebase.initializeApp().
  static Future<void> init() async {
    if (_initialized) return;
    await _requestPermission();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    tz_data.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(requestAlertPermission: false);
    await _local.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    if (Platform.isAndroid) {
      final appointmentsChannel = AndroidNotificationChannel(
        'appointments',
        'Appointments',
        description: 'Booking confirmations and appointment reminders',
        importance: Importance.high,
      );
      await _local
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(appointmentsChannel);

      final remindersChannel = AndroidNotificationChannel(
        'reminders',
        'Daily reminders',
        description: 'Breakfast, lunch, dinner, exercise, and daily log reminders',
        importance: Importance.high,
      );
      await _local
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(remindersChannel);
    }

    _handleInitialFcmMessage();
    FirebaseMessaging.onMessageOpenedApp.listen(_setPendingRouteFromMessage);

    _initialized = true;
  }

  static void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;
    try {
      final map = jsonDecode(payload) as Map<String, dynamic>?;
      final route = map?['route'] as String?;
      if (route != null && route.isNotEmpty) _pendingRoute = route;
    } catch (_) {
      if (payload.startsWith('/')) _pendingRoute = payload;
    }
  }

  static void _setPendingRouteFromMessage(RemoteMessage message) {
    final route = message.data['route'] as String?;
    if (route != null && route.isNotEmpty) _pendingRoute = route;
  }

  static Future<void> _handleInitialFcmMessage() async {
    final message = await _fcm.getInitialMessage();
    if (message != null) _setPendingRouteFromMessage(message);
  }

  static Future<bool> _requestPermission() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// Get current FCM token (for debugging or Cloud Functions).
  static Future<String?> getToken() async {
    return _fcm.getToken();
  }

  /// Save FCM token to Firestore so Cloud Functions can send push to this user.
  static Future<void> saveTokenForUser(String? userId) async {
    if (userId == null || userId.isEmpty) return;
    final token = await _fcm.getToken();
    if (token == null) return;
    try {
      await FirebaseFirestore.instance
          .collection(_userProfilesCollection)
          .doc(userId)
          .set({'fcmToken': token, 'fcmTokenUpdatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
    } catch (_) {}
    _fcm.onTokenRefresh.listen((newToken) async {
      try {
        await FirebaseFirestore.instance
            .collection(_userProfilesCollection)
            .doc(userId)
            .set({'fcmToken': newToken, 'fcmTokenUpdatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
      } catch (_) {}
    });
  }

  /// Call once after init() to refresh token for current user from LocalStorage.
  static Future<void> refreshTokenForCurrentUser() async {
    final userId = await LocalStorageService.getUserId();
    await saveTokenForUser(userId);
  }

  /// Remove FCM token for user on sign out.
  static Future<void> clearTokenForUserOnSignOut(String? userId) async {
    if (userId == null || userId.isEmpty) return;
    try {
      await FirebaseFirestore.instance
          .collection(_userProfilesCollection)
          .doc(userId)
          .update({'fcmToken': FieldValue.delete(), 'fcmTokenUpdatedAt': FieldValue.delete()});
    } catch (_) {}
  }

  /// Setup foreground message handler (show local notification when app is open).
  static void setupForegroundHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final title = message.notification?.title ?? 'Reminder';
      final body = message.notification?.body ?? '';
      final route = message.data['route'] as String?;
      final payload = route != null ? jsonEncode({'route': route}) : null;
      _showLocalNotification(title: title, body: body, payload: payload);
    });
  }

  static Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const android = AndroidNotificationDetails(
      'appointments',
      'Appointments',
      channelDescription: 'Booking confirmations and appointment reminders',
      importance: Importance.high,
      priority: Priority.high,
    );
    const ios = DarwinNotificationDetails();
    await _local.show(
      0,
      title,
      body,
      const NotificationDetails(android: android, iOS: ios),
      payload: payload,
    );
  }

  /// Schedule daily reminder notifications (breakfast, lunch, dinner, exercise, appointments, daily log).
  /// Call after init when user is in app (e.g. after dashboard loads). Uses device local timezone.
  static Future<void> scheduleDailyReminders() async {
    if (!_initialized) return;

    const reminderDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'reminders',
        'Daily reminders',
        channelDescription: 'Breakfast, lunch, dinner, exercise, and daily log reminders',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    final now = tz.TZDateTime.now(tz.local);

    Future<void> schedule(int id, int hour, int minute, String title, String body, String route) async {
      var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
      if (scheduled.isBefore(now)) scheduled = scheduled.add(const Duration(days: 1));
      final payload = jsonEncode({'route': route});
      await _local.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        reminderDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: payload,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.wallClockTime,
      );
    }

    try {
      await schedule(_ReminderId.breakfast, 8, 0, 'Breakfast time', 'Start your day with a healthy meal.', routes.AppRouter.dashboard);
      await schedule(_ReminderId.lunch, 13, 0, 'Lunch time', 'Time for a balanced lunch.', routes.AppRouter.dashboard);
      await schedule(_ReminderId.dinner, 19, 0, 'Dinner time', 'Wind down with a healthy dinner.', routes.AppRouter.dashboard);
      await schedule(_ReminderId.exercise, 9, 0, 'Exercise time', 'Get moving! Time for your workout.', routes.AppRouter.dashboard);
      await schedule(_ReminderId.appointments, 9, 30, 'Appointments', 'Check your appointments for today.', routes.AppRouter.myAppointments);
      await schedule(_ReminderId.dailyLog, 20, 0, 'Log your day', 'Record your meals, steps, and how you feel.', routes.AppRouter.dashboard);
    } catch (e) {
      print('NotificationService.scheduleDailyReminders error: $e');
    }
  }

  /// Cancel all scheduled daily reminders (e.g. if user disables reminders).
  static Future<void> cancelDailyReminders() async {
    await _local.cancel(_ReminderId.breakfast);
    await _local.cancel(_ReminderId.lunch);
    await _local.cancel(_ReminderId.dinner);
    await _local.cancel(_ReminderId.exercise);
    await _local.cancel(_ReminderId.appointments);
    await _local.cancel(_ReminderId.dailyLog);
  }

  static const _remindersDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'reminders',
      'Daily reminders',
      channelDescription: 'Breakfast, lunch, dinner, exercise, and daily log reminders',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  /// Show notification when user completes a workout. Tap opens dashboard.
  static Future<void> showWorkoutCompletedNotification({
    int? caloriesBurned,
    int? durationMinutes,
  }) async {
    if (!_initialized) return;
    final id = DateTime.now().millisecondsSinceEpoch % 2147483647;
    final body = durationMinutes != null && caloriesBurned != null
        ? 'You burned ~$caloriesBurned cal in ${durationMinutes}min. Great job!'
        : 'Great job finishing your workout!';
    final payload = jsonEncode({'route': routes.AppRouter.dashboard});
    await _local.show(
      id,
      'Workout completed',
      body,
      _remindersDetails,
      payload: payload,
    );
  }

  /// Show notification when user adds a meal. Tap opens dashboard.
  static Future<void> showMealAddedNotification({String? mealType}) async {
    if (!_initialized) return;
    final id = DateTime.now().millisecondsSinceEpoch % 2147483647;
    final body = mealType != null && mealType.isNotEmpty
        ? 'Your $mealType has been logged.'
        : 'Meal logged successfully.';
    final payload = jsonEncode({'route': routes.AppRouter.dashboard});
    await _local.show(
      id,
      'Meal added',
      body,
      _remindersDetails,
      payload: payload,
    );
  }

  /// Show notification when user adds medical info. Tap opens dashboard.
  static Future<void> showMedicalInfoAddedNotification({String? entryLabel}) async {
    if (!_initialized) return;
    final id = DateTime.now().millisecondsSinceEpoch % 2147483647;
    final body = entryLabel != null && entryLabel.isNotEmpty
        ? '$entryLabel recorded.'
        : 'Medical entry saved.';
    final payload = jsonEncode({'route': routes.AppRouter.dashboard});
    await _local.show(
      id,
      'Medical info added',
      body,
      _remindersDetails,
      payload: payload,
    );
  }

  /// Show a local notification when user successfully books an appointment.
  static Future<void> showAppointmentBookedNotification({
    required String doctorName,
    required String dateStr,
    required String time,
  }) async {
    if (!_initialized) return;
    const title = 'Appointment confirmed';
    final body = 'Your appointment with $doctorName on $dateStr at $time is confirmed.';
    final id = DateTime.now().millisecondsSinceEpoch % 2147483647;
    const android = AndroidNotificationDetails(
      'appointments',
      'Appointments',
      channelDescription: 'Booking confirmations and appointment reminders',
      importance: Importance.high,
      priority: Priority.high,
    );
    const ios = DarwinNotificationDetails();
    final payload = jsonEncode({'route': routes.AppRouter.myAppointments});
    await _local.show(
      id,
      title,
      body,
      const NotificationDetails(android: android, iOS: ios),
      payload: payload,
    );
  }
}
