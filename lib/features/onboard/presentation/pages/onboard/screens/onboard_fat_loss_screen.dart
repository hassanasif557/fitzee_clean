import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitzee_new/core/constants/app_colors.dart';
import 'package:fitzee_new/features/onboard/presentation/pages/onboard/cubit/onboard_cubit.dart';

/// Fat-loss specific questions (optional). Shown after Personal Info when userType == 'fat_loss'.
class OnboardFatLossScreen extends StatefulWidget {
  final VoidCallback? onContinue;
  final VoidCallback? onBack;

  const OnboardFatLossScreen({
    super.key,
    this.onContinue,
    this.onBack,
  });

  @override
  State<OnboardFatLossScreen> createState() => _OnboardFatLossScreenState();
}

class _OnboardFatLossScreenState extends State<OnboardFatLossScreen> {
  final _targetWeightController = TextEditingController();
  String? _weeklyGoal; // lose_1kg, lose_0_5kg, maintain

  @override
  void dispose() {
    _targetWeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDarkBlueGreen,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
          onPressed: widget.onBack,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Fat Loss Goals',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textWhite,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Optional — we\'ll use this to tailor your plan.',
                style: TextStyle(color: AppColors.textGray, fontSize: 14),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _targetWeightController,
                decoration: const InputDecoration(
                  labelText: 'Target weight (kg)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              const Text(
                'Weekly goal',
                style: TextStyle(color: AppColors.textWhite, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _chip('lose_1kg', 'Lose ~1 kg/week'),
                  _chip('lose_0_5kg', 'Lose ~0.5 kg/week'),
                  _chip('maintain', 'Maintain weight'),
                ],
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    final cubit = context.read<OnboardCubit>();
                    final target = double.tryParse(_targetWeightController.text.trim());
                    cubit.setFatLossGoals(
                      targetWeightKg: target,
                      weeklyGoal: _weeklyGoal,
                    );
                    widget.onContinue?.call();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: AppColors.textBlack,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String value, String label) {
    final selected = _weeklyGoal == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _weeklyGoal = value),
      selectedColor: AppColors.primaryGreen.withOpacity(0.4),
    );
  }
}
