import 'package:fitzee_new/features/dashboard/domain/repositories/dashboard_repository.dart';

/// Use case: check if user has submitted daily data for yesterday.
/// Used by [DashboardCubit] to decide whether to show the daily data collection screen.
/// Keeps business rule "need daily data?" in domain; UI only reacts to result.
class CheckDailyDataUseCase {
  final DashboardRepository _repository;

  CheckDailyDataUseCase(this._repository);

  Future<bool> call() => _repository.hasDataForYesterday();
}
