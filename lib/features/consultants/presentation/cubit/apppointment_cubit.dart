import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/appointment.dart';
import '../../domain/repositories/appointment_repository.dart';
import 'appointment_state.dart';

class AppointmentCubit extends Cubit<AppointmentState> {
  final AppointmentRepository repository;

  AppointmentCubit(this.repository) : super(AppointmentInitial());

  Future<String> book(Appointment appointment) async {
    emit(AppointmentLoading());
    final id = await repository.saveAppointment(appointment);
    emit(AppointmentSuccess());
    return id;
  }

  Future<void> loadAppointments(String userId) async {
    emit(AppointmentLoading());
    try {
      final appointments = await repository.getUserAppointments(userId);
      emit(AppointmentsLoaded(appointments));
    } catch (e, s) {
      debugPrint('❌ Failed to load appointments');
      debugPrint(e.toString());
      debugPrint(s.toString());
      emit(AppointmentError('Failed to load appointments'));
    }
  }
}
