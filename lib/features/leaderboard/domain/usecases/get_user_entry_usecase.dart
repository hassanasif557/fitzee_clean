import 'package:fitzee_new/features/leaderboard/domain/entities/leaderboard_entry.dart';
import 'package:fitzee_new/features/leaderboard/domain/repositories/leaderboard_repository.dart';

/// Use case to get current user's leaderboard entry
class GetUserEntryUseCase {
  final LeaderboardRepository repository;

  GetUserEntryUseCase(this.repository);

  Future<LeaderboardEntry?> call({
    required String userId,
    required LeaderboardFilter filter,
    required LeaderboardPeriod period,
  }) {
    return repository.getUserEntry(
      userId: userId,
      filter: filter,
      period: period,
    );
  }
}
