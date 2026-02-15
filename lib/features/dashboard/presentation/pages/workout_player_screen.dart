import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fitzee_new/core/constants/app_colors.dart';
import 'package:fitzee_new/core/models/exercise.dart';
import 'package:fitzee_new/core/services/workout_tracking_service.dart';
import 'package:fitzee_new/core/services/exercise_image_service.dart';
import 'package:fitzee_new/core/services/firestore_workout_service.dart';
import 'package:fitzee_new/core/services/local_storage_service.dart';
import 'package:fitzee_new/core/services/connectivity_service.dart';

class WorkoutPlayerScreen extends StatefulWidget {
  final WorkoutDay workoutDay;

  const WorkoutPlayerScreen({
    super.key,
    required this.workoutDay,
  });

  @override
  State<WorkoutPlayerScreen> createState() => _WorkoutPlayerScreenState();
}

class _WorkoutPlayerScreenState extends State<WorkoutPlayerScreen> {
  int _currentExerciseIndex = 0;
  int _currentSet = 1;
  int _currentRep = 0;
  int _timerSeconds = 0;
  bool _isResting = false;
  bool _isPaused = false;
  bool _isCompleted = false;
  Timer? _timer;
  DateTime? _startTime;
  final List<ExerciseCompletion> _completedExercises = [];
  WorkoutSession? _session;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _session = WorkoutTrackingService.createWorkoutSession(widget.workoutDay.day);
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused && !_isCompleted) {
        setState(() {
          _timerSeconds++;
        });
      }
    });
  }

  Exercise get _currentExercise => widget.workoutDay.exercises[_currentExerciseIndex];

  void _completeExercise() {
    final completion = ExerciseCompletion(
      exerciseId: _currentExercise.id,
      exerciseName: _currentExercise.name,
      setsCompleted: _currentExercise.sets,
      repsCompleted: _currentExercise.reps,
      durationCompleted: _currentExercise.durationSec > 0 ? _currentExercise.durationSec : null,
      isCompleted: true,
      completedAt: DateTime.now(),
    );

    _completedExercises.add(completion);

    // Move to next exercise or rest
    if (_currentExerciseIndex < widget.workoutDay.exercises.length - 1) {
      if (_currentExercise.restSeconds > 0 && _currentExercise.sets != null && _currentSet < _currentExercise.sets!) {
        // Rest between sets
        setState(() {
          _isResting = true;
          _currentSet++;
          _timerSeconds = 0;
        });
        Future.delayed(Duration(seconds: _currentExercise.restSeconds), () {
          if (mounted) {
            setState(() {
              _isResting = false;
            });
          }
        });
      } else {
        // Move to next exercise
        setState(() {
          _currentExerciseIndex++;
          _currentSet = 1;
          _currentRep = 0;
        });
      }
    } else {
      // Workout completed
      _finishWorkout();
    }
  }

  void _skipExercise() {
    if (_currentExerciseIndex < widget.workoutDay.exercises.length - 1) {
      setState(() {
        _currentExerciseIndex++;
        _currentSet = 1;
        _currentRep = 0;
        _isResting = false;
      });
    } else {
      _finishWorkout();
    }
  }

  void _finishWorkout() async {
    setState(() {
      _isCompleted = true;
      _isPaused = true;
    });

    _timer?.cancel();

    if (_session != null && _startTime != null) {
      final endTime = DateTime.now();
      final duration = endTime.difference(_startTime!).inMinutes;
      final estimatedCalories = (duration * 7).round(); // Rough estimate: 7 cal/min

      // Ask user for actual calories burned (and optional steps) before saving.
      final stats = await _showWorkoutStatsDialog(
        context: context,
        durationMinutes: duration,
        estimatedCalories: estimatedCalories,
      );

      // If user cancelled the dialog, still save the session locally with estimated calories,
      // but skip Firestore workout save.
      final caloriesBurned = stats?['caloriesBurned'] ?? estimatedCalories;
      final steps = stats?['steps'] ?? 0;

      final completedSession = WorkoutSession(
        id: _session!.id,
        workoutDayId: _session!.workoutDayId,
        startTime: _session!.startTime,
        endTime: endTime,
        completedExercises: _completedExercises,
        caloriesBurned: caloriesBurned,
        isCompleted: true,
      );

      await WorkoutTrackingService.saveWorkoutSession(completedSession);

      // Also store workout summary in Firestore workout collection: date, duration, calories burned, steps.
      try {
        final hasInternet = await ConnectivityService.hasInternetConnection();
        if (hasInternet) {
          final userId = await LocalStorageService.getUserId();
          if (userId != null && userId.isNotEmpty) {
            await FirestoreWorkoutService.saveWorkoutData(
              userId: userId,
              date: _session!.startTime,
              steps: steps,
              caloriesBurned: caloriesBurned,
              exerciseMinutes: duration,
            );
          }
        }
      } catch (e) {
        // Ignore Firestore errors; local session is still saved and streak updated.
      }
    }

    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  /// Dialog shown when workout is finished to capture user-confirmed
  /// calories burned and optional steps for Firestore workout logging.
  Future<Map<String, int>?> _showWorkoutStatsDialog({
    required BuildContext context,
    required int durationMinutes,
    required int estimatedCalories,
  }) async {
    final caloriesController =
        TextEditingController(text: estimatedCalories.toString());
    final stepsController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog<Map<String, int>?>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.backgroundDarkLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Workout Completed',
            style: TextStyle(
              color: AppColors.textWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Duration: $durationMinutes min',
                  style: const TextStyle(
                    color: AppColors.textGray,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: caloriesController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppColors.textWhite),
                  decoration: InputDecoration(
                    labelText: 'Calories burned',
                    labelStyle:
                        const TextStyle(color: AppColors.textGray),
                    hintText: estimatedCalories.toString(),
                    prefixIcon: const Icon(
                      Icons.local_fire_department,
                      color: AppColors.primaryGreen,
                      size: 20,
                    ),
                    suffixText: 'kcal',
                    suffixStyle:
                        const TextStyle(color: AppColors.textGray),
                    filled: true,
                    fillColor: AppColors.backgroundDark,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.borderGreen,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.borderGreen,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primaryGreen,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter calories burned';
                    }
                    final v = int.tryParse(value.trim());
                    if (v == null || v <= 0) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: stepsController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppColors.textWhite),
                  decoration: InputDecoration(
                    labelText: 'Steps during workout (optional)',
                    labelStyle:
                        const TextStyle(color: AppColors.textGray),
                    prefixIcon: const Icon(
                      Icons.directions_walk,
                      color: AppColors.primaryGreen,
                      size: 20,
                    ),
                    filled: true,
                    fillColor: AppColors.backgroundDark,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.borderGreen,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.borderGreen,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primaryGreen,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // User skips manual entry – use estimated calories and no steps.
                Navigator.of(dialogContext).pop(null);
              },
              child: const Text(
                'Skip',
                style: TextStyle(color: AppColors.textGray),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: AppColors.textBlack,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                final calories =
                    int.parse(caloriesController.text.trim());
                final stepsText = stepsController.text.trim();
                final steps =
                    stepsText.isEmpty ? 0 : int.tryParse(stepsText) ?? 0;
                Navigator.of(dialogContext).pop(<String, int>{
                  'caloriesBurned': calories,
                  'steps': steps,
                });
              },
              child: const Text(
                'Save',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isCompleted) {
      return _buildCompletionScreen();
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDarkBlueGreen,
      body: SafeArea(
        child: Column(
          children: [
            // Safety Disclaimer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.backgroundDarkLight,
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppColors.primaryGreen,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Stop if you feel pain. Consult a professional if needed.',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textGray,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
          children: [
            // Header with timer and controls
            _buildHeader(),
            // Exercise content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Exercise name and info
                    _buildExerciseInfo(),
                    const SizedBox(height: 24),
                    // Video placeholder (can be replaced with actual video player)
                    _buildVideoPlaceholder(),
                    const SizedBox(height: 24),
                    // Instructions
                    _buildInstructions(),
                    const SizedBox(height: 24),
                    // Progress indicator
                    _buildProgressIndicator(),
                  ],
                ),
              ),
            ),
            // Bottom controls
            _buildBottomControls(),
              ],
            ),
            ),],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundDarkLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.textWhite),
            onPressed: () {
              _showExitDialog();
            },
          ),
          Column(
            children: [
              Text(
                _formatTime(_timerSeconds),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
              Text(
                'Exercise ${_currentExerciseIndex + 1} of ${widget.workoutDay.exercises.length}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textGray,
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(
              _isPaused ? Icons.play_arrow : Icons.pause,
              color: AppColors.textWhite,
            ),
            onPressed: () {
              setState(() {
                _isPaused = !_isPaused;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _currentExercise.name,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textWhite,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _currentExercise.description,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textGray,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            if (_currentExercise.sets != null && _currentExercise.reps != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_currentExercise.sets} sets × ${_currentExercise.reps} reps',
                  style: const TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (_currentExercise.durationSec > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_currentExercise.durationSec}s',
                  style: const TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildVideoPlaceholder() {
    final imagePath = ExerciseImageService.getExerciseImage(_currentExercise);
    
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.backgroundDarkLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: imagePath != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  // Exercise image
                  Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback if image doesn't exist
                      return _buildPlaceholderContent();
                    },
                  ),
                  // Overlay gradient for better text visibility if needed
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                  // Video play button overlay if video is available
                  if (_currentExercise.videoUrl != null)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: AppColors.textBlack,
                          size: 40,
                        ),
                      ),
                    ),
                ],
              )
            : _buildPlaceholderContent(),
      ),
    );
  }

  Widget _buildPlaceholderContent() {
    return Container(
      color: AppColors.backgroundDarkLight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.fitness_center,
            size: 64,
            color: AppColors.primaryGreen,
          ),
          const SizedBox(height: 16),
          const Text(
            'Exercise Demonstration',
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Follow the instructions below',
            style: TextStyle(
              color: AppColors.textGray,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundDarkLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Instructions:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textWhite,
            ),
          ),
          const SizedBox(height: 12),
          ..._currentExercise.instructions.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${entry.key + 1}',
                        style: const TextStyle(
                          color: AppColors.textBlack,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Workout Progress',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textWhite,
              ),
            ),
            Text(
              '${_currentExerciseIndex + 1}/${widget.workoutDay.exercises.length}',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textGray,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: (_currentExerciseIndex + 1) / widget.workoutDay.exercises.length,
          backgroundColor: AppColors.textGray.withOpacity(0.2),
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildBottomControls() {
    if (_isResting) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.backgroundDarkLight,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Rest Time',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Set $_currentSet of ${_currentExercise.sets}',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textGray,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isResting = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: AppColors.textBlack,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Skip Rest',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundDarkLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _skipExercise,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.textGray),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Skip',
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _completeExercise,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: AppColors.textBlack,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _currentExerciseIndex == widget.workoutDay.exercises.length - 1
                    ? 'Finish Workout'
                    : 'Complete',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionScreen() {
    final duration = _startTime != null
        ? DateTime.now().difference(_startTime!).inMinutes
        : 0;
    final calories = (duration * 7).round();

    return Scaffold(
      backgroundColor: AppColors.backgroundDarkBlueGreen,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 64,
                    color: AppColors.textBlack,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Workout Completed!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textWhite,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Great job completing your workout',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textGray,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Duration', '${duration} min', Icons.timer),
                    _buildStatItem('Calories', '$calories', Icons.local_fire_department),
                    _buildStatItem('Exercises', '${_completedExercises.length}', Icons.fitness_center),
                  ],
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: AppColors.textBlack,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryGreen, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textWhite,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textGray,
          ),
        ),
      ],
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundDarkLight,
        title: const Text(
          'Exit Workout?',
          style: TextStyle(color: AppColors.textWhite),
        ),
        content: const Text(
          'Your progress will not be saved if you exit now.',
          style: TextStyle(color: AppColors.textGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textGray),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Exit workout
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
            ),
            child: const Text(
              'Exit',
              style: TextStyle(color: AppColors.textWhite),
            ),
          ),
        ],
      ),
    );
  }
}
