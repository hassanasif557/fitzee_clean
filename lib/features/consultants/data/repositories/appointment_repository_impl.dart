import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/appointment.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../datasources/consultant_remote_datasource.dart';
import '../models/appointment_model.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final FirebaseFirestore firestore;
  final ConsultantRemoteDatasource? remoteDatasource;

  AppointmentRepositoryImpl(this.firestore, [this.remoteDatasource]);

  @override
  Future<String> saveAppointment(Appointment appointment) async {
    final model = AppointmentModel.fromEntity(appointment);
    if (remoteDatasource != null) {
      return remoteDatasource!.bookAppointment(model);
    }
    final ref = await firestore.collection('appointments').add(model.toJson());
    return ref.id;
  }

  @override
  Future<List<Appointment>> getUserAppointments(String userId) async {
    final snapshot = await firestore
        .collection('appointments')
        .where('userId', isEqualTo: userId)
        .orderBy('appointmentDate', descending: false)
        .get();

    return snapshot.docs
        .map((doc) => AppointmentModel.fromJson(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<List<String>> getBookedSlots(String doctorId, DateTime date) async {
    if (remoteDatasource != null) {
      return remoteDatasource!.getBookedSlots(doctorId, date);
    }
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final snapshot = await firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .where('appointmentDate', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('appointmentDate', isLessThan: Timestamp.fromDate(end))
        .get();
    return snapshot.docs
        .map((d) => d.data()['appointmentTime'] as String? ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
  }
}
