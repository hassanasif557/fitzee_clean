import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitzee_new/core/models/food_nutrition.dart';
import 'package:fitzee_new/core/services/connectivity_service.dart';
import 'package:fitzee_new/core/services/firestore_daily_data_service.dart';
import 'package:fitzee_new/core/services/health_score_service.dart';
import 'package:fitzee_new/core/services/local_storage_service.dart';
import 'package:fitzee_new/core/services/user_profile_service.dart';

// FoodEntry is defined in food_nutrition.dart

/// Service to track daily nutrition entries
class DailyNutritionService {
  static const String _nutritionDataKey = 'daily_nutrition';

  /// Save a food entry - saves to both Firestore (if online) and local storage
  static Future<void> saveFoodEntry(FoodEntry entry, {String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final allEntries = await getAllFoodEntries();
    
    // Add new entry
    allEntries.add(entry);
    
    // Save to local storage first
    final entriesJson = allEntries.map((e) => e.toJson()).toList();
    await prefs.setString(_nutritionDataKey, jsonEncode(entriesJson));

    // If online, also sync nutrition summary to Firestore
    final hasInternet = await ConnectivityService.hasInternetConnection();
    if (hasInternet) {
      try {
        // Get userId if not provided
        final finalUserId = userId ?? await LocalStorageService.getUserId();
        if (finalUserId != null && finalUserId.isNotEmpty) {
          // Calculate total nutrition for the date
          final dateNutrition = await getTotalNutritionForDate(entry.date);
          
          // Calculate nutrition score
          int nutritionScore = 60; // Default score
          try {
            final profile = await UserProfileService.getUserProfile(finalUserId);
            if (profile != null) {
              final recommendedCalories = HealthScoreService.calculateRecommendedCalories(profile);
              final calorieScore = HealthScoreService.calorieScore(
                dateNutrition.calories.round(),
                recommendedCalories,
              );
              // Simple nutrition score based on calorie score
              nutritionScore = calorieScore;
            }
          } catch (e) {
            print('Warning: Failed to calculate nutrition score: $e');
          }

          // Save nutrition summary to Firestore
          await FirestoreDailyDataService.saveDailyNutrition(
            userId: finalUserId,
            date: entry.date,
            nutrition: dateNutrition,
            nutritionScore: nutritionScore,
          );
        }
      } catch (e) {
        // If Firestore save fails, local storage already has the data
        print('Warning: Failed to save nutrition to Firestore, using local storage: $e');
      }
    }
  }

  /// Get all food entries
  static Future<List<FoodEntry>> getAllFoodEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final dataString = prefs.getString(_nutritionDataKey);
    
    if (dataString == null) {
      return [];
    }
    
    try {
      final data = jsonDecode(dataString) as List;
      return data.map((json) => FoodEntry.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get food entries for a specific date
  static Future<List<FoodEntry>> getFoodEntriesForDate(DateTime date) async {
    final allEntries = await getAllFoodEntries();
    final dateKey = _formatDate(date);
    
    return allEntries.where((entry) {
      final entryDateKey = _formatDate(entry.date);
      return entryDateKey == dateKey;
    }).toList();
  }

  /// Get today's food entries
  static Future<List<FoodEntry>> getTodayEntries() async {
    return getFoodEntriesForDate(DateTime.now());
  }

  /// Get yesterday's food entries
  static Future<List<FoodEntry>> getYesterdayEntries() async {
    return getFoodEntriesForDate(DateTime.now().subtract(const Duration(days: 1)));
  }

  /// Calculate total nutrition for a date
  static Future<FoodNutrition> getTotalNutritionForDate(DateTime date) async {
    final entries = await getFoodEntriesForDate(date);
    
    if (entries.isEmpty) {
      return FoodNutrition(calories: 0, protein: 0, carbs: 0, fat: 0);
    }
    
    final nutritionList = entries.map((entry) => entry.nutrition).toList();
    return FoodNutrition.sum(nutritionList);
  }

  /// Get today's total nutrition
  static Future<FoodNutrition> getTodayNutrition() async {
    return getTotalNutritionForDate(DateTime.now());
  }

  /// Get yesterday's total nutrition
  static Future<FoodNutrition> getYesterdayNutrition() async {
    return getTotalNutritionForDate(DateTime.now().subtract(const Duration(days: 1)));
  }

  /// Get average nutrition for last N days
  static Future<FoodNutrition> getAverageNutrition(int days) async {
    final now = DateTime.now();
    final nutritionList = <FoodNutrition>[];
    
    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      final nutrition = await getTotalNutritionForDate(date);
      if (nutrition.calories > 0) {
        nutritionList.add(nutrition);
      }
    }
    
    if (nutritionList.isEmpty) {
      return FoodNutrition(calories: 0, protein: 0, carbs: 0, fat: 0);
    }
    
    final total = FoodNutrition.sum(nutritionList);
    final count = nutritionList.length;
    
    return FoodNutrition(
      calories: total.calories / count,
      protein: total.protein / count,
      carbs: total.carbs / count,
      fat: total.fat / count,
      fiber: total.fiber != null ? total.fiber! / count : null,
    );
  }

  /// Delete a food entry - updates both Firestore (if online) and local storage
  static Future<void> deleteFoodEntry(FoodEntry entry, {String? userId}) async {
    final allEntries = await getAllFoodEntries();
    allEntries.removeWhere((e) => 
      e.foodId == entry.foodId &&
      e.date == entry.date &&
      e.mealType == entry.mealType
    );
    
    // Update local storage first
    final prefs = await SharedPreferences.getInstance();
    final entriesJson = allEntries.map((e) => e.toJson()).toList();
    await prefs.setString(_nutritionDataKey, jsonEncode(entriesJson));

    // If online, also update Firestore
    final hasInternet = await ConnectivityService.hasInternetConnection();
    if (hasInternet) {
      try {
        final finalUserId = userId ?? await LocalStorageService.getUserId();
        if (finalUserId != null && finalUserId.isNotEmpty) {
          // Recalculate and update nutrition summary
          final dateNutrition = await getTotalNutritionForDate(entry.date);
          
          int nutritionScore = 60;
          try {
            final profile = await UserProfileService.getUserProfile(finalUserId);
            if (profile != null) {
              final recommendedCalories = HealthScoreService.calculateRecommendedCalories(profile);
              final calorieScore = HealthScoreService.calorieScore(
                dateNutrition.calories.round(),
                recommendedCalories,
              );
              nutritionScore = calorieScore;
            }
          } catch (e) {
            print('Warning: Failed to calculate nutrition score: $e');
          }

          await FirestoreDailyDataService.saveDailyNutrition(
            userId: finalUserId,
            date: entry.date,
            nutrition: dateNutrition,
            nutritionScore: nutritionScore,
          );
        }
      } catch (e) {
        print('Warning: Failed to update nutrition in Firestore: $e');
      }
    }
  }

  /// Get nutrition by meal type for a date
  static Future<Map<String, FoodNutrition>> getNutritionByMeal(DateTime date) async {
    final entries = await getFoodEntriesForDate(date);
    final mealMap = <String, List<FoodNutrition>>{};
    
    for (final entry in entries) {
      if (!mealMap.containsKey(entry.mealType)) {
        mealMap[entry.mealType] = [];
      }
      mealMap[entry.mealType]!.add(entry.nutrition);
    }
    
    return mealMap.map((meal, nutritionList) => 
      MapEntry(meal, FoodNutrition.sum(nutritionList))
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Clear local nutrition entries (call on sign out for security).
  static Future<void> clearLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_nutritionDataKey);
  }
}
