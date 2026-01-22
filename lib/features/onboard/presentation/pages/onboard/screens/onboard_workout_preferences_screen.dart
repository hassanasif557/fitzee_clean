import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:fitzee_new/core/constants/app_colors.dart';
import 'package:fitzee_new/core/services/ai_coaching_service.dart';
import '../cubit/onboard_cubit.dart';

class OnboardWorkoutPreferencesScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onContinue;

  const OnboardWorkoutPreferencesScreen({
    super.key,
    this.onBack,
    this.onContinue,
  });

  @override
  State<OnboardWorkoutPreferencesScreen> createState() =>
      _OnboardWorkoutPreferencesScreenState();
}

class _OnboardWorkoutPreferencesScreenState
    extends State<OnboardWorkoutPreferencesScreen> {
  String? _preferredWorkoutType;
  String? _equipmentAvailable;
  String? _workoutLocation;
  List<String> _favoriteExercises = [];
  String? _workoutIntensity;

  final List<String> _workoutTypes = [
    'Strength Training',
    'Cardio',
    'Yoga/Pilates',
    'HIIT',
    'CrossFit',
    'Bodyweight',
    'Mixed',
  ];

  final List<String> _equipmentOptions = [
    'Gym Equipment',
    'Home Equipment',
    'No Equipment',
    'Mixed',
  ];

  final List<String> _locationOptions = [
    'Gym',
    'Home',
    'Outdoor',
    'Anywhere',
  ];

  final List<String> _intensityOptions = [
    'Light',
    'Moderate',
    'High',
    'Very High',
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
                        'Workout Preferences',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textWhite,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Help us create the perfect workout plan for you.',
                        style: TextStyle(
                          fontSize: screenWidth < 360 ? 14 : 16,
                          color: AppColors.textGray,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Preferred Workout Type
                      const Text(
                        'Preferred Workout Type',
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
                        children: _workoutTypes.map((type) {
                          final isSelected = _preferredWorkoutType == type;
                          return _buildChipOption(
                            type,
                            isSelected,
                            () {
                              setState(() {
                                _preferredWorkoutType = type;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 32),
                      // Equipment Available
                      const Text(
                        'Equipment Available',
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
                        children: _equipmentOptions.map((option) {
                          final isSelected = _equipmentAvailable == option;
                          return _buildChipOption(
                            option,
                            isSelected,
                            () {
                              setState(() {
                                _equipmentAvailable = option;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 32),
                      // Workout Location
                      const Text(
                        'Preferred Location',
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
                        children: _locationOptions.map((location) {
                          final isSelected = _workoutLocation == location;
                          return _buildChipOption(
                            location,
                            isSelected,
                            () {
                              setState(() {
                                _workoutLocation = location;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 32),
                      // Workout Intensity
                      const Text(
                        'Preferred Intensity',
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
                        children: _intensityOptions.map((intensity) {
                          final isSelected = _workoutIntensity == intensity;
                          return _buildChipOption(
                            intensity,
                            isSelected,
                            () {
                              setState(() {
                                _workoutIntensity = intensity;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 32),
                      // Continue Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            // Save preferences
                            await AICoachingService.saveWorkoutPreferences({
                              'preferredWorkoutType': _preferredWorkoutType,
                              'equipmentAvailable': _equipmentAvailable,
                              'workoutLocation': _workoutLocation,
                              'workoutIntensity': _workoutIntensity,
                              'favoriteExercises': _favoriteExercises,
                            });
                            
                            if (widget.onContinue != null) {
                              widget.onContinue!();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            foregroundColor: AppColors.textBlack,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
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
