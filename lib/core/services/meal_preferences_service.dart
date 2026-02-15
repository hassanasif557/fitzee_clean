import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitzee_new/core/models/meal_preferences.dart';

class MealPreferencesService {
  static const String _key = 'meal_preferences';

  static Future<void> save(MealPreferences prefs) async {
    final prefsStore = await SharedPreferences.getInstance();
    await prefsStore.setString(_key, jsonEncode(prefs.toJson()));
  }

  static Future<MealPreferences> load() async {
    final prefsStore = await SharedPreferences.getInstance();
    final s = prefsStore.getString(_key);
    if (s == null) return const MealPreferences();
    try {
      return MealPreferences.fromJson(
        jsonDecode(s) as Map<String, dynamic>?,
      );
    } catch (_) {
      return const MealPreferences();
    }
  }
}
