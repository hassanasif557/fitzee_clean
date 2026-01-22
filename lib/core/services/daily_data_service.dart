import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitzee_new/core/services/connectivity_service.dart';
import 'package:fitzee_new/core/services/firestore_daily_data_service.dart';
import 'package:fitzee_new/core/services/health_score_service.dart';
import 'package:fitzee_new/core/services/local_storage_service.dart';
import 'package:fitzee_new/core/services/user_profile_service.dart';

class DailyDataService {
  static const String _dailyDataKey = 'daily_data';
  static const String _lastDataDateKey = 'last_data_date';

  /// Save daily data - saves to both Firestore (if online) and local storage
  static Future<void> saveDailyData({
    required int steps,
    required int calories,
    required double sleepHours,
    required DateTime date,
    String? userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get existing daily data
    final existingData = await getAllDailyData();
    
    // Add or update today's data
    final dateKey = _formatDate(date);
    existingData[dateKey] = {
      'steps': steps,
      'calories': calories,
      'sleepHours': sleepHours,
      'date': date.toIso8601String(),
    };
    
    // Save to local storage first
    await prefs.setString(_dailyDataKey, jsonEncode(existingData));
    await prefs.setString(_lastDataDateKey, dateKey);

    // If online and userId is provided, also save to Firestore
    final hasInternet = await ConnectivityService.hasInternetConnection();
    if (hasInternet) {
      try {
        // Get userId if not provided
        final finalUserId = userId ?? await LocalStorageService.getUserId();
        if (finalUserId != null && finalUserId.isNotEmpty) {
          // Calculate health score if possible
          int? healthScore;
          try {
            final profile = await UserProfileService.getUserProfile(finalUserId);
            if (profile != null) {
              final scoreData = await HealthScoreService.calculateHealthScore(profile);
              healthScore = scoreData['score'] as int?;
            }
          } catch (e) {
            // If health score calculation fails, continue without it
            print('Warning: Failed to calculate health score: $e');
          }

          // Save to Firestore
          await FirestoreDailyDataService.saveDailyData(
            userId: finalUserId,
            steps: steps,
            calories: calories,
            sleepHours: sleepHours,
            date: date,
            healthScore: healthScore,
          );
        }
      } catch (e) {
        // If Firestore save fails, local storage already has the data
        print('Warning: Failed to save to Firestore, using local storage: $e');
      }
    }
  }

  /// Get today's data
  static Future<Map<String, dynamic>?> getTodayData() async {
    final today = DateTime.now();
    final todayKey = _formatDate(today);
    final allData = await getAllDailyData();
    return allData[todayKey];
  }

  /// Get yesterday's data
  static Future<Map<String, dynamic>?> getYesterdayData() async {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayKey = _formatDate(yesterday);
    final allData = await getAllDailyData();
    return allData[yesterdayKey];
  }

  /// Get all daily data
  static Future<Map<String, Map<String, dynamic>>> getAllDailyData() async {
    final prefs = await SharedPreferences.getInstance();
    final dataString = prefs.getString(_dailyDataKey);
    
    if (dataString == null) {
      return {};
    }
    
    try {
      final data = jsonDecode(dataString) as Map<String, dynamic>;
      return data.map((key, value) => MapEntry(
        key,
        value as Map<String, dynamic>,
      ));
    } catch (e) {
      return {};
    }
  }

  /// Check if data was entered today
  static Future<bool> hasDataForToday() async {
    final todayData = await getTodayData();
    return todayData != null;
  }

  /// Check if data was entered yesterday
  static Future<bool> hasDataForYesterday() async {
    final yesterdayData = await getYesterdayData();
    return yesterdayData != null;
  }

  /// Get last data entry date
  static Future<String?> getLastDataDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastDataDateKey);
  }

  /// Get average data for last N days
  static Future<Map<String, dynamic>> getAverageData(int days) async {
    final allData = await getAllDailyData();
    final now = DateTime.now();
    
    int totalSteps = 0;
    int totalCalories = 0;
    double totalSleep = 0;
    int count = 0;
    
    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      final dateKey = _formatDate(date);
      final data = allData[dateKey];
      
      if (data != null) {
        totalSteps += (data['steps'] as int? ?? 0);
        totalCalories += (data['calories'] as int? ?? 0);
        totalSleep += (data['sleepHours'] as double? ?? 0.0);
        count++;
      }
    }
    
    if (count == 0) {
      return {
        'steps': 0,
        'calories': 0,
        'sleepHours': 0.0,
      };
    }
    
    return {
      'steps': (totalSteps / count).round(),
      'calories': (totalCalories / count).round(),
      'sleepHours': totalSleep / count,
    };
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
