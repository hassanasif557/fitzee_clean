import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitzee_new/core/services/local_storage_service.dart';
import 'package:fitzee_new/features/leaderboard/domain/entities/leaderboard_entry.dart';
import 'package:fitzee_new/features/leaderboard/domain/usecases/get_leaderboard_usecase.dart';
import 'package:fitzee_new/features/leaderboard/domain/usecases/get_user_entry_usecase.dart';
import 'package:fitzee_new/features/leaderboard/presentation/cubit/leaderboard_state.dart';

class LeaderboardCubit extends Cubit<LeaderboardState> {
  final GetLeaderboardUseCase getLeaderboardUseCase;
  final GetUserEntryUseCase getUserEntryUseCase;

  LeaderboardCubit({
    required this.getLeaderboardUseCase,
    required this.getUserEntryUseCase,
  }) : super(LeaderboardInitial());

  Future<void> loadLeaderboard({
    LeaderboardFilter filter = LeaderboardFilter.healthScore,
    LeaderboardPeriod period = LeaderboardPeriod.week,
  }) async {
    emit(LeaderboardLoading());

    try {
      final entries = await getLeaderboardUseCase(
        filter: filter,
        period: period,
        limit: 100,
      );

      // Get current user's entry
      LeaderboardEntry? currentUserEntry;
      try {
        final userId = await LocalStorageService.getUserId();
        if (userId != null && userId.isNotEmpty) {
          currentUserEntry = await getUserEntryUseCase(
            userId: userId,
            filter: filter,
            period: period,
          );
        }
      } catch (e) {
        // User might not be in leaderboard, continue without their entry
        print('Warning: Could not get user entry: $e');
      }

      emit(LeaderboardLoaded(
        entries: entries,
        currentUserEntry: currentUserEntry,
        currentFilter: filter,
        currentPeriod: period,
      ));
    } catch (e) {
      emit(LeaderboardError(e.toString()));
    }
  }

  Future<void> changeFilter(LeaderboardFilter filter) async {
    if (state is LeaderboardLoaded) {
      final currentState = state as LeaderboardLoaded;
      await loadLeaderboard(
        filter: filter,
        period: currentState.currentPeriod,
      );
    }
  }

  Future<void> changePeriod(LeaderboardPeriod period) async {
    if (state is LeaderboardLoaded) {
      final currentState = state as LeaderboardLoaded;
      await loadLeaderboard(
        filter: currentState.currentFilter,
        period: period,
      );
    }
  }

  Future<void> refresh() async {
    if (state is LeaderboardLoaded) {
      final currentState = state as LeaderboardLoaded;
      await loadLeaderboard(
        filter: currentState.currentFilter,
        period: currentState.currentPeriod,
      );
    }
  }
}
