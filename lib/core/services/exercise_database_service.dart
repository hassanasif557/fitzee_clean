import 'package:fitzee_new/core/models/exercise.dart';

/// Service to manage exercise database
/// Contains pre-approved exercises with videos and safety information
class ExerciseDatabaseService {
  /// Get all exercises
  static List<Exercise> getAllExercises() {
    return _exerciseDatabase;
  }

  /// Get exercise by ID
  static Exercise? getExerciseById(String id) {
    try {
      return _exerciseDatabase.firstWhere((exercise) => exercise.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Search exercises by name
  static List<Exercise> searchExercises(String query) {
    final lowerQuery = query.toLowerCase();
    return _exerciseDatabase.where((exercise) {
      return exercise.name.toLowerCase().contains(lowerQuery) ||
          exercise.description.toLowerCase().contains(lowerQuery) ||
          exercise.muscleGroup.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Get exercises by goal
  static List<Exercise> getExercisesByGoal(String goal) {
    return _exerciseDatabase.where((exercise) => exercise.goals.contains(goal)).toList();
  }

  /// Get exercises by difficulty
  static List<Exercise> getExercisesByDifficulty(String difficulty) {
    return _exerciseDatabase.where((exercise) => exercise.difficulty == difficulty).toList();
  }

  /// Get exercises by muscle group
  static List<Exercise> getExercisesByMuscleGroup(String muscleGroup) {
    return _exerciseDatabase.where((exercise) => exercise.muscleGroup == muscleGroup).toList();
  }

  /// Get exercises that require no equipment
  static List<Exercise> getBodyweightExercises() {
    return _exerciseDatabase.where((exercise) => exercise.equipment.contains('none')).toList();
  }

  // Exercise Database - Pre-approved exercises with safety information
  // Video URLs can be YouTube links or local assets
  static final List<Exercise> _exerciseDatabase = [
    // Warm-up Exercises
    Exercise(
      id: 'marching_in_place',
      name: 'Marching in Place',
      description: 'Gentle warm-up exercise to increase heart rate',
      videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', // Replace with actual video
      durationSec: 60,
      goals: ['fat_loss', 'rehab'],
      medicalRestrictions: [],
      difficulty: 'beginner',
      equipment: ['none'],
      muscleGroup: 'full_body',
      restSeconds: 0,
      instructions: [
        'Stand tall with feet hip-width apart',
        'Lift your knees alternately as if marching',
        'Swing your arms naturally',
        'Keep a steady, comfortable pace',
      ],
    ),
    Exercise(
      id: 'arm_circles',
      name: 'Arm Circles',
      description: 'Warm-up for shoulders and upper body',
      videoUrl: null,
      durationSec: 30,
      goals: ['fat_loss', 'rehab'],
      medicalRestrictions: ['shoulder_injury'],
      difficulty: 'beginner',
      equipment: ['none'],
      muscleGroup: 'arms',
      restSeconds: 0,
      instructions: [
        'Stand with arms extended to the sides',
        'Make small circles with your arms',
        'Gradually increase circle size',
        'Reverse direction after 15 seconds',
      ],
    ),
    Exercise(
      id: 'neck_rolls',
      name: 'Neck Rolls',
      description: 'Gentle neck mobility exercise',
      videoUrl: null,
      durationSec: 30,
      goals: ['rehab'],
      medicalRestrictions: ['neck_injury'],
      difficulty: 'beginner',
      equipment: ['none'],
      muscleGroup: 'full_body',
      restSeconds: 0,
      instructions: [
        'Slowly roll your head in a circle',
        'Keep movements gentle and controlled',
        'Do not force any position',
      ],
    ),

    // Beginner Exercises
    Exercise(
      id: 'squat_bodyweight',
      name: 'Bodyweight Squat',
      description: 'Fundamental lower body exercise',
      videoUrl: null,
      reps: 12,
      sets: 3,
      goals: ['fat_loss', 'muscle_gain'],
      medicalRestrictions: ['knee_pain', 'lower_back_pain'],
      difficulty: 'beginner',
      equipment: ['none'],
      muscleGroup: 'legs',
      restSeconds: 30,
      instructions: [
        'Stand with feet shoulder-width apart',
        'Lower your body as if sitting in a chair',
        'Keep knees behind toes',
        'Push through heels to return to start',
      ], durationSec: 0,
    ),
    Exercise(
      id: 'wall_pushup',
      name: 'Wall Push-ups',
      description: 'Beginner-friendly upper body exercise',
      videoUrl: null,
      reps: 10,
      sets: 3,
      goals: ['fat_loss', 'muscle_gain', 'rehab'],
      medicalRestrictions: ['shoulder_injury'],
      difficulty: 'beginner',
      equipment: ['none'],
      muscleGroup: 'chest',
      restSeconds: 30,
      instructions: [
        'Stand facing a wall, arms extended',
        'Place hands on wall at shoulder height',
        'Bend elbows to bring chest toward wall',
        'Push back to starting position',
      ],durationSec: 0,
    ),
    Exercise(
      id: 'standing_side_leg_raise',
      name: 'Standing Side Leg Raise',
      description: 'Targets hip abductors and improves balance',
      videoUrl: null,
      reps: 12,
      sets: 3,
      goals: ['fat_loss', 'rehab'],
      medicalRestrictions: ['hip_injury'],
      difficulty: 'beginner',
      equipment: ['none'],
      muscleGroup: 'legs',
      restSeconds: 20,
      instructions: [
        'Stand holding onto a chair for support',
        'Lift one leg to the side',
        'Keep your body straight',
        'Lower leg slowly and repeat',
      ],durationSec: 0,
    ),
    Exercise(
      id: 'glute_bridge',
      name: 'Glute Bridge',
      description: 'Strengthens glutes and lower back',
      videoUrl: null,
      reps: 15,
      sets: 3,
      goals: ['muscle_gain', 'rehab'],
      medicalRestrictions: ['lower_back_pain'],
      difficulty: 'beginner',
      equipment: ['none'],
      muscleGroup: 'legs',
      restSeconds: 30,
      instructions: [
        'Lie on your back with knees bent',
        'Lift your hips off the ground',
        'Squeeze your glutes at the top',
        'Lower slowly and repeat',
      ],durationSec: 0,
    ),
    Exercise(
      id: 'plank',
      name: 'Plank',
      description: 'Core strengthening exercise',
      videoUrl: null,
      durationSec: 30,
      sets: 3,
      goals: ['fat_loss', 'muscle_gain'],
      medicalRestrictions: ['lower_back_pain', 'wrist_injury'],
      difficulty: 'beginner',
      equipment: ['none'],
      muscleGroup: 'core',
      restSeconds: 30,
      instructions: [
        'Start in push-up position',
        'Hold your body straight',
        'Engage your core',
        'Breathe normally',
      ],
    ),
    Exercise(
      id: 'bird_dog',
      name: 'Bird Dog',
      description: 'Core stability and balance exercise',
      videoUrl: null,
      reps: 10,
      sets: 3,
      goals: ['rehab', 'muscle_gain'],
      medicalRestrictions: ['lower_back_pain'],
      difficulty: 'beginner',
      equipment: ['none'],
      muscleGroup: 'core',
      restSeconds: 20,
      instructions: [
        'Start on hands and knees',
        'Extend opposite arm and leg',
        'Hold for 2 seconds',
        'Return and switch sides',
      ],durationSec: 0,
    ),

    // Intermediate Exercises
    Exercise(
      id: 'pushup',
      name: 'Push-ups',
      description: 'Classic upper body exercise',
      videoUrl: null,
      reps: 12,
      sets: 3,
      goals: ['fat_loss', 'muscle_gain'],
      medicalRestrictions: ['shoulder_injury', 'wrist_injury'],
      difficulty: 'intermediate',
      equipment: ['none'],
      muscleGroup: 'chest',
      restSeconds: 45,
      instructions: [
        'Start in plank position',
        'Lower body until chest nearly touches floor',
        'Push back up to starting position',
        'Keep body straight throughout',
      ],durationSec: 0,
    ),
    Exercise(
      id: 'lunges',
      name: 'Lunges',
      description: 'Lower body strength and balance',
      videoUrl: null,
      reps: 12,
      sets: 3,
      goals: ['fat_loss', 'muscle_gain'],
      medicalRestrictions: ['knee_pain'],
      difficulty: 'intermediate',
      equipment: ['none'],
      muscleGroup: 'legs',
      restSeconds: 30,
      instructions: [
        'Step forward into a lunge position',
        'Lower back knee toward ground',
        'Push through front heel to return',
        'Alternate legs',
      ],durationSec: 0,
    ),
    Exercise(
      id: 'mountain_climbers',
      name: 'Mountain Climbers',
      description: 'Cardio and core exercise',
      videoUrl: null,
      durationSec: 30,
      sets: 3,
      goals: ['fat_loss'],
      medicalRestrictions: ['wrist_injury', 'shoulder_injury', 'knee_pain'],
      difficulty: 'intermediate',
      equipment: ['none'],
      muscleGroup: 'full_body',
      restSeconds: 30,
      instructions: [
        'Start in plank position',
        'Alternate bringing knees to chest',
        'Keep core engaged',
        'Maintain steady pace',
      ],
    ),
    Exercise(
      id: 'burpees',
      name: 'Burpees',
      description: 'Full-body cardio exercise',
      videoUrl: null,
      reps: 8,
      sets: 3,
      goals: ['fat_loss'],
      medicalRestrictions: ['knee_pain', 'lower_back_pain', 'wrist_injury', 'heart_conditions'],
      difficulty: 'intermediate',
      equipment: ['none'],
      muscleGroup: 'full_body',
      restSeconds: 60,
      instructions: [
        'Start standing, squat down',
        'Jump back to plank position',
        'Do a push-up (optional)',
        'Jump feet forward and jump up',
      ],durationSec: 0,
    ),

    // Advanced Exercises
    Exercise(
      id: 'jump_squats',
      name: 'Jump Squats',
      description: 'Explosive lower body exercise',
      videoUrl: null,
      reps: 10,
      sets: 3,
      goals: ['fat_loss', 'muscle_gain'],
      medicalRestrictions: ['knee_pain', 'lower_back_pain', 'heart_conditions'],
      difficulty: 'advanced',
      equipment: ['none'],
      muscleGroup: 'legs',
      restSeconds: 60,
      instructions: [
        'Perform a regular squat',
        'Explode upward into a jump',
        'Land softly and immediately go into next squat',
        'Keep knees aligned',
      ],durationSec: 0,
    ),
    Exercise(
      id: 'pike_pushup',
      name: 'Pike Push-ups',
      description: 'Shoulder and upper body strength',
      videoUrl: null,
      reps: 10,
      sets: 3,
      goals: ['muscle_gain'],
      medicalRestrictions: ['shoulder_injury', 'wrist_injury'],
      difficulty: 'advanced',
      equipment: ['none'],
      muscleGroup: 'arms',
      restSeconds: 45,
      instructions: [
        'Start in downward dog position',
        'Lower head toward hands',
        'Push back up',
        'Keep legs straight',
      ],durationSec: 0,
    ),

    // Stretching/Cool-down
    Exercise(
      id: 'standing_quad_stretch',
      name: 'Standing Quad Stretch',
      description: 'Stretches front of thigh',
      videoUrl: null,
      durationSec: 30,
      goals: ['rehab'],
      medicalRestrictions: ['knee_pain'],
      difficulty: 'beginner',
      equipment: ['none'],
      muscleGroup: 'legs',
      restSeconds: 0,
      instructions: [
        'Stand and hold onto a wall for support',
        'Bend one knee and grab your foot',
        'Pull heel toward glutes',
        'Hold and switch sides',
      ],
    ),
    Exercise(
      id: 'shoulder_stretch',
      name: 'Shoulder Stretch',
      description: 'Stretches shoulders and chest',
      videoUrl: null,
      durationSec: 30,
      goals: ['rehab'],
      medicalRestrictions: ['shoulder_injury'],
      difficulty: 'beginner',
      equipment: ['none'],
      muscleGroup: 'arms',
      restSeconds: 0,
      instructions: [
        'Extend one arm across your body',
        'Use other arm to gently pull',
        'Hold the stretch',
        'Switch arms',
      ],
    ),
    Exercise(
      id: 'hamstring_stretch',
      name: 'Hamstring Stretch',
      description: 'Stretches back of thigh',
      videoUrl: null,
      durationSec: 30,
      goals: ['rehab'],
      medicalRestrictions: ['lower_back_pain'],
      difficulty: 'beginner',
      equipment: ['none'],
      muscleGroup: 'legs',
      restSeconds: 0,
      instructions: [
        'Sit with one leg extended',
        'Lean forward gently',
        'Feel stretch in back of thigh',
        'Hold and switch legs',
      ],
    ),
  ];
}
