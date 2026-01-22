import 'package:fitzee_new/core/models/exercise.dart';

/// Service to map exercise IDs to their corresponding image assets
/// This provides a centralized way to manage exercise images
class ExerciseImageService {
  /// Get the image asset path for an exercise
  /// Returns null if no image is available
  static String? getExerciseImage(Exercise exercise) {
    // First check if exercise has an explicit imageAsset
    if (exercise.imageAsset != null && exercise.imageAsset!.isNotEmpty) {
      return exercise.imageAsset;
    }

    // Fallback to mapping by exercise ID
    return _exerciseImageMap[exercise.id];
  }

  /// Map of exercise IDs to their image asset paths
  /// Images should be placed in assets/images/exercises/
  static final Map<String, String> _exerciseImageMap = {
    // Warm-up Exercises
    'marching_in_place': 'assets/images/exercises/marching_in_place.png',
    'arm_circles': 'assets/images/exercises/arm_circles.png',
    'neck_rolls': 'assets/images/exercises/neck_rolls.png',

    // Beginner Exercises
    'squat_bodyweight': 'assets/images/exercises/squat_bodyweight.png',
    'wall_pushup': 'assets/images/exercises/wall_pushup.png',
    'standing_side_leg_raise': 'assets/images/exercises/standing_side_leg_raise.png',
    'glute_bridge': 'assets/images/exercises/glute_bridge.png',
    'plank': 'assets/images/exercises/plank.png',
    'bird_dog': 'assets/images/exercises/bird_dog.png',

    // Intermediate Exercises
    'pushup': 'assets/images/exercises/pushup.png',
    'lunges': 'assets/images/exercises/lunges.png',
    'mountain_climbers': 'assets/images/exercises/mountain_climbers.png',
    'burpees': 'assets/images/exercises/burpees.png',

    // Advanced Exercises
    'jump_squats': 'assets/images/exercises/jump_squats.png',
    'pike_pushup': 'assets/images/exercises/pike_pushup.png',

    // Stretching/Cool-down
    'standing_quad_stretch': 'assets/images/exercises/standing_quad_stretch.png',
    'shoulder_stretch': 'assets/images/exercises/shoulder_stretch.png',
    'hamstring_stretch': 'assets/images/exercises/hamstring_stretch.png',
  };

  /// Get a default/placeholder image path for exercises without specific images
  /// This can be used as a fallback
  static String getDefaultExerciseImage() {
    return 'assets/images/exercises/default_exercise.png';
  }

  /// Check if an image exists for an exercise
  static bool hasImage(Exercise exercise) {
    final imagePath = getExerciseImage(exercise);
    return imagePath != null;
  }
}
