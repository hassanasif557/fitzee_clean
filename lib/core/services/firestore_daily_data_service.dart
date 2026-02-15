import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitzee_new/core/models/daily_data.dart';
import 'package:fitzee_new/core/models/food_nutrition.dart';

/// Service to manage daily data in Firestore.
/// Collection: daily_data. All daily check-in fields are saved (steps, calories consumed,
/// sleep, healthScore, bloodSugar, bloodPressure, exerciseMinutes, caloriesBurned).
class FirestoreDailyDataService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _dailyDataCollection = 'daily_data';
  static const String _dailyNutritionCollection = 'daily_nutrition';

  /// Save all daily data to Firestore daily_data collection. [calories] = consumed; [caloriesBurned] = burned (optional).
  static Future<void> saveDailyData({
    required String userId,
    required int steps,
    required int calories,
    required double sleepHours,
    required DateTime date,
    int? healthScore,
    double? bloodSugar,
    int? bloodPressureSystolic,
    int? bloodPressureDiastolic,
    int? exerciseMinutes,
    int? caloriesBurned,
  }) async {
    try {
      final dateKey = DailyData.formatDateKey(date);
      final now = DateTime.now();
      final dailyData = DailyData(
        userId: userId,
        date: date,
        steps: steps,
        calories: calories,
        sleepHours: sleepHours,
        healthScore: healthScore,
        bloodSugar: bloodSugar,
        bloodPressureSystolic: bloodPressureSystolic,
        bloodPressureDiastolic: bloodPressureDiastolic,
        exerciseMinutes: exerciseMinutes,
        caloriesBurned: caloriesBurned,
        createdAt: now,
        updatedAt: now,
      );
      await _firestore
          .collection(_dailyDataCollection)
          .doc('${userId}_$dateKey')
          .set(dailyData.toJson(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save daily data to Firestore: $e');
    }
  }

  /// Get daily data for a specific date
  static Future<DailyData?> getDailyData(String userId, DateTime date) async {
    try {
      final dateKey = DailyData.formatDateKey(date);
      final docSnapshot = await _firestore
          .collection(_dailyDataCollection)
          .doc('${userId}_$dateKey')
          .get();

      if (!docSnapshot.exists) {
        return null;
      }

      final data = docSnapshot.data();
      if (data == null) {
        return null;
      }

      return DailyData.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get daily data from Firestore: $e');
    }
  }

  /// Get daily data for a date range
  static Future<List<DailyData>> getDailyDataRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(_dailyDataCollection)
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String())
          .where('date', isLessThanOrEqualTo: endDate.toIso8601String())
          .orderBy('date', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => DailyData.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get daily data range from Firestore: $e');
    }
  }

  /// Save daily nutrition summary to Firestore
  static Future<void> saveDailyNutrition({
    required String userId,
    required DateTime date,
    required FoodNutrition nutrition,
    required int nutritionScore,
  }) async {
    try {
      final dateKey = DailyData.formatDateKey(date);
      final now = DateTime.now();
      
      final nutritionData = {
        'userId': userId,
        'date': date.toIso8601String(),
        'totalCalories': nutrition.calories,
        'totalProtein': nutrition.protein,
        'totalCarbs': nutrition.carbs,
        'totalFat': nutrition.fat,
        'totalFiber': nutrition.fiber,
        'nutritionScore': nutritionScore,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      };

      // Use composite document ID: userId_dateKey
      await _firestore
          .collection(_dailyNutritionCollection)
          .doc('${userId}_$dateKey')
          .set(nutritionData, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save daily nutrition to Firestore: $e');
    }
  }

  /// Get daily nutrition for a specific date
  static Future<Map<String, dynamic>?> getDailyNutrition(
    String userId,
    DateTime date,
  ) async {
    try {
      final dateKey = DailyData.formatDateKey(date);
      final docSnapshot = await _firestore
          .collection(_dailyNutritionCollection)
          .doc('${userId}_$dateKey')
          .get();

      if (!docSnapshot.exists) {
        return null;
      }

      return docSnapshot.data();
    } catch (e) {
      throw Exception('Failed to get daily nutrition from Firestore: $e');
    }
  }

  /// Get all users' daily data for leaderboard (last N days)
  static Future<List<DailyData>> getAllUsersDailyData(int days) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));
      
      final querySnapshot = await _firestore
          .collection(_dailyDataCollection)
          .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String())
          .where('date', isLessThanOrEqualTo: endDate.toIso8601String())
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => DailyData.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get all users daily data from Firestore: $e');
    }
  }

  /// Get user's health score history
  static Future<List<DailyData>> getUserHealthScoreHistory(
    String userId,
    int days,
  ) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));
      
      return await getDailyDataRange(userId, startDate, endDate);
    } catch (e) {
      throw Exception('Failed to get health score history from Firestore: $e');
    }
  }

  /// Get all daily data for a user as Map<dateKey, data> for History/UI.
  static Future<Map<String, Map<String, dynamic>>> getUserDailyDataMap(
    String userId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_dailyDataCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();
      final map = <String, Map<String, dynamic>>{};
      for (final doc in snapshot.docs) {
        final d = doc.data();
        final dateStr = d['date'] as String?;
        if (dateStr != null) {
          final date = DateTime.parse(dateStr);
          final dateKey = DailyData.formatDateKey(date);
          map[dateKey] = d;
        }
      }
      return map;
    } catch (e) {
      throw Exception('Failed to get daily data map from Firestore: $e');
    }
  }
}
