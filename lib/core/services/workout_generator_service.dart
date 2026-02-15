import 'dart:math';
import 'package:fitzee_new/core/models/exercise.dart';
import 'package:fitzee_new/core/services/exercise_database_service.dart';
import 'package:fitzee_new/core/services/workout_rules_engine.dart';
import 'package:fitzee_new/features/onboard/domain/entities/user_profile.dart';

/// Service to generate workout plans based on rules and user profile
class WorkoutGeneratorService {
  /// Generate a complete workout plan
  static WorkoutPlan generateWorkoutPlan({
    required UserProfile? profile,
    required int daysPerWeek,
  }) {
    final userGoal = profile?.userType ?? profile?.goal ?? 'fat_loss';
    final goal = (userGoal == 'medical') ? 'fat_loss' : userGoal;
    final difficulty = WorkoutRulesEngine.getRecommendedDifficulty(profile);
    final allExercises = ExerciseDatabaseService.getAllExercises();

    // Filter exercises using rules engine
    final filteredExercises = WorkoutRulesEngine.filterExercises(
      allExercises: allExercises,
      goal: goal,
      difficulty: difficulty,
      profile: profile,
    );

    if (filteredExercises.isEmpty) {
      // Fallback to beginner exercises if no matches
      return _generateFallbackPlan(userGoal, difficulty, daysPerWeek);
    }

    // Generate workout days
    final workoutDays = <WorkoutDay>[];
    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    for (int i = 0; i < daysPerWeek; i++) {
      final workoutType = WorkoutRulesEngine.getWorkoutType(goal, i, daysPerWeek);
      final typeFilteredExercises = WorkoutRulesEngine.filterByWorkoutType(
        filteredExercises,
        workoutType,
      );

      if (typeFilteredExercises.isEmpty) {
        // Use all filtered exercises if type filter returns empty
        final day = _generateWorkoutDay(
          day: dayNames[i],
          workoutType: workoutType,
          exercises: filteredExercises,
          difficulty: difficulty,
        );
        workoutDays.add(day);
      } else {
        final day = _generateWorkoutDay(
          day: dayNames[i],
          workoutType: workoutType,
          exercises: typeFilteredExercises,
          difficulty: difficulty,
        );
        workoutDays.add(day);
      }
    }

    // Calculate total duration
    final totalDuration = workoutDays.fold<int>(
      0,
      (sum, day) => sum + day.estimatedDuration,
    );

    return WorkoutPlan(
      planName: _getPlanName(userGoal, difficulty),
      goal: userGoal,
      difficulty: difficulty,
      days: workoutDays,
      totalDuration: totalDuration,
      description: _getPlanDescription(userGoal, difficulty),
    );
  }

  /// Generate a single workout day
  static WorkoutDay _generateWorkoutDay({
    required String day,
    required String workoutType,
    required List<Exercise> exercises,
    required String difficulty,
  }) {
    // Balance muscle groups
    final balancedExercises = WorkoutRulesEngine.balanceMuscleGroups(exercises);

    // Select exercises for the day
    final selectedExercises = _selectExercisesForDay(
      balancedExercises,
      workoutType,
      difficulty,
    );

    // Calculate estimated duration (warm-up + exercises + rest + cool-down)
    final estimatedDuration = _calculateDuration(selectedExercises);

    // Estimate calories (rough calculation: 5-10 calories per minute based on intensity)
    final caloriesPerMinute = difficulty == 'advanced' ? 10 : (difficulty == 'intermediate' ? 7 : 5);
    final estimatedCalories = estimatedDuration * caloriesPerMinute;

    return WorkoutDay(
      day: day,
      workoutType: workoutType,
      exercises: selectedExercises,
      estimatedDuration: estimatedDuration,
      estimatedCalories: estimatedCalories,
    );
  }

  /// Select exercises for a workout day
  static List<Exercise> _selectExercisesForDay(
    List<Exercise> availableExercises,
    String workoutType,
    String difficulty,
  ) {
    final selected = <Exercise>[];
    final random = Random();

    // Always include warm-up
    final warmUps = availableExercises.where((e) =>
        e.name.toLowerCase().contains('march') ||
        e.name.toLowerCase().contains('arm circle') ||
        e.name.toLowerCase().contains('neck')).toList();
    if (warmUps.isNotEmpty) {
      selected.add(warmUps[random.nextInt(warmUps.length)]);
    }

    // Select main exercises based on workout type and difficulty
    int exerciseCount;
    if (difficulty == 'beginner') {
      exerciseCount = 4; // 4-5 exercises for beginners
    } else if (difficulty == 'intermediate') {
      exerciseCount = 5; // 5-6 exercises for intermediate
    } else {
      exerciseCount = 6; // 6-7 exercises for advanced
    }

    // Filter out warm-ups and cool-downs
    final mainExercises = availableExercises.where((e) =>
        !e.name.toLowerCase().contains('march') &&
        !e.name.toLowerCase().contains('stretch')).toList();

    // Select exercises ensuring variety
    final usedMuscleGroups = <String>{};
    int attempts = 0;
    while (selected.length < exerciseCount && attempts < 50) {
      final exercise = mainExercises[random.nextInt(mainExercises.length)];
      
      // Avoid too many exercises from same muscle group
      if (!usedMuscleGroups.contains(exercise.muscleGroup) ||
          usedMuscleGroups.length >= 3) {
        selected.add(exercise);
        usedMuscleGroups.add(exercise.muscleGroup);
      }
      attempts++;
    }

    // Always include cool-down/stretch
    final coolDowns = availableExercises.where((e) =>
        e.name.toLowerCase().contains('stretch')).toList();
    if (coolDowns.isNotEmpty && selected.length < exerciseCount + 1) {
      selected.add(coolDowns[random.nextInt(coolDowns.length)]);
    }

    return selected;
  }

  /// Calculate estimated duration for workout
  static int _calculateDuration(List<Exercise> exercises) {
    int totalSeconds = 0;

    for (final exercise in exercises) {
      if (exercise.sets != null && exercise.reps != null) {
        // Estimate: 2 seconds per rep, 30 seconds rest between sets
        final timePerSet = (exercise.reps! * 2) + exercise.restSeconds;
        totalSeconds += timePerSet * exercise.sets!;
      } else if (exercise.durationSec > 0) {
        totalSeconds += exercise.durationSec;
        if (exercise.sets != null) {
          totalSeconds += exercise.restSeconds * (exercise.sets! - 1);
        }
      }
    }

    // Add 5 minutes for warm-up and cool-down
    totalSeconds += 300;

    // Convert to minutes
    return (totalSeconds / 60).ceil();
  }

  /// Get plan name
  static String _getPlanName(String goal, String difficulty) {
    final goalName = goal == 'fat_loss'
        ? 'Fat Loss'
        : goal == 'medical'
            ? 'Medical'
            : goal == 'rehab'
                ? 'Rehabilitation'
                : 'Fat Loss';
    final difficultyName = difficulty[0].toUpperCase() + difficulty.substring(1);
    return '$goalName - $difficultyName Plan';
  }

  /// Get plan description
  static String _getPlanDescription(String goal, String difficulty) {
    if (goal == 'fat_loss') {
      return 'A $difficulty-level workout plan focused on burning calories and improving cardiovascular health.';
    } else if (goal == 'medical') {
      return 'A $difficulty-level plan designed with medical considerations in mind.';
    } else if (goal == 'rehab') {
      return 'A gentle $difficulty-level rehabilitation plan to improve mobility and reduce pain.';
    } else {
      return 'A $difficulty-level workout plan tailored to your goals.';
    }
  }

  /// Generate fallback plan if no exercises match
  static WorkoutPlan _generateFallbackPlan(
    String userGoal,
    String difficulty,
    int daysPerWeek,
  ) {
    final allExercises = ExerciseDatabaseService.getAllExercises();
    final beginnerExercises = allExercises
        .where((e) => e.difficulty == 'beginner' && e.goals.contains('rehab'))
        .toList();

    final workoutDays = <WorkoutDay>[];
    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    for (int i = 0; i < daysPerWeek; i++) {
      final day = _generateWorkoutDay(
        day: dayNames[i],
        workoutType: 'rehab',
        exercises: beginnerExercises,
        difficulty: 'beginner',
      );
      workoutDays.add(day);
    }

    return WorkoutPlan(
      planName: 'Safe Beginner Plan',
      goal: userGoal,
      difficulty: 'beginner',
      days: workoutDays,
      totalDuration: workoutDays.fold<int>(0, (sum, day) => sum + day.estimatedDuration),
      description: 'A safe beginner workout plan suitable for all fitness levels.',
    );
  }

  /// Get today's workout from plan
  static WorkoutDay? getTodayWorkout(WorkoutPlan plan) {
    final today = DateTime.now();
    final dayIndex = today.weekday - 1; // Monday = 0

    if (dayIndex < plan.days.length) {
      return plan.days[dayIndex];
    }

    // If plan has fewer days than current weekday, cycle through
    return plan.days[dayIndex % plan.days.length];
  }
}
