import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';

class AppointmentSuccessPage extends StatelessWidget {
  const AppointmentSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle,
                size: 80, color: AppColors.primaryGreen),
            const SizedBox(height: 16),
            const Text(
              'Appointment Confirmed',
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your appointment has been booked successfully',
              style: TextStyle(color: AppColors.textGray),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
              ),
              onPressed: () {
                Navigator.popUntil(context, (r) => r.isFirst);
              },
              child: const Text(
                'Go Home',
                style: TextStyle(color: AppColors.textBlack),
              ),
            )
          ],
        ),
      ),
    );
  }
}
