import 'package:fitzee_new/core/models/exercise.dart';
import 'package:fitzee_new/core/services/ai_meal_service.dart';
import 'package:fitzee_new/core/services/daily_data_service.dart';
import 'package:fitzee_new/core/services/daily_nutrition_service.dart';
import 'package:fitzee_new/core/services/health_score_service.dart';
import 'package:fitzee_new/core/services/local_storage_service.dart';
import 'package:fitzee_new/core/services/medical_entry_service.dart';
import 'package:fitzee_new/core/services/user_profile_service.dart';
import 'package:fitzee_new/core/services/workout_generator_service.dart';
import 'package:fitzee_new/core/services/workout_tracking_service.dart';
import 'package:fitzee_new/features/dashboard/domain/entities/dashboard_data.dart';
import 'package:fitzee_new/features/dashboard/domain/repositories/dashboard_repository.dart';

import '../../../../core/models/daily_meal_plan.dart';

/// Implementation of [DashboardRepository] (Clean Architecture: data layer).
/// Delegates to existing core services so business logic stays in use cases
/// and presentation depends only on the domain repository interface.
class DashboardRepositoryImpl implements DashboardRepository {
  @override
  Future<bool> hasDataForYesterday() =>
      DailyDataService.hasDataForYesterday();

  @override
  Future<DashboardData> getDashboardData() async {
    try {
      final userId = await LocalStorageService.getUserId();
      final profile = await UserProfileService.getUserProfile(userId);

      final yesterdayData = await DailyDataService.getYesterdayData();
      final averageData = await DailyDataService.getAverageData(7);
      final dailyData = yesterdayData ?? averageData;

      final todayNutrition = await DailyNutritionService.getTodayNutrition();
      final todayMedicalEntries =
          await MedicalEntryService.getTodayMedicalEntries();

      final savedPlanJson = await WorkoutTrackingService.getWorkoutPlan();
      final workoutPlan = savedPlanJson != null
          ? WorkoutPlan.fromJson(savedPlanJson)
          : _generateAndPersistPlan(profile);

      final todayWorkout =
          WorkoutGeneratorService.getTodayWorkout(workoutPlan);
      final workoutStreak = await WorkoutTrackingService.getWorkoutStreak();

      // Fast path: formula health score, no meal plan (AI loaded in background via getDashboardAIData)
      Map<String, dynamic>? healthScore;
      try {
        healthScore = await HealthScoreService.calculateHealthScore(profile);
      } catch (_) {}

      return DashboardData(
        userProfile: profile,
        healthScore: healthScore,
        dailyData: dailyData,
        todayNutrition: todayNutrition,
        todayMedicalEntries: todayMedicalEntries,
        workoutPlan: workoutPlan,
        todayWorkout: todayWorkout,
        workoutStreak: workoutStreak,
        dailyMealPlan: null,
      );
    } catch (e) {
      print('Warning: getDashboardData failed (offline or error), returning empty: $e');
      try {
        final averageData = await DailyDataService.getAverageData(7);
        return DashboardData(dailyData: averageData, todayMedicalEntries: const [], dailyMealPlan: null);
      } catch (_) {
        return const DashboardData(todayMedicalEntries: [], dailyMealPlan: null);
      }
    }
  }

  @override
  Future<DashboardAIDataResult> getDashboardAIData() async {
    try {
      final userId = await LocalStorageService.getUserId();
      final profile = await UserProfileService.getUserProfile(userId);
      if (profile == null) return const DashboardAIDataResult();

      final dailyMealPlan = await AiMealService.getDailySuggestedMealPlan(profile);
      return DashboardAIDataResult(dailyMealPlan: dailyMealPlan);
    } catch (e) {
      print('Warning: getDashboardAIData failed: $e');
      return const DashboardAIDataResult();
    }
  }

  /// Generates a new workout plan from profile and persists it via service.
  WorkoutPlan _generateAndPersistPlan(profile) {
    final daysPerWeek = profile?.trainingDaysPerWeek ??
        profile?.exerciseFrequencyPerWeek ??
        3;
    final plan = WorkoutGeneratorService.generateWorkoutPlan(
      profile: profile,
      daysPerWeek: daysPerWeek,
    );
    WorkoutTrackingService.saveWorkoutPlan(plan.toJson());
    return plan;
  }
}
