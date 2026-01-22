import 'package:fitzee_new/features/leaderboard/domain/entities/leaderboard_entry.dart';
import 'package:fitzee_new/features/leaderboard/domain/repositories/leaderboard_repository.dart';

/// Use case to get user's rank in leaderboard
class GetUserRankUseCase {
  final LeaderboardRepository repository;

  GetUserRankUseCase(this.repository);

  Future<int?> call({
    required String userId,
    required LeaderboardFilter filter,
    required LeaderboardPeriod period,
  }) {
    return repository.getUserRank(
      userId: userId,
      filter: filter,
      period: period,
    );
  }
}
