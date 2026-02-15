import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitzee_new/features/onboard/presentation/pages/onboard/cubit/onboard_cubit.dart';
import 'package:fitzee_new/features/onboard/presentation/pages/onboard/screens/onboard_fat_loss_screen.dart';
import 'package:fitzee_new/features/onboard/presentation/pages/onboard/screens/onboard_rehab_screen.dart';

/// Shows fat-loss or rehab specific questions based on user type. Medical users skip this (they get the 6-step questionnaire).
class OnboardTypeSpecificScreen extends StatelessWidget {
  final VoidCallback? onContinue;
  final VoidCallback? onBack;

  const OnboardTypeSpecificScreen({
    super.key,
    this.onContinue,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final userType = context.read<OnboardCubit>().profile.userType ??
        context.read<OnboardCubit>().profile.goal;
    if (userType == 'fat_loss') {
      return OnboardFatLossScreen(
        onContinue: onContinue,
        onBack: onBack,
      );
    }
    if (userType == 'rehab') {
      return OnboardRehabScreen(
        onContinue: onContinue,
        onBack: onBack,
      );
    }
    return const SizedBox.shrink();
  }
}
