import 'dart:async';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Central service for Firebase Crashlytics.
/// Use [setScreen] and [setLastAction] so crash reports include screen and action context.
class CrashlyticsService {
  static final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  /// Call once after Firebase.initializeApp() in main().
  /// Passes Flutter and Dart errors to Crashlytics.
  static Future<void> init() async {
    await _crashlytics.setCrashlyticsCollectionEnabled(true);
    FlutterError.onError = (details) {
      _crashlytics.recordFlutterFatalError(details);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      _crashlytics.recordError(error, stack, fatal: true);
      return true;
    };
  }

  /// Set the current user so crashes are attributed to them.
  /// Call after login; call [clearUser] on sign out.
  static Future<void> setUserIdentifier(String? userId) async {
    if (userId != null && userId.isNotEmpty) {
      await _crashlytics.setUserIdentifier(userId);
    } else {
      await _crashlytics.setUserIdentifier('');
    }
  }

  /// Clear user identifier on sign out.
  static Future<void> clearUser() => setUserIdentifier(null);

  /// Set current screen name (custom key). Shown in crash report.
  static Future<void> setScreen(String screenName) async {
    await _crashlytics.setCustomKey('screen', screenName);
  }

  /// Set last user action (custom key). Call before/after important actions.
  static Future<void> setLastAction(String action) async {
    await _crashlytics.setCustomKey('last_action', action);
  }

  /// Log a message (included with next crash report as breadcrumb).
  static Future<void> log(String message) async {
    await _crashlytics.log(message);
  }

  /// Record a non-fatal error (e.g. from catch blocks).
  static Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) async {
    await _crashlytics.recordError(
      exception,
      stack,
      reason: reason,
      fatal: fatal,
    );
  }

  /// Call to force a crash (for testing only). Remove in production.
  static void testCrash() {
    _crashlytics.crash();
  }
}
