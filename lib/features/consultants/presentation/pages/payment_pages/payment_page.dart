import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/stripe_service.dart';
import '../../domain/entities/doctor.dart';

class PaymentPage extends StatelessWidget {
  final Doctor doctor;
  final String selectedTime;

  const PaymentPage({
    super.key,
    required this.doctor,
    required this.selectedTime,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(title: const Text('Payment')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _summary(),
            const Spacer(),
            _payButton(context),
          ],
        ),
      ),
    );
  }

  Widget _summary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundDarkBlueGreen,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(doctor.name,
              style: const TextStyle(color: AppColors.textWhite)),
          const SizedBox(height: 6),
          Text('Time: $selectedTime',
              style: const TextStyle(color: AppColors.textGray)),
          const SizedBox(height: 6),
          Text(
            '\$${doctor.pricePerHour}',
            style: const TextStyle(
              color: AppColors.primaryGreen,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _payButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
        ),
        onPressed: () async {
          await StripeService.pay(doctor.pricePerHour);
          Navigator.popUntil(context, (r) => r.isFirst);
        },
        child: const Text(
          'Pay Now',
          style: TextStyle(
            color: AppColors.textBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
