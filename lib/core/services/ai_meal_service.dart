import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitzee_new/core/models/daily_meal_plan.dart';
import 'package:fitzee_new/core/services/ai_coaching_service.dart';
import 'package:fitzee_new/core/services/meal_preferences_service.dart';
import 'package:fitzee_new/features/onboard/domain/entities/user_profile.dart';

class AiMealService {
  /// Default calories when profile has no weight/height (rough maintenance).
  static const int defaultDailyCalories = 2000;

  /// Builds calories estimate from profile (Mifflin-St Jeor approx) or default.
  static int _caloriesFromProfile(UserProfile? profile) {
    if (profile?.weight != null && profile?.height != null && profile?.age != null) {
      final w = profile!.weight!;
      final h = profile.height!;
      final a = profile.age!;
      final isMale = profile.gender == 'male';
      double bmr = (10 * w) + (6.25 * h) - (5 * a) + (isMale ? 5 : -161);
      final activity = profile.trainingDaysPerWeek ?? 3;
      final factor = 1.2 + (activity * 0.1);
      return (bmr * factor).round().clamp(1200, 3500);
    }
    return defaultDailyCalories;
  }

  /// Diet type from onboard diet preferences (Vegetarian, Vegan, etc.) or 'balanced'.
  static Future<String> _dietTypeFromOnboard() async {
    final prefs = await AICoachingService.getDietPreferences();
    final restrictions = prefs['dietaryRestrictions'];
    if (restrictions is List && restrictions.isNotEmpty) {
      final first = restrictions.first.toString().toLowerCase();
      if (first.contains('vegetarian')) return 'vegetarian';
      if (first.contains('vegan')) return 'vegan';
      if (first.contains('keto')) return 'keto';
      if (first.contains('paleo')) return 'paleo';
      if (first.contains('gluten')) return 'gluten_free';
      return first.replaceAll(' ', '_');
    }
    return 'balanced';
  }

  /// Fetches daily suggested meal plan from backend using meal preferences (cuisine, conditions, allergies),
  /// profile (age, weight, goal), and onboard diet type. Returns null on error or no data.
  static Future<DailyMealPlan?> getDailySuggestedMealPlan(UserProfile? profile) async {
    final auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    if (user == null) return null;

    await user.getIdToken(true);

    final mealPrefs = await MealPreferencesService.load();
    final calories = _caloriesFromProfile(profile);
    final dietPreference = await _dietTypeFromOnboard();
    final primaryGoal = profile?.userType ?? profile?.goal ?? 'fat_loss';

    final medicalConditions = <String>[...mealPrefs.medicalConditionsForApi];
    if (profile != null) {
      if (profile.medicalProfile != null) {
        final m = profile.medicalProfile!;
        if (m.conditions.isNotEmpty && !m.conditions.contains('none')) {
          for (final c in m.conditions) {
            if (!medicalConditions.contains(c)) medicalConditions.add(c);
          }
        }
      }
      if (profile.hasDiabetes == true && !medicalConditions.contains('diabetes')) medicalConditions.add('diabetes');
      if (profile.hasHeartConditions == true && !medicalConditions.contains('heart_disease')) medicalConditions.add('heart_disease');
      if (profile.hasAsthma == true && !medicalConditions.contains('asthma')) medicalConditions.add('asthma');
    }

    final allergies = <String>[...mealPrefs.allergiesForApi];
    if (profile?.medicalProfile?.allergies != null) {
      for (final a in profile!.medicalProfile!.allergies) {
        if (a != 'none' && !allergies.any((x) => x.toLowerCase() == a.toLowerCase())) allergies.add(a);
      }
    }

    try {
      final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
      final callable = functions.httpsCallable(
        'generateMealPlan',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 45)),
      );

      final result = await callable.call({
        'preferredCuisine': mealPrefs.preferredCuisine,
        'likedFoods': mealPrefs.likedFoods,
        'calories': calories,
        'dietPreference': dietPreference,
        'medicalConditions': medicalConditions,
        'allergies': allergies,
        'age': profile?.age,
        'weight': profile?.weight,
        'primaryGoal': primaryGoal,
      });

      Map<String, dynamic> data;
      if (result.data is String) {
        try {
          data = Map<String, dynamic>.from(
            jsonDecode(result.data as String) as Map,
          );
        } catch (_) {
          data = <String, dynamic>{'mealPlan': result.data};
        }
      } else {
        data = Map<String, dynamic>.from(result.data as Map);
      }
      return DailyMealPlan.fromBackendResponse(data);
    } catch (e) {
      print('AiMealService.getDailySuggestedMealPlan error: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>> generateMealPlan({
    required int calories,
    required String dietPreference,
    required List<String> medicalConditions,
    required List<String> allergies,
  }) async {
    final auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    if (user == null) {
      await auth.signInAnonymously();
      user = auth.currentUser;
    }

    await user!.getIdToken(true);

    final functions = FirebaseFunctions.instanceFor(region: 'us-central1');

    final callable = functions.httpsCallable(
      'generateMealPlan',
      options: HttpsCallableOptions(timeout: const Duration(seconds: 30)),
    );

    final result = await callable.call({
      "calories": calories,
      "dietPreference": dietPreference,
      "medicalConditions": medicalConditions,
      "allergies": allergies,
    });

    if (result.data is String) {
      return {"mealPlan": result.data};
    }
    return Map<String, dynamic>.from(result.data);
  }
}
