import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitzee_new/core/services/openai_service.dart';
import 'package:fitzee_new/core/services/local_storage_service.dart';
import 'package:fitzee_new/core/services/user_profile_service.dart';
import 'package:fitzee_new/core/services/daily_data_service.dart';
import 'package:fitzee_new/features/onboard/domain/entities/user_profile.dart';

class AICoachingService {
  static const String _healthScoreKey = 'health_score';
  static const String _workoutPlanKey = 'workout_plan';
  static const String _dietPlanKey = 'diet_plan';
  static const String _workoutPreferencesKey = 'workout_preferences';
  static const String _dietPreferencesKey = 'diet_preferences';

  /// Get or generate health score
  static Future<Map<String, dynamic>> getHealthScore({bool forceRegenerate = false}) async {
    try {
      // Try to get cached health score (unless forcing regeneration)
      if (!forceRegenerate) {
        final cached = await _getCachedData(_healthScoreKey);
        if (cached != null) {
          return cached;
        }
      }

      // Generate new health score with daily data
      final userId = await LocalStorageService.getUserId();
      final profile = await UserProfileService.getUserProfile(userId);
      
      if (profile == null) {
        throw Exception('User profile not found');
      }

      final profileData = profile.toJson();
      
      // Get daily data
      final yesterdayData = await DailyDataService.getYesterdayData();
      final averageData = await DailyDataService.getAverageData(7);
      
      // Combine profile and daily data
      final combinedData = {
        ...profileData,
        'yesterdayData': yesterdayData ?? {},
        'averageData': averageData,
      };
      
      print('AICoachingService: Generating health score with combined data');
      print('AICoachingService: Profile data keys: ${combinedData.keys.toList()}');
      
      final healthScore = await OpenAIService.generateHealthScore(combinedData);
      
      print('AICoachingService: Health score generated successfully: ${healthScore['score']}');
      
      // Cache the result
      await _saveCachedData(_healthScoreKey, healthScore);
      
      return healthScore;
    } catch (e, stackTrace) {
      // Log the actual error instead of silently returning default
      print('AICoachingService: ERROR generating health score: $e');
      print('AICoachingService: Stack trace: $stackTrace');
      
      // Handle quota errors specifically
      if (e is QuotaExceededException) {
        print('AICoachingService: QUOTA EXCEEDED - API key has reached usage limit');
      } else if (e is RateLimitException) {
        print('AICoachingService: RATE LIMIT - Too many requests');
      } else if (e is AuthenticationException) {
        print('AICoachingService: AUTHENTICATION FAILED - Invalid API key');
      }
      
      // Check if we have cached data to return instead of default
      final cached = await _getCachedData(_healthScoreKey);
      if (cached != null) {
        print('AICoachingService: Returning cached health score due to API error');
        return cached;
      }
      
      // Only return default if no cache exists and API failed
      print('AICoachingService: WARNING - Returning default health score due to API failure');
      print('AICoachingService: This means the API call failed and no cached data exists');
      print('AICoachingService: Error type: ${e.runtimeType}');
      
      return {
        'score': 75,
        'breakdown': {
          'fitness': 70,
          'nutrition': 75,
          'recovery': 80,
          'lifestyle': 75,
        },
        'recommendations': [
          'Maintain regular exercise routine',
          'Focus on quality sleep',
          'Stay hydrated throughout the day',
        ],
      };
    }
  }

  /// Get or generate workout plan
  static Future<Map<String, dynamic>> getWorkoutPlan({bool forceRegenerate = false}) async {
    try {
      // Try to get cached workout plan (unless forcing regeneration)
      if (!forceRegenerate) {
        final cached = await _getCachedData(_workoutPlanKey);
        if (cached != null) {
          return cached;
        }
      }

      // Generate new workout plan with daily data
      final userId = await LocalStorageService.getUserId();
      final profile = await UserProfileService.getUserProfile(userId);
      final preferences = await getWorkoutPreferences();
      
      if (profile == null) {
        throw Exception('User profile not found');
      }

      final profileData = profile.toJson();
      
      // Get daily data
      final yesterdayData = await DailyDataService.getYesterdayData();
      final averageData = await DailyDataService.getAverageData(7);
      
      // Combine profile and daily data
      final combinedData = {
        ...profileData,
        'yesterdayData': yesterdayData ?? {},
        'averageData': averageData,
      };
      
      final workoutPlan = await OpenAIService.generateWorkoutPlan(
        combinedData,
        preferences,
      );
      
      // Cache the result
      await _saveCachedData(_workoutPlanKey, workoutPlan);
      
      return workoutPlan;
    } catch (e) {
      // Return default if API fails
      return {
        'planName': 'Balanced Fitness Plan',
        'difficulty': 'intermediate',
        'duration': 45,
        'weeklySchedule': [],
        'tips': [
          'Start with warm-up exercises',
          'Listen to your body',
          'Stay consistent',
        ],
      };
    }
  }

  /// Get or generate diet plan
  static Future<Map<String, dynamic>> getDietPlan({bool forceRegenerate = false}) async {
    try {
      // Try to get cached diet plan (unless forcing regeneration)
      if (!forceRegenerate) {
        final cached = await _getCachedData(_dietPlanKey);
        if (cached != null) {
          return cached;
        }
      }

      // Generate new diet plan with daily data
      final userId = await LocalStorageService.getUserId();
      final profile = await UserProfileService.getUserProfile(userId);
      final preferences = await getDietPreferences();
      
      if (profile == null) {
        throw Exception('User profile not found');
      }

      final profileData = profile.toJson();
      
      // Get daily data
      final yesterdayData = await DailyDataService.getYesterdayData();
      final averageData = await DailyDataService.getAverageData(7);
      
      // Combine profile and daily data
      final combinedData = {
        ...profileData,
        'yesterdayData': yesterdayData ?? {},
        'averageData': averageData,
      };
      
      final dietPlan = await OpenAIService.generateDietPlan(
        combinedData,
        preferences,
      );
      
      // Cache the result
      await _saveCachedData(_dietPlanKey, dietPlan);
      
      return dietPlan;
    } catch (e) {
      // Return default if API fails
      return {
        'planName': 'Balanced Nutrition Plan',
        'dailyCalories': 2000,
        'macros': {
          'protein': 150,
          'carbs': 200,
          'fats': 65,
        },
        'weeklyMealPlan': [],
        'tips': [
          'Eat balanced meals',
          'Stay hydrated',
          'Include variety in your diet',
        ],
      };
    }
  }

  /// Save workout preferences
  static Future<void> saveWorkoutPreferences(Map<String, dynamic> preferences) async {
    await _saveCachedData(_workoutPreferencesKey, preferences);
  }

  /// Get workout preferences
  static Future<Map<String, dynamic>> getWorkoutPreferences() async {
    final cached = await _getCachedData(_workoutPreferencesKey);
    return cached ?? {};
  }

  /// Save diet preferences
  static Future<void> saveDietPreferences(Map<String, dynamic> preferences) async {
    await _saveCachedData(_dietPreferencesKey, preferences);
  }

  /// Get diet preferences
  static Future<Map<String, dynamic>> getDietPreferences() async {
    final cached = await _getCachedData(_dietPreferencesKey);
    return cached ?? {};
  }

  /// Clear all cached data (useful for regeneration)
  static Future<void> clearCache() async {
    final prefs = await _getSharedPreferences();
    await prefs.remove(_healthScoreKey);
    await prefs.remove(_workoutPlanKey);
    await prefs.remove(_dietPlanKey);
  }

  /// Regenerate all plans with latest daily data
  static Future<void> regeneratePlans() async {
    await clearCache();
    await getHealthScore(forceRegenerate: true);
    await getWorkoutPlan(forceRegenerate: true);
    await getDietPlan(forceRegenerate: true);
  }

  // Helper methods for caching
  static Future<void> _saveCachedData(String key, Map<String, dynamic> data) async {
    final prefs = await _getSharedPreferences();
    await prefs.setString(key, jsonEncode(data));
  }

  static Future<Map<String, dynamic>?> _getCachedData(String key) async {
    final prefs = await _getSharedPreferences();
    final data = prefs.getString(key);
    if (data != null) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    return null;
  }
}

// Helper to get SharedPreferences instance
Future<SharedPreferences> _getSharedPreferences() async {
  return await SharedPreferences.getInstance();
}
