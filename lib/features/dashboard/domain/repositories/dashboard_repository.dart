import 'package:fitzee_new/core/models/daily_meal_plan.dart';
import 'package:fitzee_new/features/dashboard/domain/entities/dashboard_data.dart';

/// Abstract repository for dashboard data (Clean Architecture: domain layer).
/// Implementation in data layer uses [DailyDataService], [UserProfileService], etc.
/// Cubits depend only on this interface, not on concrete services.
abstract class DashboardRepository {
  /// Returns true if the user has already submitted daily data for yesterday.
  /// Used to decide whether to show the daily data collection screen.
  Future<bool> hasDataForYesterday();

  /// Aggregates profile, health score, daily data, nutrition, medical entries,
  /// workout plan and streak into a single [DashboardData] entity.
  /// Uses formula-based health score and null meal plan for fast load; call [getDashboardAIData] after for AI meal plan.
  Future<DashboardData> getDashboardData();

  /// Fetches AI meal plan only (may be slow). Call after dashboard is shown to avoid blocking.
  Future<DashboardAIDataResult> getDashboardAIData();
}

/// Result of loading AI meal plan for dashboard.
class DashboardAIDataResult {
  final DailyMealPlan? dailyMealPlan;

  const DashboardAIDataResult({this.dailyMealPlan});
}
