import 'package:fitzee_new/core/models/exercise.dart';
import 'package:fitzee_new/features/onboard/domain/entities/user_profile.dart';

/// Rules engine for filtering exercises based on user profile
/// NO AI - Pure rule-based filtering for safety
class WorkoutRulesEngine {
  /// Filter exercises based on user profile and constraints
  static List<Exercise> filterExercises({
    required List<Exercise> allExercises,
    required String goal,
    required String difficulty,
    required UserProfile? profile,
  }) {
    // Get medical restrictions from profile
    final medicalIssues = _getMedicalIssues(profile);

    return allExercises.where((exercise) {
      // Rule 1: Must match goal
      if (!exercise.goals.contains(goal)) {
        return false;
      }

      // Rule 2: Must match difficulty level
      if (exercise.difficulty != difficulty) {
        return false;
      }

      // Rule 3: Exclude exercises with medical restrictions
      for (final restriction in exercise.medicalRestrictions) {
        if (medicalIssues.contains(restriction)) {
          return false;
        }
      }

      // Rule 4: Additional safety checks
      if (!_isExerciseSafe(exercise, profile)) {
        return false;
      }

      return true;
    }).toList();
  }

  /// Get medical issues from user profile
  static List<String> _getMedicalIssues(UserProfile? profile) {
    final issues = <String>[];

    if (profile == null) {
      return issues;
    }

    // Map profile medical conditions to exercise restrictions
    if (profile.hasHeartConditions == true) {
      issues.add('heart_conditions');
    }
    if (profile.hasAsthma == true) {
      issues.add('asthma');
    }
    if (profile.hasActiveInjuries == true) {
      // Add common injury restrictions
      issues.add('knee_pain');
      issues.add('lower_back_pain');
      issues.add('shoulder_injury');
    }
    if (profile.hasChronicPain == true) {
      issues.add('lower_back_pain');
    }
    if (profile.hasRecentSurgeries == true) {
      issues.add('knee_pain');
      issues.add('lower_back_pain');
      issues.add('shoulder_injury');
    }
    if (profile.isPregnant == true) {
      issues.add('knee_pain');
      issues.add('lower_back_pain');
    }

    return issues;
  }

  /// Additional safety checks for exercises
  static bool _isExerciseSafe(Exercise exercise, UserProfile? profile) {
    if (profile == null) {
      return true;
    }

    // Rule: No high-intensity exercises for heart conditions
    if (profile.hasHeartConditions == true) {
      final highIntensityExercises = ['burpees', 'jump_squats', 'mountain_climbers'];
      if (highIntensityExercises.contains(exercise.id)) {
        return false;
      }
    }

    // Rule: No heavy impact for recent surgeries
    if (profile.hasRecentSurgeries == true) {
      final highImpactExercises = ['jump_squats', 'burpees'];
      if (highImpactExercises.contains(exercise.id)) {
        return false;
      }
    }

    // Rule: No exercises requiring balance for certain conditions
    if (profile.hasActiveInjuries == true) {
      // Could add more specific checks here
    }

    return true;
  }

  /// Get recommended difficulty based on user profile
  static String getRecommendedDifficulty(UserProfile? profile) {
    if (profile == null) {
      return 'beginner';
    }

    // Check for conditions that require beginner level
    if (profile.hasActiveInjuries == true ||
        profile.hasRecentSurgeries == true ||
        profile.hasHeartConditions == true ||
        profile.isPregnant == true) {
      return 'beginner';
    }

    // Check exercise frequency to determine level
    final exerciseFrequency = profile.exerciseFrequencyPerWeek ?? 0;
    if (exerciseFrequency >= 5) {
      return 'advanced';
    } else if (exerciseFrequency >= 3) {
      return 'intermediate';
    } else {
      return 'beginner';
    }
  }

  /// Balance muscle groups in workout
  static List<Exercise> balanceMuscleGroups(List<Exercise> exercises) {
    final muscleGroupCount = <String, int>{};
    final balanced = <Exercise>[];

    // Count exercises per muscle group
    for (final exercise in exercises) {
      muscleGroupCount[exercise.muscleGroup] =
          (muscleGroupCount[exercise.muscleGroup] ?? 0) + 1;
    }

    // Prioritize exercises from underrepresented muscle groups
    final sortedExercises = List<Exercise>.from(exercises);
    sortedExercises.sort((a, b) {
      final countA = muscleGroupCount[a.muscleGroup] ?? 0;
      final countB = muscleGroupCount[b.muscleGroup] ?? 0;
      return countA.compareTo(countB);
    });

    return sortedExercises;
  }

  /// Get workout type based on goal and day
  static String getWorkoutType(String goal, int dayIndex, int totalDays) {
    if (goal == 'rehab') {
      return 'rehab';
    }

    // Alternate between full body, upper, lower for variety
    if (totalDays <= 3) {
      return 'full_body'; // For 3 days or less, do full body
    }

    // For more days, alternate
    final pattern = dayIndex % 3;
    switch (pattern) {
      case 0:
        return 'full_body';
      case 1:
        return 'upper_body';
      case 2:
        return 'lower_body';
      default:
        return 'full_body';
    }
  }

  /// Filter exercises by workout type
  static List<Exercise> filterByWorkoutType(
    List<Exercise> exercises,
    String workoutType,
  ) {
    if (workoutType == 'full_body') {
      return exercises; // Include all
    } else if (workoutType == 'upper_body') {
      return exercises.where((e) =>
          ['chest', 'arms', 'back'].contains(e.muscleGroup)).toList();
    } else if (workoutType == 'lower_body') {
      return exercises.where((e) =>
          ['legs', 'core'].contains(e.muscleGroup)).toList();
    } else if (workoutType == 'cardio') {
      return exercises.where((e) =>
          e.goals.contains('fat_loss') && e.muscleGroup == 'full_body').toList();
    } else if (workoutType == 'rehab') {
      return exercises.where((e) =>
          e.goals.contains('rehab')).toList();
    }

    return exercises;
  }
}
