import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:fitzee_new/features/onboard/presentation/pages/onboard/cubit/onboard_cubit.dart';
import 'package:fitzee_new/features/onboard/presentation/pages/onboard/screens/onboard_intro_screen.dart';
import 'package:fitzee_new/features/onboard/presentation/pages/onboard/screens/onboard_goal_screen.dart';
import 'package:fitzee_new/features/onboard/presentation/pages/onboard/screens/onboard_personal_info_screen.dart';
import 'package:fitzee_new/features/onboard/presentation/pages/onboard/screens/onboard_activity_history_screen.dart';
import 'package:fitzee_new/features/onboard/presentation/pages/onboard/screens/onboard_availability_screen.dart';
import 'package:fitzee_new/features/onboard/presentation/pages/onboard/screens/onboard_daily_habits_screen.dart';
import 'package:fitzee_new/features/onboard/presentation/pages/onboard/screens/onboard_medical_conditions_screen.dart';
import 'package:fitzee_new/features/onboard/presentation/pages/onboard/screens/onboard_physical_state_screen.dart';
import 'package:fitzee_new/features/onboard/presentation/pages/onboard/screens/onboard_recent_events_screen.dart';
import 'package:fitzee_new/features/onboard/presentation/pages/onboard/screens/onboard_workout_preferences_screen.dart';
import 'package:fitzee_new/features/onboard/presentation/pages/onboard/screens/onboard_diet_preferences_screen.dart';



class OnboardPage extends StatefulWidget {
  const OnboardPage({super.key});

  @override
  State<OnboardPage> createState() => _OnboardPageState();
}

class _OnboardPageState extends State<OnboardPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const int totalPages = 11;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int pageIndex) {
    setState(() {
      _currentPage = pageIndex;
    });
    _pageController.animateToPage(
      pageIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _nextPage() {
    if (_currentPage < totalPages - 1) {
      _goToPage(_currentPage + 1);
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _goToPage(_currentPage - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OnboardCubit(),
      child: BlocListener<OnboardCubit, OnboardState>(
        listener: (context, state) {
          if (state is OnboardCompleted) {
            context.go('/dashboard');
          }
        },
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          physics: const NeverScrollableScrollPhysics(),
          children: [
            // Screen 0: Intro
            OnboardIntroScreen(onNext: _nextPage),
            // Screen 1: Goal Selection
            OnboardGoalScreen(
              onContinue: () => _goToPage(2),
              onBack: _previousPage,
            ),
            // Screen 2: Personal Info
            OnboardPersonalInfoScreen(
              onBack: _previousPage,
              onContinue: () => _goToPage(3),
            ),
            // Screen 3: Activity History
            OnboardActivityHistoryScreen(
              onBack: _previousPage,
              onContinue: () => _goToPage(4),
            ),
            // Screen 4: Availability
            OnboardAvailabilityScreen(
              onBack: _previousPage,
              onContinue: () => _goToPage(5),
            ),
            // Screen 5: Daily Habits
            OnboardDailyHabitsScreen(
              onBack: _previousPage,
              onContinue: () => _goToPage(6),
            ),
            // Screen 6: Medical Conditions
            OnboardMedicalConditionsScreen(
              onBack: _previousPage,
              onContinue: () => _goToPage(7),
            ),
            // Screen 7: Physical State
            OnboardPhysicalStateScreen(
              onBack: _previousPage,
              onContinue: () => _goToPage(8),
            ),
            // Screen 8: Recent Events
            OnboardRecentEventsScreen(
              onBack: _previousPage,
              onContinue: () => _goToPage(9),
            ),
            // Screen 9: Workout Preferences
            OnboardWorkoutPreferencesScreen(
              onBack: _previousPage,
              onContinue: () => _goToPage(10),
            ),
            // Screen 10: Diet Preferences (Final Screen)
            OnboardDietPreferencesScreen(
              onBack: _previousPage,
            ),
          ],
        ),
      ),
    );
  }
}

