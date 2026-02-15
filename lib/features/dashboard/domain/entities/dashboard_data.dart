/// Domain entity holding all data required to display the dashboard.
/// Used by [GetDashboardDataUseCase] so the presentation layer (Cubit)
/// does not depend on concrete services.
import 'package:fitzee_new/core/models/daily_meal_plan.dart';
import 'package:fitzee_new/core/models/exercise.dart';
import 'package:fitzee_new/core/models/food_nutrition.dart';
import 'package:fitzee_new/core/models/medical_entry.dart';
import 'package:fitzee_new/features/onboard/domain/entities/user_profile.dart';

class DashboardData {
  final UserProfile? userProfile;
  final Map<String, dynamic>? healthScore;
  final Map<String, dynamic>? dailyData;
  final FoodNutrition? todayNutrition;
  final List<MedicalEntry> todayMedicalEntries;
  final WorkoutPlan? workoutPlan;
  final WorkoutDay? todayWorkout;
  final int workoutStreak;
  final DailyMealPlan? dailyMealPlan;

  const DashboardData({
    this.userProfile,
    this.healthScore,
    this.dailyData,
    this.todayNutrition,
    this.todayMedicalEntries = const [],
    this.workoutPlan,
    this.todayWorkout,
    this.workoutStreak = 0,
    this.dailyMealPlan,
  });
}
