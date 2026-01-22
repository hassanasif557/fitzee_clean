import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:fitzee_new/core/constants/app_colors.dart';
import '../cubit/onboard_cubit.dart';

class OnboardPhysicalStateScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onContinue;

  const OnboardPhysicalStateScreen({
    super.key,
    this.onBack,
    this.onContinue,
  });

  @override
  State<OnboardPhysicalStateScreen> createState() =>
      _OnboardPhysicalStateScreenState();
}

class _OnboardPhysicalStateScreenState
    extends State<OnboardPhysicalStateScreen> {
  bool _hasActiveInjuries = false;
  bool _hasChronicPain = false;
  bool _takingPrescriptionMedications = false;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<OnboardCubit>();
    final profile = cubit.profile;
    _hasActiveInjuries = profile.hasActiveInjuries ?? false;
    _hasChronicPain = profile.hasChronicPain ?? false;
    _takingPrescriptionMedications =
        profile.takingPrescriptionMedications ?? false;
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
                        'Physical State',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textWhite,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Help us understand your current physical condition.',
                        style: TextStyle(
                          fontSize: screenWidth < 360 ? 14 : 16,
                          color: AppColors.textGray,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Physical State Options
                      _buildCheckboxOption(
                        'Active injuries',
                        _hasActiveInjuries,
                        (value) {
                          setState(() {
                            _hasActiveInjuries = value;
                          });
                          context.read<OnboardCubit>().setHasActiveInjuries(value);
                        },
                        Icons.healing,
                      ),
                      const SizedBox(height: 16),
                      _buildCheckboxOption(
                        'Chronic pain',
                        _hasChronicPain,
                        (value) {
                          setState(() {
                            _hasChronicPain = value;
                          });
                          context.read<OnboardCubit>().setHasChronicPain(value);
                        },
                        Icons.medical_information,
                      ),
                      const SizedBox(height: 16),
                      _buildCheckboxOption(
                        'Taking prescription medications',
                        _takingPrescriptionMedications,
                        (value) {
                          setState(() {
                            _takingPrescriptionMedications = value;
                          });
                          context
                              .read<OnboardCubit>()
                              .setTakingPrescriptionMedications(value);
                        },
                        Icons.medication,
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
