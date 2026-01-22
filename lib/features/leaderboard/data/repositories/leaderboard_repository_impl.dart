import 'package:fitzee_new/core/models/daily_data.dart';
import 'package:fitzee_new/features/leaderboard/data/datasources/leaderboard_remote_datasource.dart';
import 'package:fitzee_new/features/leaderboard/domain/entities/leaderboard_entry.dart';
import 'package:fitzee_new/features/leaderboard/domain/repositories/leaderboard_repository.dart';
import 'package:fitzee_new/features/onboard/domain/entities/user_profile.dart';

/// Implementation of LeaderboardRepository
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
      // Calculate date range based on period
      final endDate = DateTime.now();
      final startDate = _getStartDateForPeriod(period, endDate);

      // Get all users' daily data
      final allDailyData = await remoteDataSource.getAllUsersDailyData(
        startDate: startDate,
        endDate: endDate,
      );

      // Group data by user
      final userDataMap = <String, List<DailyData>>{};
      for (final data in allDailyData) {
        if (!userDataMap.containsKey(data.userId)) {
          userDataMap[data.userId] = [];
        }
        userDataMap[data.userId]!.add(data);
      }

      // Calculate metrics for each user
      final entries = <LeaderboardEntry>[];
      for (final userId in userDataMap.keys) {
        final userDailyData = userDataMap[userId]!;
        final entry = await _calculateLeaderboardEntry(
          userId: userId,
          dailyData: userDailyData,
          startDate: startDate,
          endDate: endDate,
        );
        if (entry != null) {
          entries.add(entry);
        }
      }

      // Sort based on filter
      entries.sort((a, b) {
        switch (filter) {
          case LeaderboardFilter.healthScore:
            return b.healthScore.compareTo(a.healthScore);
          case LeaderboardFilter.healthImprovement:
            return b.healthScoreImprovement.compareTo(a.healthScoreImprovement);
          case LeaderboardFilter.nutritionScore:
            return b.nutritionScore.compareTo(a.nutritionScore);
          case LeaderboardFilter.nutritionImprovement:
            return b.nutritionScoreImprovement.compareTo(a.nutritionScoreImprovement);
          case LeaderboardFilter.totalImprovement:
            return b.totalImprovementScore.compareTo(a.totalImprovementScore);
        }
      });

      // Assign ranks and limit results
      for (int i = 0; i < entries.length && i < limit; i++) {
        entries[i] = LeaderboardEntry(
          userId: entries[i].userId,
          userName: entries[i].userName,
          rank: i + 1,
          healthScore: entries[i].healthScore,
          healthScoreImprovement: entries[i].healthScoreImprovement,
          nutritionScore: entries[i].nutritionScore,
          nutritionScoreImprovement: entries[i].nutritionScoreImprovement,
          averageSteps: entries[i].averageSteps,
          averageCalories: entries[i].averageCalories,
          averageSleepHours: entries[i].averageSleepHours,
          workoutStreak: entries[i].workoutStreak,
          profileImageUrl: entries[i].profileImageUrl,
        );
      }

      return entries.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to get leaderboard: $e');
    }
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
        limit: 1000, // Get more entries to find user's rank
      );

      final userIndex = leaderboard.indexWhere((entry) => entry.userId == userId);
      if (userIndex == -1) {
        return null;
      }

      return leaderboard[userIndex].rank;
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

      return leaderboard.firstWhere(
        (entry) => entry.userId == userId,
        orElse: () => throw Exception('User not found in leaderboard'),
      );
    } catch (e) {
      return null;
    }
  }

  /// Calculate leaderboard entry for a user
  Future<LeaderboardEntry?> _calculateLeaderboardEntry({
    required String userId,
    required List<DailyData> dailyData,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (dailyData.isEmpty) return null;

    // Get user profile for name
    final profile = await remoteDataSource.getUserProfile(userId);
    final userName = profile?.name;

    // Calculate averages
    final totalSteps = dailyData.fold<int>(0, (sum, data) => sum + data.steps);
    final totalCalories = dailyData.fold<int>(0, (sum, data) => sum + data.calories);
    final totalSleep = dailyData.fold<double>(0, (sum, data) => sum + data.sleepHours);
    final count = dailyData.length;

    final averageSteps = count > 0 ? (totalSteps / count).round() : 0;
    final averageCalories = count > 0 ? (totalCalories / count).round() : 0;
    final averageSleepHours = count > 0 ? (totalSleep / count) : 0.0;

    // Calculate current period scores
    final currentHealthScores = dailyData
        .where((data) => data.healthScore != null)
        .map((data) => data.healthScore!)
        .toList();
    final currentHealthScore = currentHealthScores.isNotEmpty
        ? (currentHealthScores.reduce((a, b) => a + b) / currentHealthScores.length).round()
        : 0;

    // Get nutrition data
    final nutritionData = await remoteDataSource.getUserNutritionData(
      userId,
      startDate,
      endDate,
    );
    final currentNutritionScores = nutritionData
        .where((data) => data['nutritionScore'] != null)
        .map((data) => data['nutritionScore'] as int)
        .toList();
    final currentNutritionScore = currentNutritionScores.isNotEmpty
        ? (currentNutritionScores.reduce((a, b) => a + b) / currentNutritionScores.length).round()
        : 60;

    // Calculate previous period for improvement comparison
    final previousPeriodDays = endDate.difference(startDate).inDays;
    final previousStartDate = startDate.subtract(Duration(days: previousPeriodDays));
    final previousEndDate = startDate;

    final previousHealthScores = await remoteDataSource.getUserHealthScoreHistory(
      userId,
      previousStartDate,
      previousEndDate,
    );
    final previousHealthScoreList = previousHealthScores
        .where((data) => data.healthScore != null)
        .map((data) => data.healthScore!)
        .toList();
    final previousHealthScore = previousHealthScoreList.isNotEmpty
        ? (previousHealthScoreList.reduce((a, b) => a + b) / previousHealthScoreList.length).round()
        : currentHealthScore;

    final previousNutritionData = await remoteDataSource.getUserNutritionData(
      userId,
      previousStartDate,
      previousEndDate,
    );
    final previousNutritionScores = previousNutritionData
        .where((data) => data['nutritionScore'] != null)
        .map((data) => data['nutritionScore'] as int)
        .toList();
    final previousNutritionScore = previousNutritionScores.isNotEmpty
        ? (previousNutritionScores.reduce((a, b) => a + b) / previousNutritionScores.length).round()
        : currentNutritionScore;

    // Calculate improvements
    final healthScoreImprovement = currentHealthScore - previousHealthScore;
    final nutritionScoreImprovement = currentNutritionScore - previousNutritionScore;

    // Calculate workout streak (simplified - would need workout data)
    final workoutStreak = 0; // TODO: Implement workout streak calculation

    return LeaderboardEntry(
      userId: userId,
      userName: userName,
      rank: 0, // Will be assigned later
      healthScore: currentHealthScore,
      healthScoreImprovement: healthScoreImprovement,
      nutritionScore: currentNutritionScore,
      nutritionScoreImprovement: nutritionScoreImprovement,
      averageSteps: averageSteps,
      averageCalories: averageCalories,
      averageSleepHours: averageSleepHours,
      workoutStreak: workoutStreak,
    );
  }

  DateTime _getStartDateForPeriod(LeaderboardPeriod period, DateTime endDate) {
    switch (period) {
      case LeaderboardPeriod.week:
        return endDate.subtract(const Duration(days: 7));
      case LeaderboardPeriod.month:
        return endDate.subtract(const Duration(days: 30));
      case LeaderboardPeriod.allTime:
        return DateTime(2020, 1, 1); // Arbitrary start date
    }
  }
}
