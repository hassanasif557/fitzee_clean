import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:fitzee_new/core/constants/app_colors.dart';
import '../cubit/onboard_cubit.dart';

class OnboardAvailabilityScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onContinue;

  const OnboardAvailabilityScreen({
    super.key,
    this.onBack,
    this.onContinue,
  });

  @override
  State<OnboardAvailabilityScreen> createState() =>
      _OnboardAvailabilityScreenState();
}

class _OnboardAvailabilityScreenState extends State<OnboardAvailabilityScreen> {
  int? _selectedDays;
  String? _selectedTimeOfDay;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<OnboardCubit>();
    _selectedDays = cubit.profile.trainingDaysPerWeek;
    _selectedTimeOfDay = cubit.profile.preferredTimeOfDay;
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
                        'Availability',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textWhite,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tell us about your training schedule preferences.',
                        style: TextStyle(
                          fontSize: screenWidth < 360 ? 14 : 16,
                          color: AppColors.textGray,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Training Days
                      const Text(
                        'How many days per week can you train?',
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
                        children: List.generate(7, (index) {
                          final days = index + 1;
                          final isSelected = _selectedDays == days;
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedDays = days;
                              });
                              context
                                  .read<OnboardCubit>()
                                  .setTrainingDaysPerWeek(days);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: (screenWidth - 64 - 36) / 4,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryGreen.withOpacity(0.2)
                                    : AppColors.backgroundDarkLight,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primaryGreen
                                      : AppColors.borderGreen.withOpacity(0.3),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Text(
                                '$days',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isSelected
                                      ? AppColors.primaryGreen
                                      : AppColors.textWhite,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 32),
                      // Preferred Time
                      const Text(
                        'Preferred time of day?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textWhite,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTimeOption('morning', 'Morning'),
                      const SizedBox(height: 16),
                      _buildTimeOption('afternoon', 'Afternoon'),
                      const SizedBox(height: 16),
                      _buildTimeOption('evening', 'Evening'),
                      const SizedBox(height: 32),
                      // Continue Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _selectedDays != null &&
                                  _selectedTimeOfDay != null
                              ? () {
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

  Widget _buildTimeOption(String value, String label) {
    final isSelected = _selectedTimeOfDay == value;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedTimeOfDay = value;
        });
        context.read<OnboardCubit>().setPreferredTimeOfDay(value);
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
