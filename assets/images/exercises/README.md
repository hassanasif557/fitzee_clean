# Exercise Images

This folder should contain images for each exercise in the workout app. Images should be in PNG format and named according to the exercise ID.

## Required Images

Place the following images in this folder:

### Warm-up Exercises
- `marching_in_place.png` - Marching in Place exercise
- `arm_circles.png` - Arm Circles exercise
- `neck_rolls.png` - Neck Rolls exercise

### Beginner Exercises
- `squat_bodyweight.png` - Bodyweight Squat
- `wall_pushup.png` - Wall Push-ups
- `standing_side_leg_raise.png` - Standing Side Leg Raise
- `glute_bridge.png` - Glute Bridge
- `plank.png` - Plank
- `bird_dog.png` - Bird Dog

### Intermediate Exercises
- `pushup.png` - Push-ups
- `lunges.png` - Lunges
- `mountain_climbers.png` - Mountain Climbers
- `burpees.png` - Burpees

### Advanced Exercises
- `jump_squats.png` - Jump Squats
- `pike_pushup.png` - Pike Push-ups

### Stretching/Cool-down
- `standing_quad_stretch.png` - Standing Quad Stretch
- `shoulder_stretch.png` - Shoulder Stretch
- `hamstring_stretch.png` - Hamstring Stretch

### Optional
- `default_exercise.png` - Default/placeholder image for exercises without specific images

## Image Guidelines

- **Format**: PNG (recommended) or JPG
- **Size**: Recommended 800x600px or similar aspect ratio (4:3 or 16:9)
- **Content**: Images should clearly show the exercise being performed
- **Style**: Use clear, well-lit images with good contrast
- **Background**: Transparent or solid color backgrounds work best

## Notes

- If an image is missing, the app will show a placeholder icon
- Images are automatically mapped to exercises based on their ID
- The mapping is handled by `ExerciseImageService` in the codebase
