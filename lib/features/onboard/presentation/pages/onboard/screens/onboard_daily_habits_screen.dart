import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:fitzee_new/core/constants/app_colors.dart';
import '../cubit/onboard_cubit.dart';

class OnboardDailyHabitsScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onContinue;

  const OnboardDailyHabitsScreen({
    super.key,
    this.onBack,
    this.onContinue,
  });

  @override
  State<OnboardDailyHabitsScreen> createState() =>
      _OnboardDailyHabitsScreenState();
}

class _OnboardDailyHabitsScreenState extends State<OnboardDailyHabitsScreen> {
  final TextEditingController _sleepHoursController = TextEditingController();
  int? _selectedStressLevel;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<OnboardCubit>();
    if (cubit.profile.averageSleepHours != null) {
      _sleepHoursController.text =
          cubit.profile.averageSleepHours!.toStringAsFixed(1);
    }
    _selectedStressLevel = cubit.profile.stressLevel;
  }

  @override
  void dispose() {
    _sleepHoursController.dispose();
    super.dispose();
  }

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
                        'Daily Habits',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textWhite,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Help us understand your daily routine.',
                        style: TextStyle(
                          fontSize: screenWidth < 360 ? 14 : 16,
                          color: AppColors.textGray,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Sleep Hours
                      const Text(
                        'Average Sleep Hours',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textWhite,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _sleepHoursController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        style: const TextStyle(color: AppColors.textWhite),
                        decoration: InputDecoration(
                          labelText: 'Hours per night',
                          labelStyle: const TextStyle(
                            color: AppColors.textGray,
                          ),
                          hintText: '7.5',
                          hintStyle: const TextStyle(
                            color: AppColors.textGray,
                          ),
                          prefixIcon: const Icon(
                            Icons.bedtime,
                            color: AppColors.primaryGreen,
                          ),
                          filled: true,
                          fillColor: AppColors.backgroundDarkLight,
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
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            final hours = double.tryParse(value);
                            if (hours != null) {
                              context
                                  .read<OnboardCubit>()
                                  .setAverageSleepHours(hours);
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 32),
                      // Stress Level
                      const Text(
                        'Stress Level (1-10)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textWhite,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: List.generate(10, (index) {
                          final level = index + 1;
                          final isSelected = _selectedStressLevel == level;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedStressLevel = level;
                                  });
                                  context
                                      .read<OnboardCubit>()
                                      .setStressLevel(level);
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primaryGreen
                                        : AppColors.backgroundDarkLight,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primaryGreen
                                          : AppColors.borderGreen
                                              .withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    '$level',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: isSelected
                                          ? AppColors.textBlack
                                          : AppColors.textWhite,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 32),
                      // Continue Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
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
}
