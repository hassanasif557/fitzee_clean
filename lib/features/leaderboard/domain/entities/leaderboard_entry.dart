/// Entity representing a user's entry in the leaderboard
class LeaderboardEntry {
  final String userId;
  final String? userName;
  final int rank;
  final int healthScore;
  final int healthScoreImprovement; // Improvement from previous period
  final int nutritionScore;
  final int nutritionScoreImprovement;
  final int averageSteps;
  final int averageCalories;
  final double averageSleepHours;
  final int workoutStreak;
  final String? profileImageUrl;

  LeaderboardEntry({
    required this.userId,
    this.userName,
    required this.rank,
    required this.healthScore,
    required this.healthScoreImprovement,
    required this.nutritionScore,
    required this.nutritionScoreImprovement,
    required this.averageSteps,
    required this.averageCalories,
    required this.averageSleepHours,
    required this.workoutStreak,
    this.profileImageUrl,
  });

  /// Calculate total improvement score (weighted combination)
  int get totalImprovementScore {
    return ((healthScoreImprovement * 0.6) + (nutritionScoreImprovement * 0.4)).round();
  }
}

/// Leaderboard filter/sort options
enum LeaderboardFilter {
  healthScore, // Rank by health score
  healthImprovement, // Rank by health score improvement
  nutritionScore, // Rank by nutrition score
  nutritionImprovement, // Rank by nutrition improvement
  totalImprovement, // Rank by combined improvement
}

/// Leaderboard time period
enum LeaderboardPeriod {
  week, // Last 7 days
  month, // Last 30 days
  allTime, // All time
}
