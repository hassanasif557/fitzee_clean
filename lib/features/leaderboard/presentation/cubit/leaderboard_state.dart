/// States for the leaderboard screen: initial, loading, loaded (with entries and filter/period), error.
import 'package:equatable/equatable.dart';
import 'package:fitzee_new/features/leaderboard/domain/entities/leaderboard_entry.dart';

abstract class LeaderboardState extends Equatable {
  const LeaderboardState();

  @override
  List<Object?> get props => [];
}

class LeaderboardInitial extends LeaderboardState {}

class LeaderboardLoading extends LeaderboardState {}

class LeaderboardLoaded extends LeaderboardState {
  final List<LeaderboardEntry> entries;
  final LeaderboardEntry? currentUserEntry;
  final LeaderboardFilter currentFilter;
  final LeaderboardPeriod currentPeriod;

  const LeaderboardLoaded({
    required this.entries,
    this.currentUserEntry,
    required this.currentFilter,
    required this.currentPeriod,
  });

  @override
  List<Object?> get props => [entries, currentUserEntry, currentFilter, currentPeriod];

  LeaderboardLoaded copyWith({
    List<LeaderboardEntry>? entries,
    LeaderboardEntry? currentUserEntry,
    LeaderboardFilter? currentFilter,
    LeaderboardPeriod? currentPeriod,
  }) {
    return LeaderboardLoaded(
      entries: entries ?? this.entries,
      currentUserEntry: currentUserEntry ?? this.currentUserEntry,
      currentFilter: currentFilter ?? this.currentFilter,
      currentPeriod: currentPeriod ?? this.currentPeriod,
    );
  }
}

class LeaderboardError extends LeaderboardState {
  final String message;

  const LeaderboardError(this.message);

  @override
  List<Object?> get props => [message];
}
