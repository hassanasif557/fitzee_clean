import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:fitzee_new/core/constants/app_colors.dart';
import '../cubit/onboard_cubit.dart';

class OnboardRecentEventsScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onContinue;

  const OnboardRecentEventsScreen({
    super.key,
    this.onBack,
    this.onContinue,
  });

  @override
  State<OnboardRecentEventsScreen> createState() =>
      _OnboardRecentEventsScreenState();
}

class _OnboardRecentEventsScreenState
    extends State<OnboardRecentEventsScreen> {
  bool _hasRecentSurgeries = false;
  bool _isPregnant = false;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<OnboardCubit>();
    final profile = cubit.profile;
    _hasRecentSurgeries = profile.hasRecentSurgeries ?? false;
    _isPregnant = profile.isPregnant ?? false;
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
                        'Recent Events',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textWhite,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Please let us know about any recent events that might affect your training.',
                        style: TextStyle(
                          fontSize: screenWidth < 360 ? 14 : 16,
                          color: AppColors.textGray,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Recent Events Options
                      _buildCheckboxOption(
                        'Recent surgeries',
                        _hasRecentSurgeries,
                        (value) {
                          setState(() {
                            _hasRecentSurgeries = value;
                          });
                          context.read<OnboardCubit>().setHasRecentSurgeries(value);
                        },
                        Icons.local_hospital,
                      ),
                      const SizedBox(height: 16),
                      _buildCheckboxOption(
                        'Currently pregnant',
                        _isPregnant,
                        (value) {
                          setState(() {
                            _isPregnant = value;
                          });
                          context.read<OnboardCubit>().setIsPregnant(value);
                        },
                        Icons.child_care,
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
                              onPressed: isSaving
                                  ? null
                                  : () {
                                      // Continue to next screen
                                      if (widget.onContinue != null) {
                                        widget.onContinue!();
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                foregroundColor: AppColors.textBlack,
                                disabledBackgroundColor:
                                    AppColors.primaryGreen.withOpacity(0.5),
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

  Widget _buildCheckboxOption(
    String label,
    bool value,
    Function(bool) onChanged,
    IconData icon,
  ) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundDarkLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: value
                ? AppColors.primaryGreen
                : AppColors.borderGreen.withOpacity(0.3),
            width: value ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: value ? AppColors.primaryGreen : AppColors.textGray,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color: value
                      ? AppColors.primaryGreen
                      : AppColors.textWhite,
                  fontWeight: value ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            Checkbox(
              value: value,
              onChanged: (newValue) => onChanged(newValue ?? false),
              activeColor: AppColors.primaryGreen,
              checkColor: AppColors.textBlack,
            ),
          ],
        ),
      ),
    );
  }
}
