import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'local_storage_service.dart';

/// Handles FCM token and push notifications for appointment booking & reminders.
/// Call [init] after Firebase.initializeApp(). Call [saveTokenForUser] after login.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Optional: handle background message (e.g. update UI via storage)
}

class NotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();
  static const String _userProfilesCollection = 'user_profiles';

  static bool _initialized = false;

  /// Call once after Firebase.initializeApp().
  static Future<void> init() async {
    if (_initialized) return;
    await _requestPermission();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
    );
    await _local.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
    if (Platform.isAndroid) {
      final channel = AndroidNotificationChannel(
        'appointments',
        'Appointments',
        description: 'Booking confirmations and appointment reminders',
        importance: Importance.high,
      );
      await _local
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
    _initialized = true;
  }

  static void _onNotificationTap(NotificationResponse response) {
    // Optional: navigate to My Appointments when user taps notification
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
  /// Call after user is logged in (e.g. from dashboard or auth callback).
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

  /// Remove FCM token for user on sign out (so they no longer receive push for this account).
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
      final title = message.notification?.title ?? 'Appointment';
      final body = message.notification?.body ?? '';
      _showLocalNotification(title: title, body: body);
    });
  }

  static Future<void> _showLocalNotification({required String title, required String body}) async {
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
    );
  }

  /// Show a local notification when user successfully books an appointment (no Cloud Function needed).
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
    await _local.show(
      id,
      title,
      body,
      const NotificationDetails(android: android, iOS: ios),
    );
  }
}
