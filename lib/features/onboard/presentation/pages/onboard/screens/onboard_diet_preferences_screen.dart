import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:fitzee_new/core/constants/app_colors.dart';
import 'package:fitzee_new/core/services/ai_coaching_service.dart';
import 'package:fitzee_new/features/onboard/presentation/pages/onboard/cubit/onboard_cubit.dart';

class OnboardDietPreferencesScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onContinue;

  const OnboardDietPreferencesScreen({
    super.key,
    this.onBack,
    this.onContinue,
  });

  @override
  State<OnboardDietPreferencesScreen> createState() =>
      _OnboardDietPreferencesScreenState();
}

class _OnboardDietPreferencesScreenState
    extends State<OnboardDietPreferencesScreen> {
  List<String> _dietaryRestrictions = [];
  List<String> _dislikedFoods = [];
  String? _mealFrequency;
  String? _cookingSkill;

  final List<String> _restrictionOptions = [
    'Vegetarian',
    'Vegan',
    'Gluten-Free',
    'Dairy-Free',
    'Nut-Free',
    'Halal',
    'Kosher',
    'Paleo',
    'Keto',
  ];

  final List<String> _mealFrequencyOptions = [
    '3 meals per day',
    '4-5 small meals',
    'Intermittent Fasting',
    'Flexible',
  ];

  final List<String> _cookingSkillOptions = [
    'Beginner',
    'Intermediate',
    'Advanced',
    'No Cooking',
  ];

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;

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
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.textWhite,
                      ),
                      onPressed: () {
                        if (widget.onBack != null) {
                          widget.onBack!();
                        } else {
                          context.pop();
                        }
                      },
                    ),
                    const Expanded(child: SizedBox()),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth < 360 ? 24 : 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 32),
                      const Text(
                        'Diet Preferences',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textWhite,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Help us create a personalized meal plan that fits your lifestyle.',
                        style: TextStyle(
                          fontSize: screenWidth < 360 ? 14 : 16,
                          color: AppColors.textGray,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Dietary Restrictions
                      const Text(
                        'Dietary Restrictions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textWhite,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '(Select all that apply)',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textGray,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _restrictionOptions.map((restriction) {
                          final isSelected =
                              _dietaryRestrictions.contains(restriction);
                          return _buildChipOption(
                            restriction,
                            isSelected,
                            () {
                              setState(() {
                                if (isSelected) {
                                  _dietaryRestrictions.remove(restriction);
                                } else {
                                  _dietaryRestrictions.add(restriction);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 32),
                      // Meal Frequency
                      const Text(
                        'Preferred Meal Frequency',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textWhite,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _mealFrequencyOptions.map((frequency) {
                          final isSelected = _mealFrequency == frequency;
                          return _buildChipOption(
                            frequency,
                            isSelected,
                            () {
                              setState(() {
                                _mealFrequency = frequency;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 32),
                      // Cooking Skill
                      const Text(
                        'Cooking Skill Level',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textWhite,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _cookingSkillOptions.map((skill) {
                          final isSelected = _cookingSkill == skill;
                          return _buildChipOption(
                            skill,
                            isSelected,
                            () {
                              setState(() {
                                _cookingSkill = skill;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 32),
                      // Get Started Button
                      BlocConsumer<OnboardCubit, OnboardState>(
                        listener: (context, state) {
                          if (state is OnboardCompleted) {
                            context.go('/dashboard');
                          } else if (state is OnboardError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(state.message),
                                backgroundColor: AppColors.errorRed,
                              ),
                            );
                          }
                        },
                        builder: (context, state) {
                          final isSaving = state is OnboardSaving;
                          return SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                          onPressed: () async {
                            // Save preferences
                            await AICoachingService.saveDietPreferences({
                              'dietaryRestrictions': _dietaryRestrictions,
                              'dislikedFoods': _dislikedFoods,
                              'mealFrequency': _mealFrequency,
                              'cookingSkill': _cookingSkill,
                            });
                            
                            // Save profile and complete onboard
                            if (mounted) {
                              context.read<OnboardCubit>().saveProfile();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            foregroundColor: AppColors.textBlack,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                              child: isSaving
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          AppColors.textBlack,
                                        ),
                                      ),
                                    )
                                  : const Text(
                                      'Get Started',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChipOption(
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGreen
              : AppColors.backgroundDarkLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGreen
                : AppColors.borderGreen.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.textBlack : AppColors.textWhite,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
