import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitzee_new/core/models/exercise.dart';
import 'package:fitzee_new/core/services/exercise_database_service.dart';
import 'package:fitzee_new/core/services/workout_rules_engine.dart';
import 'package:fitzee_new/features/onboard/domain/entities/user_profile.dart';

/// Response from the generateWorkoutPlan callable.
class AiWorkoutPlanResponse {
  final String goal;
  final String difficulty;
  final List<AiWorkoutDay> days;

  const AiWorkoutPlanResponse({
    required this.goal,
    required this.difficulty,
    required this.days,
  });

  factory AiWorkoutPlanResponse.fromJson(Map<String, dynamic> json) {
    final daysList = json['days'] as List<dynamic>? ?? [];
    return AiWorkoutPlanResponse(
      goal: json['goal'] as String? ?? 'fat_loss',
      difficulty: json['difficulty'] as String? ?? 'beginner',
      days: daysList
          .map((d) => AiWorkoutDay.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AiWorkoutDay {
  final String day;
  final String workoutType;
  final List<String> exerciseIds;

  const AiWorkoutDay({
    required this.day,
    required this.workoutType,
    required this.exerciseIds,
  });

  factory AiWorkoutDay.fromJson(Map<String, dynamic> json) {
    final ids = json['exerciseIds'] as List<dynamic>? ?? [];
    return AiWorkoutDay(
      day: json['day'] as String? ?? 'Day 1',
      workoutType: json['workoutType'] as String? ?? 'full_body',
      exerciseIds: ids.map((e) => e.toString()).toList(),
    );
  }
}

/// Calls Firebase callable to get AI-suggested workout plan (exercise IDs per day).
/// Caller should resolve IDs to [Exercise] and build [WorkoutPlan] with duration/calories.
class AiWorkoutService {
  /// Build medical conditions list for API from [UserProfile].
  static List<String> medicalConditionsFromProfile(UserProfile? profile) {
    final list = <String>[];
    if (profile == null) return list;
    if (profile.hasHeartConditions == true) list.add('heart_conditions');
    if (profile.hasAsthma == true) list.add('asthma');
    if (profile.hasActiveInjuries == true) {
      list.addAll(['knee_pain', 'lower_back_pain', 'shoulder_injury']);
    }
    if (profile.hasChronicPain == true) list.add('lower_back_pain');
    if (profile.hasRecentSurgeries == true) {
      list.addAll(['knee_pain', 'lower_back_pain', 'shoulder_injury']);
    }
    if (profile.isPregnant == true) {
      list.addAll(['knee_pain', 'lower_back_pain']);
    }
    if (profile.medicalProfile != null) {
      for (final c in profile.medicalProfile!.conditions) {
        if (c != 'none' && !list.any((x) => x.toLowerCase() == c.toLowerCase())) {
          list.add(c);
        }
      }
    }
    return list;
  }

  /// Get minimal exercise list for the AI (id, name, goals, difficulty, medicalRestrictions, muscleGroup).
  static List<Map<String, dynamic>> getAvailableExercisesForApi() {
    final all = ExerciseDatabaseService.getAllExercises();
    return all
        .map((e) => {
              'id': e.id,
              'name': e.name,
              'goals': e.goals,
              'difficulty': e.difficulty,
              'medicalRestrictions': e.medicalRestrictions,
              'muscleGroup': e.muscleGroup,
            })
        .toList();
  }

  /// Call backend to get AI-suggested plan. Returns null on error.
  static Future<AiWorkoutPlanResponse?> generateWorkoutPlan({
    required UserProfile? profile,
    required int daysPerWeek,
  }) async {
    final auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    if (user == null) return null;

    try {
      await user.getIdToken(true);
    } catch (_) {
      return null;
    }

    final goal = profile?.userType ?? profile?.goal ?? 'fat_loss';
    final apiGoal = goal == 'medical' ? 'fat_loss' : goal;
    final difficulty = WorkoutRulesEngine.getRecommendedDifficulty(profile);
    final medicalConditions = medicalConditionsFromProfile(profile);
    final availableExercises = getAvailableExercisesForApi();

    try {
      final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
      final callable = functions.httpsCallable(
        'generateWorkoutPlan',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 45)),
      );

      final result = await callable.call({
        'goal': apiGoal,
        'difficulty': difficulty,
        'daysPerWeek': daysPerWeek,
        'medicalConditions': medicalConditions,
        'availableExercises': availableExercises,
      });

      Map<String, dynamic> data;
      if (result.data is String) {
        try {
          data = Map<String, dynamic>.from(
            jsonDecode(result.data as String) as Map,
          );
        } catch (_) {
          return null;
        }
      } else {
        data = Map<String, dynamic>.from(result.data as Map);
      }

      return AiWorkoutPlanResponse.fromJson(data);
    } catch (e) {
      print('AiWorkoutService.generateWorkoutPlan error: $e');
      return null;
    }
  }

  /// Convert AI response + exercise database into a [WorkoutPlan].
  /// Fills in full [Exercise] objects, estimated duration and calories.
  static WorkoutPlan? buildPlanFromAiResponse(
    AiWorkoutPlanResponse response,
    String userGoal,
  ) {
    final dayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    final workoutDays = <WorkoutDay>[];

    for (final aiDay in response.days) {
      final exercises = <Exercise>[];
      for (final id in aiDay.exerciseIds) {
        final ex = ExerciseDatabaseService.getExerciseById(id);
        if (ex != null) exercises.add(ex);
      }
      if (exercises.isEmpty) continue;

      final estimatedDuration = _estimateDuration(exercises);
      final caloriesPerMin = response.difficulty == 'advanced'
          ? 10
          : (response.difficulty == 'intermediate' ? 7 : 5);
      final estimatedCalories = estimatedDuration * caloriesPerMin;

      workoutDays.add(WorkoutDay(
        day: aiDay.day,
        workoutType: aiDay.workoutType,
        exercises: exercises,
        estimatedDuration: estimatedDuration,
        estimatedCalories: estimatedCalories,
      ));
    }

    if (workoutDays.isEmpty) return null;

    final planName = _planName(userGoal, response.difficulty);
    final totalDuration =
        workoutDays.fold<int>(0, (sum, d) => sum + d.estimatedDuration);

    return WorkoutPlan(
      planName: planName,
      goal: userGoal,
      difficulty: response.difficulty,
      days: workoutDays,
      totalDuration: totalDuration,
      description: _planDescription(userGoal, response.difficulty),
    );
  }

  static int _estimateDuration(List<Exercise> exercises) {
    int totalSeconds = 0;
    for (final e in exercises) {
      if (e.sets != null && e.reps != null) {
        final timePerSet = (e.reps! * 2) + e.restSeconds;
        totalSeconds += timePerSet * e.sets!;
      } else if (e.durationSec > 0) {
        totalSeconds += e.durationSec;
        if (e.sets != null) {
          totalSeconds += e.restSeconds * (e.sets! - 1);
        }
      }
    }
    totalSeconds += 300; // warm-up/cool-down
    return (totalSeconds / 60).ceil();
  }

  static String _planName(String goal, String difficulty) {
    final g = goal == 'fat_loss'
        ? 'Fat Loss'
        : goal == 'medical'
            ? 'Medical'
            : goal == 'rehab'
                ? 'Rehabilitation'
                : 'Fat Loss';
    final d = difficulty.isNotEmpty
        ? difficulty[0].toUpperCase() + difficulty.substring(1)
        : 'Beginner';
    return '$g - $d Plan';
  }

  static String _planDescription(String goal, String difficulty) {
    if (goal == 'fat_loss') {
      return 'A $difficulty-level workout plan focused on burning calories and improving cardiovascular health.';
    }
    if (goal == 'medical') {
      return 'A $difficulty-level plan designed with medical considerations in mind.';
    }
    if (goal == 'rehab') {
      return 'A gentle $difficulty-level rehabilitation plan to improve mobility and reduce pain.';
    }
    return 'A $difficulty-level workout plan tailored to your goals.';
  }
}
