import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitzee_new/features/onboard/domain/entities/user_profile.dart';

class LocalStorageService {
  static const String _authKey = 'is_authenticated';
  static const String _userIdKey = 'user_id';
  static const String _onboardCompletedKey = 'onboard_completed';
  static const String _userProfileKey = 'user_profile';

  static Future<void> saveAuthState({
    required bool isAuthenticated,
    required String userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_authKey, isAuthenticated);
    await prefs.setString(_userIdKey, userId);
  }

  static Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_authKey) ?? false;
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  static Future<void> clearAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authKey);
    await prefs.remove(_userIdKey);
  }

  /// Clear all user-related data on sign out (auth, userId, onboard, profile).
  /// Call together with other services' clear methods for full sign-out.
  static Future<void> clearAllUserDataOnSignOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_onboardCompletedKey);
    await prefs.remove(_userProfileKey);
  }

  static Future<void> setOnboardCompleted(bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardCompletedKey, completed);
  }

  static Future<bool> isOnboardCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardCompletedKey) ?? false;
  }

  static Future<void> saveUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(profile.toJson());
    await prefs.setString(_userProfileKey, jsonString);
  }

  static Future<UserProfile?> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_userProfileKey);
    if (jsonString == null) return null;
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return UserProfile.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  static Future<void> clearUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userProfileKey);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
