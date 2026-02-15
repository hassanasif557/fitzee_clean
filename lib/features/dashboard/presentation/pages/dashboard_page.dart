import 'package:flutter/material.dart';
import 'package:fitzee_new/core/models/daily_meal_plan.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitzee_new/core/constants/app_colors.dart';
import 'package:fitzee_new/core/constants/theme_ext.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitzee_new/core/models/food_nutrition.dart';
import 'package:fitzee_new/core/models/medical_entry.dart';
import 'package:fitzee_new/core/models/exercise.dart';
import 'package:fitzee_new/core/services/health_score_service.dart';
import 'package:fitzee_new/features/dashboard/presentation/core/di/dashboard_di.dart';
import 'package:fitzee_new/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:fitzee_new/features/dashboard/presentation/cubit/dashboard_state.dart';
import 'package:fitzee_new/features/onboard/domain/entities/user_profile.dart';
import 'daily_data_collection_screen.dart';
import 'ai_chat_screen.dart';
import 'progress_report_screen.dart';
import 'meal_entry_screen.dart';
import 'medical_entry_screen.dart';
import 'workout_player_screen.dart';
import 'meal_plan_detail_page.dart';
import '../widgets/dashboard_nav_panel.dart';

/// Main dashboard screen: health score, daily metrics, nutrition, medical, workout, AI coaching.
/// Uses [DashboardCubit] for all data and auth actions (Clean Architecture + Bloc/Cubit).
/// State comes only from [BlocBuilder] / [BlocListener]; no local business logic or service calls.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  /// Cubit is created via DI so it receives use cases (Clean Architecture).
  late final DashboardCubit _cubit = DashboardDi.createCubit();

  @override
  void initState() {
    super.initState();
    _cubit.checkDailyDataAndLoad();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  /// Shows sign-out confirmation; on confirm, delegates to [DashboardCubit.signOut].
  /// Navigation and cleanup are handled by the cubit and [BlocListener].
  Future<void> _signOut() async {
    final theme = Theme.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          'dashboard.sign_out'.tr(),
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'dashboard.sign_out_confirm'.tr(),
          style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'common.cancel'.tr(),
              style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
            ),
            child: Text(
              'dashboard.sign_out'.tr(),
              style: const TextStyle(color: AppColors.textWhite),
            ),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await _cubit.signOut();
    }
  }

  /// Shows delete-account confirmation; on confirm, delegates to [DashboardCubit.deleteAccount].
  /// Redirects to sign-in explicitly after success so redirect is reliable (listener is backup).
  Future<void> _deleteAccount() async {
    final theme = Theme.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          'dashboard.delete_account'.tr(),
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'dashboard.delete_account_confirm'.tr(),
          style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'common.cancel'.tr(),
              style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
            ),
            child: Text(
              'dashboard.delete_account'.tr(),
              style: const TextStyle(color: AppColors.textWhite),
            ),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    await _cubit.deleteAccount();
    if (!mounted) return;
    // Redirect to sign-in immediately after delete (don't rely only on BlocListener).
    if (_cubit.state.deleteAccountSuccess && context.mounted) {
      context.go('/phone_auth');
    }
  }

  void _openNavPanel() {
    final navContext = context;
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (dialogContext) => DashboardNavPanel(
        navigatorContext: navContext,
        onClose: () => Navigator.of(dialogContext).pop(),
        onSignOut: _signOut,
        onDeleteAccount: _deleteAccount,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: MultiBlocListener(
        listeners: [
          // Navigate to sign-in when sign-out or delete-account succeeds.
          BlocListener<DashboardCubit, DashboardState>(
            listenWhen: (prev, next) =>
                prev.signOutSuccess != next.signOutSuccess ||
                prev.deleteAccountSuccess != next.deleteAccountSuccess,
            listener: (context, state) {
              if ((state.signOutSuccess || state.deleteAccountSuccess) &&
                  context.mounted) {
                context.go('/phone_auth');
              }
            },
          ),
          // Show SnackBar when sign-out or delete-account fails.
          BlocListener<DashboardCubit, DashboardState>(
            listenWhen: (prev, next) => prev.authError != next.authError,
            listener: (context, state) {
              if (state.authError != null &&
                  state.authError!.isNotEmpty &&
                  context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.authError!),
                    backgroundColor: AppColors.errorRed,
                  ),
                );
              }
            },
          ),
          // When daily data is needed, open daily data collection screen.
          BlocListener<DashboardCubit, DashboardState>(
            listenWhen: (prev, next) =>
                prev.needsDailyDataCollection != next.needsDailyDataCollection,
            listener: (context, state) async {
              if (state.needsDailyDataCollection && mounted) {
                _cubit.clearDailyDataCollectionFlag();
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => DailyDataCollectionScreen(
                      onComplete: () => _cubit.refresh(),
                    ),
                  ),
                );
                if (result == true && mounted) {
                  _cubit.refresh();
                }
              }
            },
          ),
        ],
        child: BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, state) {
            final screenWidth = MediaQuery.of(context).size.width;
            final userName = state.userProfile?.name?.split(' ').first ?? 'User';

            return Scaffold(
              backgroundColor: context.themeScaffoldBg,
              body: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      context.themeScaffoldBg,
                      context.themeScaffoldBg.withValues(alpha: 0.98),
                      context.themeScaffoldBg,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: state.isLoading
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
                              // Header: app name, greeting, refresh / leaderboard / menu
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                        onPressed: _cubit.refresh,
                                        tooltip: 'Refresh Data',
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.leaderboard,
                                          color: AppColors.primaryGreen,
                                          size: 24,
                                        ),
                                        onPressed: () => context.push('/leaderboard'),
                                        tooltip: 'Leaderboard',
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.menu_rounded,
                                          color: AppColors.textWhite,
                                          size: 28,
                                        ),
                                        onPressed: _openNavPanel,
                                        tooltip: 'Menu',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              if (state.healthScore != null)
                                _buildHealthScoreCard(state.healthScore!),
                              const SizedBox(height: 24),
                              _buildDailyMetrics(state.dailyData),
                              const SizedBox(height: 24),
                              _buildProgressReportButton(),
                              const SizedBox(height: 24),
                              _buildNutritionCard(
                                  state.todayNutrition, state.userProfile),
                              const SizedBox(height: 24),
                              if (state.dailyMealPlan != null &&
                                  state.dailyMealPlan!.hasAnyMeal)
                                _buildDailyMealPlanSection(state.dailyMealPlan!),
                              if (state.isLoadingAI &&
                                  (state.dailyMealPlan == null ||
                                      !state.dailyMealPlan!.hasAnyMeal))
                                _buildMealPlanLoadingPlaceholder(),
                              if (state.dailyMealPlan != null &&
                                  state.dailyMealPlan!.hasAnyMeal)
                                const SizedBox(height: 24),
                              if (state.isLoadingAI &&
                                  (state.dailyMealPlan == null ||
                                      !state.dailyMealPlan!.hasAnyMeal))
                                const SizedBox(height: 24),
                              _buildMedicalInfoCard(state.todayMedicalEntries),
                              const SizedBox(height: 24),
                              if (state.todayWorkout != null)
                                _buildWorkoutCard(
                                    state.todayWorkout!, state.workoutStreak),
                              const SizedBox(height: 24),
                              if (state.healthScore != null)
                                _buildAICoachingCard(state.healthScore!),
                              const SizedBox(height: 24),
                              Center(
                                child: TextButton.icon(
                                  onPressed: () async {
                                    final result =
                                        await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            DailyDataCollectionScreen(
                                          onComplete: () => _cubit.refresh(),
                                        ),
                                      ),
                                    );
                                    if (result == true) {
                                      _cubit.refresh();
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
          },
        ),
      ),
    );
  }

  /// Builds the health score circular card from cubit state (formula-based score).
  Widget _buildHealthScoreCard(Map<String, dynamic> healthScore) {
    final scoreRaw = healthScore['score'];
    final score = scoreRaw is int
        ? scoreRaw
        : (scoreRaw is num ? (scoreRaw as num).round() : 85);
    final scoreLabel = healthScore['scoreLabel'] as String? ?? 'Good';
    final breakdown = healthScore['breakdown'] as Map<String, dynamic>? ?? {};
    final bmiRaw = healthScore['bmi'];
    final bmi = bmiRaw is num ? (bmiRaw as num).toDouble() : 0.0;
    final bmiCategory = healthScore['bmiCategory'] as String? ?? 'Unknown';

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
          // Breakdown (values may be int or double from JSON)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBreakdownItem(
                'Fitness',
                _toInt(breakdown['fitness'], 70),
                breakdown['fitnessLabel'] as String?,
              ),
              _buildBreakdownItem(
                'Nutrition',
                _toInt(breakdown['nutrition'], 75),
                breakdown['nutritionLabel'] as String?,
              ),
              _buildBreakdownItem(
                'Recovery',
                _toInt(breakdown['recovery'], 80),
                breakdown['recoveryLabel'] as String?,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMealPlanLoadingPlaceholder() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.backgroundDarkLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderGreen.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primaryGreen.withOpacity(0.8),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Loading suggested meals...',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textGray,
            ),
          ),
        ],
      ),
    );
  }

  static int _toInt(dynamic value, int fallback) {
    if (value is int) return value;
    if (value is num) return (value as num).round();
    return fallback;
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

  /// Builds the daily metrics row (steps, calories, etc.) from cubit state.
  Widget _buildDailyMetrics(Map<String, dynamic>? dailyData) {
    final steps = dailyData?['steps'] ?? 0;
    final calories = dailyData?['calories'] ?? 0;
    final sleep = dailyData?['sleepHours'] ?? 0.0;
    
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

  /// Builds the daily suggested meal plan section: Breakfast, Lunch, Dinner tiles.
  Widget _buildDailyMealPlanSection(DailyMealPlan plan) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundDarkLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderGreen.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.restaurant_menu_rounded,
                color: AppColors.primaryGreen,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                plan.planName ?? 'Today’s suggested meals',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textWhite,
                ),
              ),
            ],
          ),
          if (plan.dailyCalories > 0) ...[
            const SizedBox(height: 4),
            Text(
              '${plan.dailyCalories} cal total • personalized for you',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textGray,
              ),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              if (plan.breakfast != null)
                Expanded(
                  child: _mealPlanTile(
                    context,
                    'Breakfast',
                    plan.breakfast!,
                    Icons.free_breakfast_rounded,
                  ),
                ),
              if (plan.breakfast != null && plan.lunch != null)
                const SizedBox(width: 12),
              if (plan.lunch != null)
                Expanded(
                  child: _mealPlanTile(
                    context,
                    'Lunch',
                    plan.lunch!,
                    Icons.lunch_dining_rounded,
                  ),
                ),
              if (plan.lunch != null && plan.dinner != null)
                const SizedBox(width: 12),
              if (plan.dinner != null)
                Expanded(
                  child: _mealPlanTile(
                    context,
                    'Dinner',
                    plan.dinner!,
                    Icons.dinner_dining_rounded,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mealPlanTile(
    BuildContext context,
    String mealType,
    MealSlot meal,
    IconData icon,
  ) {
    return Material(
      color: AppColors.backgroundDark.withOpacity(0.6),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          print('meal ${meal.description}');
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => MealPlanDetailPage(
                mealType: mealType,
                meal: meal,
              ),
            ),
          );
          },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primaryGreen.withOpacity(0.4),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.primaryGreen, size: 32),
              const SizedBox(height: 10),
              Text(
                mealType,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                meal.description.isNotEmpty ? meal.description : meal.name,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textWhite,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              if (meal.reason.isNotEmpty || meal.alternatives.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Tap for why & alternatives',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.primaryGreen.withOpacity(0.9),
                  ),
                ),
              ],
              if (meal.calories > 0) ...[
                const SizedBox(height: 6),
                Text(
                  '${meal.calories} cal',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textGray,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the nutrition summary card from cubit state.
  /// [userProfile] is passed from state so we don't need context.read (State's context is above BlocProvider).
  Widget _buildNutritionCard(
      FoodNutrition? todayNutrition, UserProfile? userProfile) {
    final calories = todayNutrition?.calories ?? 0.0;
    final protein = todayNutrition?.protein ?? 0.0;
    final carbs = todayNutrition?.carbs ?? 0.0;
    final fat = todayNutrition?.fat ?? 0.0;
    final recommendedCalories = userProfile != null
        ? HealthScoreService.calculateRecommendedCalories(userProfile)
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
                    _cubit.refresh();
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
                  _cubit.refresh();
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

  /// Builds the medical entries card from cubit state.
  Widget _buildMedicalInfoCard(List<MedicalEntry> todayMedicalEntries) {
    final entries = todayMedicalEntries;
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
                    Icons.medical_services,
                    color: AppColors.primaryGreen,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Today\'s Medical Info',
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
                      builder: (context) => const MedicalEntryScreen(),
                    ),
                  );
                  if (result == true) _cubit.refresh();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No medical entries today. Tap + to add blood pressure, sugar level, or custom.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textGray.withOpacity(0.9),
                ),
              ),
            )
          else
            ...entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.label,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textWhite,
                          ),
                        ),
                        Text(
                          '${e.dateTime.hour.toString().padLeft(2, '0')}:${e.dateTime.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    e.displayValue,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
            )),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const MedicalEntryScreen(),
                  ),
                );
                if (result == true) _cubit.refresh();
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryGreen),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Add Medical Info',
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

  /// Builds the today's workout card from cubit state.
  Widget _buildWorkoutCard(WorkoutDay todayWorkout, int workoutStreak) {
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
              if (workoutStreak > 0)
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
                        '$workoutStreak',
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
            todayWorkout.workoutType.toUpperCase().replaceAll('_', ' '),
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
                '${todayWorkout.estimatedDuration} min',
                style: const TextStyle(
                  color: AppColors.textGray,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.local_fire_department, size: 16, color: AppColors.textGray),
              const SizedBox(width: 4),
              Text(
                '~${todayWorkout.estimatedCalories} kcal',
                style: const TextStyle(
                  color: AppColors.textGray,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${todayWorkout.exercises.length} exercises',
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
                      workoutDay: todayWorkout,
                    ),
                  ),
                ).then((completed) {
                  if (completed == true) {
                    _cubit.refresh(); // Refresh to update streak
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

  /// Builds the AI coaching card from cubit state.
  Widget _buildAICoachingCard(Map<String, dynamic> healthScore) {
    final recommendations = healthScore['recommendations'] as List? ?? [];
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
