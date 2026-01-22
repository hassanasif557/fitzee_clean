import 'package:fitzee_new/features/leaderboard/domain/entities/leaderboard_entry.dart';

/// Repository interface for leaderboard operations
abstract class LeaderboardRepository {
  /// Get leaderboard entries
  /// [filter] determines how entries are ranked
  /// [period] determines the time period for data
  /// [limit] maximum number of entries to return
  Future<List<LeaderboardEntry>> getLeaderboard({
    required LeaderboardFilter filter,
    required LeaderboardPeriod period,
    int limit = 100,
  });

  /// Get current user's rank in leaderboard
  Future<int?> getUserRank({
    required String userId,
    required LeaderboardFilter filter,
    required LeaderboardPeriod period,
  });

  /// Get current user's leaderboard entry
  Future<LeaderboardEntry?> getUserEntry({
    required String userId,
    required LeaderboardFilter filter,
    required LeaderboardPeriod period,
  });
}
