import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:fitzee_new/features/onboard/presentation/pages/onboard/cubit/onboard_cubit.dart';
import 'package:fitzee_new/features/onboard/presentation/pages/onboard/screens/onboard_intro_screen.dart';
import 'package:fitzee_new/features/onboard/presentation/pages/onboard/screens/onboard_goal_screen.dart';
import 'package:fitzee_new/features/onboard/presentation/pages/onboard/screens/onboard_medical_questionnaire_page.dart';
import 'package:fitzee_new/features/onboard/presentation/pages/onboard/screens/onboard_personal_info_screen.dart';
import 'package:fitzee_new/features/onboard/presentation/pages/onboard/screens/onboard_activity_history_screen.dart';
import 'package:fitzee_new/features/onboard/presentation/pages/onboard/screens/onboard_availability_screen.dart';
import 'package:fitzee_new/features/onboard/presentation/pages/onboard/screens/onboard_daily_habits_screen.dart';
import 'package:fitzee_new/features/onboard/presentation/pages/onboard/screens/onboard_medical_conditions_screen.dart';
import 'package:fitzee_new/features/onboard/presentation/pages/onboard/screens/onboard_physical_state_screen.dart';
import 'package:fitzee_new/features/onboard/presentation/pages/onboard/screens/onboard_recent_events_screen.dart';
import 'package:fitzee_new/features/onboard/presentation/pages/onboard/screens/onboard_workout_preferences_screen.dart';
import 'package:fitzee_new/features/onboard/presentation/pages/onboard/screens/onboard_diet_preferences_screen.dart';
import 'package:fitzee_new/features/onboard/presentation/pages/onboard/screens/onboard_type_specific_screen.dart';



class OnboardPage extends StatefulWidget {
  const OnboardPage({super.key});

  @override
  State<OnboardPage> createState() => _OnboardPageState();
}

class _OnboardPageState extends State<OnboardPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const int totalPages = 12;

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

  /// After Personal Info: if medical user type, show 6-step medical questionnaire then save & go dashboard; else continue to Activity.
  void _onAfterPersonalInfo(BuildContext context) {
    final cubit = context.read<OnboardCubit>();
    final userType = cubit.profile.userType ?? cubit.profile.goal;
    if (userType == 'medical') {
      Navigator.of(context)
          .push<bool>(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: cubit,
                child: OnboardMedicalQuestionnairePage(
                  onComplete: () {},
                ),
              ),
            ),
          )
          .then((done) async {
        if (done == true && context.mounted) {
          await cubit.saveProfile();
          if (context.mounted) context.go('/dashboard');
        }
      });
    } else {
      _goToPage(3);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardCubit, OnboardState>(
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
            // Screen 2: Personal Info (then branch: medical → questionnaire, else → type-specific then activity)
            OnboardPersonalInfoScreen(
              onBack: _previousPage,
              onContinue: () => _onAfterPersonalInfo(context),
            ),
            // Screen 3: Type-specific (fat loss or rehab questions)
            OnboardTypeSpecificScreen(
              onBack: () => _goToPage(2),
              onContinue: () => _goToPage(4),
            ),
            // Screen 4: Activity History
            OnboardActivityHistoryScreen(
              onBack: _previousPage,
              onContinue: () => _goToPage(5),
            ),
            // Screen 5: Availability
            OnboardAvailabilityScreen(
              onBack: _previousPage,
              onContinue: () => _goToPage(6),
            ),
            // Screen 6: Daily Habits
            OnboardDailyHabitsScreen(
              onBack: _previousPage,
              onContinue: () => _goToPage(7),
            ),
            // Screen 7: Medical Conditions
            OnboardMedicalConditionsScreen(
              onBack: _previousPage,
              onContinue: () => _goToPage(8),
            ),
            // Screen 8: Physical State
            OnboardPhysicalStateScreen(
              onBack: _previousPage,
              onContinue: () => _goToPage(9),
            ),
            // Screen 9: Recent Events
            OnboardRecentEventsScreen(
              onBack: _previousPage,
              onContinue: () => _goToPage(10),
            ),
            // Screen 10: Workout Preferences
            OnboardWorkoutPreferencesScreen(
              onBack: _previousPage,
              onContinue: () => _goToPage(11),
            ),
            // Screen 11: Diet Preferences (Final Screen)
            OnboardDietPreferencesScreen(
              onBack: _previousPage,
            ),
          ],
        ),
      );
  }
}

