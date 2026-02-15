import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitzee_new/core/constants/app_colors.dart';
import 'package:fitzee_new/features/onboard/presentation/pages/onboard/cubit/onboard_cubit.dart';

/// Rehab / physiotherapy specific questions (optional). Shown after Personal Info when userType == 'rehab'.
class OnboardRehabScreen extends StatefulWidget {
  final VoidCallback? onContinue;
  final VoidCallback? onBack;

  const OnboardRehabScreen({
    super.key,
    this.onContinue,
    this.onBack,
  });

  @override
  State<OnboardRehabScreen> createState() => _OnboardRehabScreenState();
}

class _OnboardRehabScreenState extends State<OnboardRehabScreen> {
  final _focusAreas = <String>[];
  String? _painLevel; // low, medium, high

  static const _areas = [
    'lower_back',
    'knee',
    'shoulder',
    'neck',
    'hip',
    'ankle',
    'general_mobility',
  ];
  static const _areaLabels = {
    'lower_back': 'Lower back',
    'knee': 'Knee',
    'shoulder': 'Shoulder',
    'neck': 'Neck',
    'hip': 'Hip',
    'ankle': 'Ankle',
    'general_mobility': 'General mobility',
  };

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
                'Rehab Focus',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textWhite,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Optional — helps us tailor exercises for you.',
                style: TextStyle(color: AppColors.textGray, fontSize: 14),
              ),
              const SizedBox(height: 32),
              const Text(
                'Focus areas (select any)',
                style: TextStyle(color: AppColors.textWhite, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _areas.map((value) {
                  final selected = _focusAreas.contains(value);
                  return FilterChip(
                    label: Text(_areaLabels[value] ?? value),
                    selected: selected,
                    onSelected: (v) {
                      setState(() {
                        if (v) _focusAreas.add(value);
                        else _focusAreas.remove(value);
                      });
                    },
                    selectedColor: AppColors.primaryGreen.withOpacity(0.4),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              const Text(
                'Current pain level',
                style: TextStyle(color: AppColors.textWhite, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _chip('low', 'Low'),
                  _chip('medium', 'Medium'),
                  _chip('high', 'High'),
                ],
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<OnboardCubit>().setRehabGoals(
                      focusAreas: _focusAreas.isEmpty ? null : List.from(_focusAreas),
                      painLevel: _painLevel,
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
    final selected = _painLevel == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _painLevel = value),
      selectedColor: AppColors.primaryGreen.withOpacity(0.4),
    );
  }
}
