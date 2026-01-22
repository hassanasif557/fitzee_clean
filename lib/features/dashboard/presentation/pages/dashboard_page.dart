import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitzee_new/core/constants/app_colors.dart';
import 'package:fitzee_new/core/services/local_storage_service.dart';
import 'package:fitzee_new/core/services/user_profile_service.dart';
import 'package:fitzee_new/core/services/health_score_service.dart';
import 'package:fitzee_new/core/services/daily_data_service.dart';
import 'package:fitzee_new/core/services/daily_nutrition_service.dart';
import 'package:fitzee_new/core/services/workout_generator_service.dart';
import 'package:fitzee_new/core/services/workout_tracking_service.dart';
import 'package:fitzee_new/core/models/food_nutrition.dart';
import 'package:fitzee_new/core/models/exercise.dart';
import 'package:fitzee_new/features/onboard/domain/entities/user_profile.dart';
import 'daily_data_collection_screen.dart';
import 'ai_chat_screen.dart';
import 'progress_report_screen.dart';
import 'meal_entry_screen.dart';
import 'workout_player_screen.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  UserProfile? _userProfile;
  Map<String, dynamic>? _healthScore;
  Map<String, dynamic>? _dailyData;
  FoodNutrition? _todayNutrition;
  WorkoutPlan? _workoutPlan;
  WorkoutDay? _todayWorkout;
  int _workoutStreak = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkDailyDataAndLoad();
  }

  Future<void> _checkDailyDataAndLoad() async {
    // Check if we need to collect daily data
    final hasYesterdayData = await DailyDataService.hasDataForYesterday();
    
    if (!hasYesterdayData && mounted) {
      // Show daily data collection screen
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DailyDataCollectionScreen(
            onComplete: () {
              // After data is collected, refresh dashboard
              _refreshData();
            },
          ),
        ),
      );
    }
    
    await _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = await LocalStorageService.getUserId();
      final profile = await UserProfileService.getUserProfile(userId);
      
      // Load daily data
      final yesterdayData = await DailyDataService.getYesterdayData();
      final averageData = await DailyDataService.getAverageData(7);
      
      // Load today's nutrition
      final todayNutrition = await DailyNutritionService.getTodayNutrition();
      
      // Generate or load workout plan
      WorkoutPlan? workoutPlan;
      final savedPlan = await WorkoutTrackingService.getWorkoutPlan();
      if (savedPlan != null) {
        workoutPlan = WorkoutPlan.fromJson(savedPlan);
      } else {
        // Generate new plan based on profile
        final daysPerWeek = profile?.trainingDaysPerWeek ?? profile?.exerciseFrequencyPerWeek ?? 3;
        workoutPlan = WorkoutGeneratorService.generateWorkoutPlan(
          profile: profile,
          daysPerWeek: daysPerWeek,
        );
        // Save the plan
        await WorkoutTrackingService.saveWorkoutPlan(workoutPlan.toJson());
      }
      
      final todayWorkout = WorkoutGeneratorService.getTodayWorkout(workoutPlan);
      final workoutStreak = await WorkoutTrackingService.getWorkoutStreak();
      
      // Calculate health score based on BMI (no AI calls)
      final healthScore = await HealthScoreService.calculateHealthScore(profile);

      setState(() {
        _userProfile = profile;
        _dailyData = yesterdayData ?? averageData;
        _todayNutrition = todayNutrition;
        _workoutPlan = workoutPlan;
        _todayWorkout = todayWorkout;
        _workoutStreak = workoutStreak;
        _healthScore = healthScore;
        _isLoading = false;
      });
    } catch (e) {
      print('Dashboard: Error loading data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundDarkLight,
        title: const Text(
          'Sign Out',
          style: TextStyle(
            color: AppColors.textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: AppColors.textGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textGray),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
            ),
            child: const Text(
              'Sign Out',
              style: TextStyle(color: AppColors.textWhite),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseAuth.instance.signOut();
        await LocalStorageService.clearAuthState();
        if (mounted) {
          context.go('/');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final userName = _userProfile?.name?.split(' ').first ?? 'User';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.backgroundDarkBlueGreen,
              AppColors.backgroundDarkBlueGreen.withOpacity(0.98),
              AppColors.backgroundDarkBlueGreen,
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryGreen,
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth < 360 ? 16 : 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'FITZEE AI',
                                  style: TextStyle(
                                    color: AppColors.primaryGreen,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Good Morning, $userName',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textWhite,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.refresh,
                                  color: AppColors.primaryGreen,
                                  size: 24,
                                ),
                                onPressed: _refreshData,
                                tooltip: 'Refresh Data',
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.leaderboard,
                                  color: AppColors.primaryGreen,
                                  size: 24,
                                ),
                                onPressed: () {
                                  context.push('/leaderboard');
                                },
                                tooltip: 'Leaderboard',
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.notifications_outlined,
                                  color: AppColors.textWhite,
                                  size: 28,
                                ),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Health Score
                      if (_healthScore != null) _buildHealthScoreCard(),
                      const SizedBox(height: 24),
                      // Daily Metrics
                      _buildDailyMetrics(),
                      const SizedBox(height: 24),
                      // Progress Report Button
                      _buildProgressReportButton(),
                      const SizedBox(height: 24),
                      // Nutrition Tracking
                      _buildNutritionCard(),
                      const SizedBox(height: 24),
                      // Today's Workout
                      if (_todayWorkout != null) _buildWorkoutCard(),
                      const SizedBox(height: 24),
                      // AI Coaching
                      if (_healthScore != null) _buildAICoachingCard(),
                      const SizedBox(height: 24),
                      // Update Daily Data Button
                      Center(
                        child: TextButton.icon(
                          onPressed: () async {
                            final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => DailyDataCollectionScreen(
                                  onComplete: () {
                                    _refreshData();
                                  },
                                ),
                              ),
                            );
                            if (result == true) {
                              _refreshData();
                            }
                          },
                          icon: const Icon(
                            Icons.edit_calendar,
                            color: AppColors.primaryGreen,
                          ),
                          label: const Text(
                            'Update Daily Data',
                            style: TextStyle(
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildHealthScoreCard() {
    final score = _healthScore!['score'] as int? ?? 85;
    final scoreLabel = _healthScore!['scoreLabel'] as String? ?? 'Good';
    final breakdown = _healthScore!['breakdown'] as Map<String, dynamic>? ?? {};
    final bmi = _healthScore!['bmi'] as double? ?? 0.0;
    final bmiCategory = _healthScore!['bmiCategory'] as String? ?? 'Unknown';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.backgroundDarkLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Circular Progress Indicator
          SizedBox(
            width: 150,
            height: 150,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 150,
                  height: 150,
                  child: CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 12,
                    backgroundColor: AppColors.textGray.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primaryGreen,
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$score',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textWhite,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      scoreLabel.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        color: _getScoreLabelColor(score),
                        letterSpacing: 1,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'HEALTH SCORE',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textGray,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (bmi > 0) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'BMI: ${bmi.toStringAsFixed(1)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    bmiCategory,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          // Breakdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBreakdownItem(
                'Fitness',
                breakdown['fitness'] ?? 70,
                breakdown['fitnessLabel'] as String?,
              ),
              _buildBreakdownItem(
                'Nutrition',
                breakdown['nutrition'] ?? 75,
                breakdown['nutritionLabel'] as String?,
              ),
              _buildBreakdownItem(
                'Recovery',
                breakdown['recovery'] ?? 80,
                breakdown['recoveryLabel'] as String?,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getScoreLabelColor(int score) {
    if (score >= 90) {
      return AppColors.primaryGreen;
    } else if (score >= 75) {
      return Colors.lightGreen;
    } else if (score >= 50) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Widget _buildBreakdownItem(String label, int value, String? labelText) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _getScoreLabelColor(value),
            ),
          ),
          if (labelText != null) ...[
            const SizedBox(height: 2),
            Text(
              labelText,
              style: TextStyle(
                fontSize: 9,
                color: _getScoreLabelColor(value),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyMetrics() {
    final steps = _dailyData?['steps'] ?? 0;
    final calories = _dailyData?['calories'] ?? 0;
    final sleep = _dailyData?['sleepHours'] ?? 0.0;
    
    String stepsText = steps >= 1000 
        ? '${(steps / 1000).toStringAsFixed(1)}k'
        : steps.toString();
    String sleepText = sleep > 0 
        ? '${sleep.toStringAsFixed(1)}h'
        : '0h';
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildMetricItem(stepsText, 'STEPS', Icons.directions_walk),
        _buildMetricItem('$calories', 'KCAL', Icons.local_fire_department),
        _buildMetricItem(sleepText, 'SLEEP', Icons.bedtime),
      ],
    );
  }

  Widget _buildMetricItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryGreen, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
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

  Widget _buildProgressReportButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ProgressReportScreen(),
            ),
          );
        },
        icon: const Icon(
          Icons.analytics,
          color: AppColors.textBlack,
        ),
        label: const Text(
          'View Progress Report',
          style: TextStyle(
            color: AppColors.textBlack,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionCard() {
    final calories = _todayNutrition?.calories ?? 0.0;
    final protein = _todayNutrition?.protein ?? 0.0;
    final carbs = _todayNutrition?.carbs ?? 0.0;
    final fat = _todayNutrition?.fat ?? 0.0;
    final recommendedCalories = _userProfile != null
        ? HealthScoreService.calculateRecommendedCalories(_userProfile)
        : 2000;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundDarkLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.restaurant,
                    color: AppColors.primaryGreen,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Today\'s Nutrition',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textWhite,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(
                  Icons.add_circle,
                  color: AppColors.primaryGreen,
                ),
                onPressed: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const MealEntryScreen(),
                    ),
                  );
                  if (result == true) {
                    _loadData();
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Calories Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Calories',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textGray,
                ),
              ),
              Text(
                '${calories.toStringAsFixed(0)} / $recommendedCalories kcal',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textWhite,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: recommendedCalories > 0 ? (calories / recommendedCalories).clamp(0.0, 1.0) : 0,
            backgroundColor: AppColors.textGray.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 20),
          // Macros
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMacroItem('Protein', '${protein.toStringAsFixed(1)}g', Icons.fitness_center),
              _buildMacroItem('Carbs', '${carbs.toStringAsFixed(1)}g', Icons.grain),
              _buildMacroItem('Fat', '${fat.toStringAsFixed(1)}g', Icons.water_drop),
            ],
          ),
          const SizedBox(height: 16),
          // View Details Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const MealEntryScreen(),
                  ),
                );
                if (result == true) {
                  _loadData();
                }
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryGreen),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Add Meal',
                style: TextStyle(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryGreen, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
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

  Widget _buildWorkoutCard() {
    if (_todayWorkout == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundDarkLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.fitness_center,
                    color: AppColors.primaryGreen,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Today\'s Workout',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textWhite,
                    ),
                  ),
                ],
              ),
              if (_workoutStreak > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                       Icon(
                        Icons.local_fire_department,
                        size: 16,
                        color: AppColors.primaryGreen,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$_workoutStreak',
                        style: const TextStyle(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _todayWorkout!.workoutType.toUpperCase().replaceAll('_', ' '),
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.timer, size: 16, color: AppColors.textGray),
              const SizedBox(width: 4),
              Text(
                '${_todayWorkout!.estimatedDuration} min',
                style: const TextStyle(
                  color: AppColors.textGray,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.local_fire_department, size: 16, color: AppColors.textGray),
              const SizedBox(width: 4),
              Text(
                '~${_todayWorkout!.estimatedCalories} kcal',
                style: const TextStyle(
                  color: AppColors.textGray,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${_todayWorkout!.exercises.length} exercises',
            style: const TextStyle(
              color: AppColors.textWhite,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => WorkoutPlayerScreen(
                      workoutDay: _todayWorkout!,
                    ),
                  ),
                ).then((completed) {
                  if (completed == true) {
                    _loadData(); // Refresh to update streak
                  }
                });
              },
              icon: const Icon(
                Icons.play_arrow,
                color: AppColors.textBlack,
              ),
              label: const Text(
                'Start Workout',
                style: TextStyle(
                  color: AppColors.textBlack,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAICoachingCard() {
    final recommendations = _healthScore!['recommendations'] as List? ?? [];
    final recommendation = recommendations.isNotEmpty
        ? recommendations[0] as String
        : 'Maintain your current routine and stay consistent.';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundDarkLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: AppColors.primaryGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'AI COACHING',
                style: TextStyle(
                  color: AppColors.primaryGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            recommendation,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textWhite,
            ),
          ),
          if (recommendations.length > 1) ...[
            const SizedBox(height: 12),
            Text(
              recommendations[1] as String? ?? '',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textGray,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AIChatScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: AppColors.textBlack,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Chat with AI'),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AIChatScreen(),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryGreen),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Details',
                  style: TextStyle(color: AppColors.textWhite),
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ],
      ),
    );
  }

}
