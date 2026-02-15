/// Model for a single exercise
class Exercise {
  final String id;
  final String name;
  final String description;
  final String? videoUrl; // YouTube URL or local video path
  final String? imageAsset; // Local asset path for exercise image
  /// Duration in seconds (for timed exercises). For rep-based exercises, keep this as 0.
  final int durationSec;
  final int? reps; // Number of reps (if applicable)
  final int? sets; // Number of sets (if applicable)
  final List<String> goals; // ['fat_loss', 'muscle_gain', 'rehab']
  final List<String> medicalRestrictions; // Conditions that should AVOID this exercise
  final String difficulty; // 'beginner', 'intermediate', 'advanced'
  final List<String> equipment; // ['none', 'dumbbells', 'resistance_band', etc.]
  final String muscleGroup; // 'chest', 'legs', 'back', 'arms', 'core', 'full_body'
  final int restSeconds; // Rest time between sets
  final List<String> instructions; // Step-by-step instructions

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    this.videoUrl,
    this.imageAsset,
    this.durationSec = 0,
    this.reps,
    this.sets,
    required this.goals,
    required this.medicalRestrictions,
    required this.difficulty,
    required this.equipment,
    required this.muscleGroup,
    this.restSeconds = 30,
    required this.instructions,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'videoUrl': videoUrl,
      'imageAsset': imageAsset,
      'durationSec': durationSec,
      'reps': reps,
      'sets': sets,
      'goals': goals,
      'medicalRestrictions': medicalRestrictions,
      'difficulty': difficulty,
      'equipment': equipment,
      'muscleGroup': muscleGroup,
      'restSeconds': restSeconds,
      'instructions': instructions,
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      videoUrl: json['videoUrl'] as String?,
      imageAsset: json['imageAsset'] as String?,
      durationSec: json['durationSec'] as int? ?? 0,
      reps: json['reps'] as int?,
      sets: json['sets'] as int?,
      goals: (json['goals'] as List).map((e) => e as String).toList(),
      medicalRestrictions: (json['medicalRestrictions'] as List).map((e) => e as String).toList(),
      difficulty: json['difficulty'] as String,
      equipment: (json['equipment'] as List).map((e) => e as String).toList(),
      muscleGroup: json['muscleGroup'] as String,
      restSeconds: json['restSeconds'] as int? ?? 30,
      instructions: (json['instructions'] as List).map((e) => e as String).toList(),
    );
  }
}

/// Model for a single workout day
class WorkoutDay {
  final String day; // 'Monday', 'Day 1', etc.
  final String workoutType; // 'full_body', 'upper_body', 'lower_body', 'cardio', etc.
  final List<Exercise> exercises;
  final int estimatedDuration; // Total duration in minutes
  final int estimatedCalories; // Estimated calories burned

  WorkoutDay({
    required this.day,
    required this.workoutType,
    required this.exercises,
    required this.estimatedDuration,
    required this.estimatedCalories,
  });

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'workoutType': workoutType,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'estimatedDuration': estimatedDuration,
      'estimatedCalories': estimatedCalories,
    };
  }

  factory WorkoutDay.fromJson(Map<String, dynamic> json) {
    return WorkoutDay(
      day: json['day'] as String,
      workoutType: json['workoutType'] as String,
      exercises: (json['exercises'] as List)
          .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList(),
      estimatedDuration: json['estimatedDuration'] as int,
      estimatedCalories: json['estimatedCalories'] as int,
    );
  }
}

/// Model for a complete workout plan
class WorkoutPlan {
  final String planName;
  final String goal; // 'fat_loss', 'muscle_gain', 'rehab'
  final String difficulty; // 'beginner', 'intermediate', 'advanced'
  final List<WorkoutDay> days;
  final int totalDuration; // Total duration in minutes
  final String? description;

  WorkoutPlan({
    required this.planName,
    required this.goal,
    required this.difficulty,
    required this.days,
    required this.totalDuration,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'planName': planName,
      'goal': goal,
      'difficulty': difficulty,
      'days': days.map((d) => d.toJson()).toList(),
      'totalDuration': totalDuration,
      'description': description,
    };
  }

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) {
    return WorkoutPlan(
      planName: json['planName'] as String,
      goal: json['goal'] as String,
      difficulty: json['difficulty'] as String,
      days: (json['days'] as List)
          .map((d) => WorkoutDay.fromJson(d as Map<String, dynamic>))
          .toList(),
      totalDuration: json['totalDuration'] as int,
      description: json['description'] as String?,
    );
  }
}

/// Model for workout session tracking
class WorkoutSession {
  final String id;
  final String workoutDayId;
  final DateTime startTime;
  final DateTime? endTime;
  final List<ExerciseCompletion> completedExercises;
  final int? caloriesBurned;
  final bool isCompleted;

  WorkoutSession({
    required this.id,
    required this.workoutDayId,
    required this.startTime,
    this.endTime,
    required this.completedExercises,
    this.caloriesBurned,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workoutDayId': workoutDayId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'completedExercises': completedExercises.map((e) => e.toJson()).toList(),
      'caloriesBurned': caloriesBurned,
      'isCompleted': isCompleted,
    };
  }

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      id: json['id'] as String,
      workoutDayId: json['workoutDayId'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime'] as String) : null,
      completedExercises: (json['completedExercises'] as List)
          .map((e) => ExerciseCompletion.fromJson(e as Map<String, dynamic>))
          .toList(),
      caloriesBurned: json['caloriesBurned'] as int?,
      isCompleted: json['isCompleted'] as bool,
    );
  }
}

/// Model for tracking individual exercise completion
class ExerciseCompletion {
  final String exerciseId;
  final String exerciseName;
  final int? setsCompleted;
  final int? repsCompleted;
  final int? durationCompleted; // in seconds
  final bool isCompleted;
  final DateTime? completedAt;

  ExerciseCompletion({
    required this.exerciseId,
    required this.exerciseName,
    this.setsCompleted,
    this.repsCompleted,
    this.durationCompleted,
    this.isCompleted = false,
    this.completedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'setsCompleted': setsCompleted,
      'repsCompleted': repsCompleted,
      'durationCompleted': durationCompleted,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory ExerciseCompletion.fromJson(Map<String, dynamic> json) {
    return ExerciseCompletion(
      exerciseId: json['exerciseId'] as String,
      exerciseName: json['exerciseName'] as String,
      setsCompleted: json['setsCompleted'] as int?,
      repsCompleted: json['repsCompleted'] as int?,
      durationCompleted: json['durationCompleted'] as int?,
      isCompleted: json['isCompleted'] as bool,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
    );
  }
}
