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

}
