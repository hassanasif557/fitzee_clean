import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/repositories/appointment_repository_impl.dart';
import '../../domain/entities/appointment.dart';
import '../cubit/appointment_state.dart';
import '../cubit/apppointment_cubit.dart';

class MyAppointmentsPage extends StatefulWidget {
  const MyAppointmentsPage({super.key});

  @override
  State<MyAppointmentsPage> createState() => _MyAppointmentsPageState();
}

class _MyAppointmentsPageState extends State<MyAppointmentsPage> {
  bool showUpcoming = true;

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return BlocProvider(
      create: (_) => AppointmentCubit(
        AppointmentRepositoryImpl(FirebaseFirestore.instance),
      )..loadAppointments(userId),
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundDark,
          elevation: 0,
          title: const Text(
            'My Appointments',
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: const IconThemeData(color: AppColors.textWhite),
        ),
        body: BlocBuilder<AppointmentCubit, AppointmentState>(
          builder: (context, state) {
            if (state is AppointmentLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGreen),
              );
            }

            if (state is AppointmentsLoaded) {
              final now = DateTime.now();

              final upcoming = state.appointments
                  .where((a) => a.appointmentDate.isAfter(now))
                  .toList();

              final past = state.appointments
                  .where((a) => a.appointmentDate.isBefore(now))
                  .toList();

              return Column(
                children: [
                  _tabs(),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: (showUpcoming ? upcoming : past)
                          .map(_appointmentCard)
                          .toList(),
                    ),
                  ),
                ],
              );
            }

            return const Center(
              child: Text(
                'Failed to load appointments',
                style: TextStyle(color: AppColors.textWhite),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _tabs() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _tabButton('Upcoming', true),
          const SizedBox(width: 12),
          _tabButton('Past', false),
        ],
      ),
    );
  }

  Widget _tabButton(String title, bool upcoming) {
    final selected = showUpcoming == upcoming;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => showUpcoming = upcoming),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.backgroundDarkBlueGreen
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: selected
                    ? AppColors.primaryGreen
                    : AppColors.textGray,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _appointmentCard(Appointment a) {
    final dateStr = '${a.appointmentDate.year}-${a.appointmentDate.month.toString().padLeft(2, '0')}-${a.appointmentDate.day.toString().padLeft(2, '0')}';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundDarkBlueGreen,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGreenDark.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$dateStr • ${a.appointmentTime}',
                  style: const TextStyle(
                    color: AppColors.primaryGreen,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            a.doctorName,
            style: const TextStyle(
              color: AppColors.textWhite,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Consultation • \$${a.price}',
            style: const TextStyle(color: AppColors.textGray, fontSize: 14),
          ),
          const SizedBox(height: 14),
          if (showUpcoming)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: AppColors.textBlack,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  'Join Call',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            )
          else
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  'View Recap',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
