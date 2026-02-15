import 'package:fitzee_new/features/leaderboard/domain/entities/leaderboard_entry.dart';
import 'package:fitzee_new/features/leaderboard/domain/repositories/leaderboard_repository.dart';

/// Use case to get leaderboard entries
class GetLeaderboardUseCase {
  final LeaderboardRepository repository;

  GetLeaderboardUseCase(this.repository);

  Future<List<LeaderboardEntry>> call({
    required LeaderboardFilter filter,
    required LeaderboardPeriod period,
    int limit = 100,
  }) {
    print('leaderboard usecase before repository.getLeaderboard');
    return repository.getLeaderboard(
      filter: filter,
      period: period,
      limit: limit,
    );
  }
}
