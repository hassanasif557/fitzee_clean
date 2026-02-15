import 'package:equatable/equatable.dart';
import 'package:fitzee_new/core/models/daily_meal_plan.dart';
import 'package:fitzee_new/core/models/exercise.dart';
import 'package:fitzee_new/core/models/food_nutrition.dart';
import 'package:fitzee_new/core/models/medical_entry.dart';
import 'package:fitzee_new/features/onboard/domain/entities/user_profile.dart';

/// Immutable state for the dashboard screen (Bloc/Cubit state management).
/// Holds loading flag, error, daily-data prompt, and all data needed to render the dashboard.
/// [signOutSuccess] / [deleteAccountSuccess] are one-off flags so the UI can navigate after auth actions.
class DashboardState extends Equatable {
  final bool isLoading;
  /// True while AI health score and meal plan are loading in background.
  final bool isLoadingAI;
  final String? errorMessage;

  final bool needsDailyDataCollection;

  final UserProfile? userProfile;
  final Map<String, dynamic>? healthScore;
  final Map<String, dynamic>? dailyData;

  final FoodNutrition? todayNutrition;
  final List<MedicalEntry> todayMedicalEntries;

  final WorkoutPlan? workoutPlan;
  final WorkoutDay? todayWorkout;
  final int workoutStreak;
  final DailyMealPlan? dailyMealPlan;

  /// Set to true after sign-out completes so the UI can navigate to login.
  final bool signOutSuccess;
  /// Set to true after account deletion completes so the UI can navigate to login.
  final bool deleteAccountSuccess;
  /// Error message from sign-out or delete-account (e.g. requires-recent-login).
  final String? authError;

  const DashboardState({
    this.isLoading = true,
    this.isLoadingAI = false,
    this.errorMessage,
    this.needsDailyDataCollection = false,
    this.userProfile,
    this.healthScore,
    this.dailyData,
    this.todayNutrition,
    this.todayMedicalEntries = const [],
    this.workoutPlan,
    this.todayWorkout,
    this.workoutStreak = 0,
    this.dailyMealPlan,
    this.signOutSuccess = false,
    this.deleteAccountSuccess = false,
    this.authError,
  });

  DashboardState copyWith({
    bool? isLoading,
    bool? isLoadingAI,
    String? errorMessage,
    bool? needsDailyDataCollection,
    UserProfile? userProfile,
    Map<String, dynamic>? healthScore,
    Map<String, dynamic>? dailyData,
    FoodNutrition? todayNutrition,
    List<MedicalEntry>? todayMedicalEntries,
    WorkoutPlan? workoutPlan,
    WorkoutDay? todayWorkout,
    int? workoutStreak,
    DailyMealPlan? dailyMealPlan,
    bool? signOutSuccess,
    bool? deleteAccountSuccess,
    String? authError,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingAI: isLoadingAI ?? this.isLoadingAI,
      errorMessage: errorMessage,
      needsDailyDataCollection:
          needsDailyDataCollection ?? this.needsDailyDataCollection,
      userProfile: userProfile ?? this.userProfile,
      healthScore: healthScore ?? this.healthScore,
      dailyData: dailyData ?? this.dailyData,
      todayNutrition: todayNutrition ?? this.todayNutrition,
      todayMedicalEntries: todayMedicalEntries ?? this.todayMedicalEntries,
      workoutPlan: workoutPlan ?? this.workoutPlan,
      todayWorkout: todayWorkout ?? this.todayWorkout,
      workoutStreak: workoutStreak ?? this.workoutStreak,
      dailyMealPlan: dailyMealPlan ?? this.dailyMealPlan,
      signOutSuccess: signOutSuccess ?? this.signOutSuccess,
      deleteAccountSuccess: deleteAccountSuccess ?? this.deleteAccountSuccess,
      authError: authError,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isLoadingAI,
        errorMessage,
        needsDailyDataCollection,
        userProfile,
        healthScore,
        dailyData,
        todayNutrition,
        todayMedicalEntries,
        workoutPlan,
        todayWorkout,
        workoutStreak,
        dailyMealPlan,
        signOutSuccess,
        deleteAccountSuccess,
        authError,
      ];
}

