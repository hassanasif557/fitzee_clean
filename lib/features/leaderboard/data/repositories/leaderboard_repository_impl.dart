import 'package:fitzee_new/core/models/daily_data.dart';
import 'package:fitzee_new/features/leaderboard/data/datasources/leaderboard_remote_datasource.dart';
import 'package:fitzee_new/features/leaderboard/domain/entities/leaderboard_entry.dart';
import 'package:fitzee_new/features/leaderboard/domain/repositories/leaderboard_repository.dart';
import 'package:fitzee_new/features/onboard/domain/entities/user_profile.dart';

/// Implementation of LeaderboardRepository.
/// Ranks by health score only using daily_data (one Firestore query + parallel profile fetches).
class LeaderboardRepositoryImpl implements LeaderboardRepository {
  final LeaderboardRemoteDataSource remoteDataSource;

  LeaderboardRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<LeaderboardEntry>> getLeaderboard({
    required LeaderboardFilter filter,
    required LeaderboardPeriod period,
    int limit = 100,
  }) async {
    try {
      final endDate = DateTime.now();
      final startDate = _getStartDateForPeriod(period, endDate);
      final days = endDate.difference(startDate).inDays;

      // Single query: all users' daily data for the period
      final allDailyData = await remoteDataSource.getAllUsersDailyData(
        startDate: startDate,
        endDate: endDate,
      );

      // Group by user
      final userDataMap = <String, List<DailyData>>{};
      for (final data in allDailyData) {
        userDataMap.putIfAbsent(data.userId, () => []).add(data);
      }

      final userIds = userDataMap.keys.toList();
      if (userIds.isEmpty) return [];

      // Fetch all profiles in parallel (one batch instead of N sequential)
      final profiles = await Future.wait<UserProfile?>(
        userIds.map((id) => remoteDataSource.getUserProfile(id)),
      );
      final profileMap = <String, UserProfile?>{};
      for (var i = 0; i < userIds.length; i++) {
        profileMap[userIds[i]] = profiles[i];
      }

      // Build entries from daily data only (no nutrition or previous-period calls)
      final entries = <LeaderboardEntry>[];
      for (final userId in userDataMap.keys) {
        final dailyData = userDataMap[userId]!;
        final profile = profileMap[userId];
        final entry = _entryFromDailyData(
          userId: userId,
          dailyData: dailyData,
          userName: profile?.name,
        );
        if (entry != null) entries.add(entry);
      }

      // Rank by health score descending
      entries.sort((a, b) => b.healthScore.compareTo(a.healthScore));

      // Assign ranks and limit
      final limited = entries.take(limit).toList();
      return limited.asMap().entries.map((e) {
        final entry = e.value;
        return LeaderboardEntry(
          userId: entry.userId,
          userName: entry.userName,
          rank: e.key + 1,
          healthScore: entry.healthScore,
          healthScoreImprovement: entry.healthScoreImprovement,
          nutritionScore: entry.nutritionScore,
          nutritionScoreImprovement: entry.nutritionScoreImprovement,
          averageSteps: entry.averageSteps,
          averageCalories: entry.averageCalories,
          averageSleepHours: entry.averageSleepHours,
          workoutStreak: entry.workoutStreak,
          profileImageUrl: entry.profileImageUrl,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to get leaderboard: $e');
    }
  }

  /// Build one entry from a user's daily data (no extra Firestore calls).
  LeaderboardEntry? _entryFromDailyData({
    required String userId,
    required List<DailyData> dailyData,
    String? userName,
  }) {
    if (dailyData.isEmpty) return null;

    final count = dailyData.length;
    final totalSteps = dailyData.fold<int>(0, (s, d) => s + d.steps);
    final totalCalories = dailyData.fold<int>(0, (s, d) => s + d.calories);
    final totalSleep = dailyData.fold<double>(0, (s, d) => s + d.sleepHours);

    final healthScores = dailyData
        .where((d) => d.healthScore != null)
        .map((d) => d.healthScore!);
    final healthScore = healthScores.isNotEmpty
        ? (healthScores.reduce((a, b) => a + b) / healthScores.length).round()
        : 0;

    return LeaderboardEntry(
      userId: userId,
      userName: userName,
      rank: 0,
      healthScore: healthScore,
      healthScoreImprovement: 0,
      nutritionScore: 0,
      nutritionScoreImprovement: 0,
      averageSteps: count > 0 ? (totalSteps / count).round() : 0,
      averageCalories: count > 0 ? (totalCalories / count).round() : 0,
      averageSleepHours: count > 0 ? totalSleep / count : 0.0,
      workoutStreak: 0,
    );
  }

  @override
  Future<int?> getUserRank({
    required String userId,
    required LeaderboardFilter filter,
    required LeaderboardPeriod period,
  }) async {
    try {
      final leaderboard = await getLeaderboard(
        filter: filter,
        period: period,
        limit: 1000,
      );
      final index = leaderboard.indexWhere((e) => e.userId == userId);
      return index >= 0 ? leaderboard[index].rank : null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<LeaderboardEntry?> getUserEntry({
    required String userId,
    required LeaderboardFilter filter,
    required LeaderboardPeriod period,
  }) async {
    try {
      final leaderboard = await getLeaderboard(
        filter: filter,
        period: period,
        limit: 1000,
      );
      final index = leaderboard.indexWhere((e) => e.userId == userId);
      return index >= 0 ? leaderboard[index] : null;
    } catch (e) {
      return null;
    }
  }

  DateTime _getStartDateForPeriod(LeaderboardPeriod period, DateTime endDate) {
    switch (period) {
      case LeaderboardPeriod.week:
        return endDate.subtract(const Duration(days: 7));
      case LeaderboardPeriod.month:
        return endDate.subtract(const Duration(days: 30));
      case LeaderboardPeriod.allTime:
        return DateTime(2020, 1, 1);
    }
  }
}
