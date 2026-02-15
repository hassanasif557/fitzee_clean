import 'package:fitzee_new/features/dashboard/domain/entities/dashboard_data.dart';
import 'package:fitzee_new/features/dashboard/domain/repositories/dashboard_repository.dart';

/// Use case: load all data required for the dashboard (profile, health score,
/// daily data, nutrition, medical entries, workout plan and streak).
/// [DashboardCubit] calls this instead of touching services directly (Clean Architecture).
class GetDashboardDataUseCase {
  final DashboardRepository _repository;

  GetDashboardDataUseCase(this._repository);

  /// Fast load: formula health score, no meal plan.
  Future<DashboardData> call() => _repository.getDashboardData();

  /// AI data (health score + meal plan). Call after dashboard is shown; may be slow.
  Future<DashboardAIDataResult> getAIData() => _repository.getDashboardAIData();
}
