import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitzee_new/core/models/daily_data.dart';
import 'package:fitzee_new/core/services/firestore_daily_data_service.dart';
import 'package:fitzee_new/core/services/firestore_user_profile_service.dart';
import 'package:fitzee_new/features/onboard/domain/entities/user_profile.dart';

/// Remote datasource for leaderboard data from Firestore
class LeaderboardRemoteDataSource {
  final FirebaseFirestore firestore;

  LeaderboardRemoteDataSource({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  /// Get all users' daily data for a time period
  Future<List<DailyData>> getAllUsersDailyData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      return await FirestoreDailyDataService.getAllUsersDailyData(
        endDate.difference(startDate).inDays,
      );
    } catch (e) {
      throw Exception('Failed to get users daily data: $e');
    }
  }

  /// Get user profile by ID
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      return await FirestoreUserProfileService.getUserProfile(userId);
    } catch (e) {
      return null;
    }
  }

  /// Get daily nutrition data for a user in a date range
  Future<List<Map<String, dynamic>>> getUserNutritionData(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final nutritionList = <Map<String, dynamic>>[];
      final currentDate = startDate;

      while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
        final nutrition = await FirestoreDailyDataService.getDailyNutrition(
          userId,
          currentDate,
        );
        if (nutrition != null) {
          nutritionList.add(nutrition);
        }
        // Move to next day
        final nextDate = DateTime(
          currentDate.year,
          currentDate.month,
          currentDate.day + 1,
        );
        if (nextDate.isAfter(endDate)) break;
        // This is a simplified approach - in production, you'd want to batch query
        await Future.delayed(const Duration(milliseconds: 10)); // Rate limiting
      }

      return nutritionList;
    } catch (e) {
      throw Exception('Failed to get user nutrition data: $e');
    }
  }

  /// Get user's health score history
  Future<List<DailyData>> getUserHealthScoreHistory(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      return await FirestoreDailyDataService.getUserHealthScoreHistory(
        userId,
        endDate.difference(startDate).inDays,
      );
    } catch (e) {
      throw Exception('Failed to get user health score history: $e');
    }
  }
}
