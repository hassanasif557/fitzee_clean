import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:fitzee_new/core/constants/app_colors.dart';
import '../cubit/onboard_cubit.dart';

class OnboardActivityHistoryScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onContinue;

  const OnboardActivityHistoryScreen({
    super.key,
    this.onBack,
    this.onContinue,
  });

  @override
  State<OnboardActivityHistoryScreen> createState() =>
      _OnboardActivityHistoryScreenState();
}

class _OnboardActivityHistoryScreenState
    extends State<OnboardActivityHistoryScreen> {
  int? _selectedFrequency;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<OnboardCubit>();
    _selectedFrequency = cubit.profile.exerciseFrequencyPerWeek;
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
                        'Activity History',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textWhite,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'How often do you currently exercise per week?',
                        style: TextStyle(
                          fontSize: screenWidth < 360 ? 14 : 16,
                          color: AppColors.textGray,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Frequency Options
                      _buildFrequencyOption(0, 'Never'),
                      const SizedBox(height: 16),
                      _buildFrequencyOption(1, '1 day per week'),
                      const SizedBox(height: 16),
                      _buildFrequencyOption(2, '2 days per week'),
                      const SizedBox(height: 16),
                      _buildFrequencyOption(3, '3 days per week'),
                      const SizedBox(height: 16),
                      _buildFrequencyOption(4, '4 days per week'),
                      const SizedBox(height: 16),
                      _buildFrequencyOption(5, '5 days per week'),
                      const SizedBox(height: 16),
                      _buildFrequencyOption(6, '6 days per week'),
                      const SizedBox(height: 16),
                      _buildFrequencyOption(7, '7 days per week'),
                      const SizedBox(height: 32),
                      // Continue Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _selectedFrequency != null
                              ? () {
                                  context
                                      .read<OnboardCubit>()
                                      .setExerciseFrequencyPerWeek(
                                          _selectedFrequency!);
                                  if (widget.onContinue != null) {
                                    widget.onContinue!();
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            foregroundColor: AppColors.textBlack,
                            disabledBackgroundColor:
                                AppColors.primaryGreen.withOpacity(0.5),
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

  Widget _buildFrequencyOption(int frequency, String label) {
    final isSelected = _selectedFrequency == frequency;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedFrequency = frequency;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundDarkLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGreen
                : AppColors.borderGreen.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? AppColors.primaryGreen
                      : AppColors.textWhite,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primaryGreen,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
