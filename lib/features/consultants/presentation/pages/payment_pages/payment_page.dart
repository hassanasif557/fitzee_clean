import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitzee_new/features/consultants/presentation/pages/payment_pages/payment_failed_page.dart';
import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/services/local_storage_service.dart';
import '../../../../../core/services/notification_service.dart';
import '../../../../../core/services/stripe_service.dart';
import '../../../data/datasources/consultant_remote_datasource.dart';
import '../../../data/repositories/appointment_repository_impl.dart';
import '../../../domain/entities/appointment.dart';
import '../../../domain/entities/doctor.dart';
import 'appointment_success_page.dart';

class PaymentPage extends StatelessWidget {
  final Doctor doctor;
  /// Appointment date (start of day). Required for correct booking.
  final DateTime selectedDate;
  final String selectedTime;

  const PaymentPage({
    super.key,
    required this.doctor,
    required this.selectedDate,
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
    final dateStr = '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
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
              style: const TextStyle(
                color: AppColors.textWhite,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 6),
          Text('Date: $dateStr • $selectedTime',
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
        // onPressed: () async {
        //   await StripeService.pay(doctor.pricePerHour);
        //   Navigator.popUntil(context, (r) => r.isFirst);
        // },
        onPressed: () async {
          final success = await StripeService.pay(
            doctor.pricePerHour,
          );

          if (success) {
            final userId = await LocalStorageService.getUserId();
            final appointment = Appointment(
              doctorId: doctor.id,
              doctorName: doctor.name,
              userId: userId ?? '',
              appointmentTime: selectedTime,
              price: doctor.pricePerHour,
              status: 'confirmed',
              paymentStatus: 'paid',
              createdAt: DateTime.now(),
              appointmentDate: selectedDate,
            );

            final repo = AppointmentRepositoryImpl(
              FirebaseFirestore.instance,
              ConsultantRemoteDatasource(FirebaseFirestore.instance),
            );
            await repo.saveAppointment(appointment);

            final dateStr = '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
            await NotificationService.showAppointmentBookedNotification(
              doctorName: doctor.name,
              dateStr: dateStr,
              time: selectedTime,
            );

            if (context.mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const AppointmentSuccessPage(),
                ),
              );
            }
          } else {
            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PaymentFailedPage(),
                ),
              );
            }
          }
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
