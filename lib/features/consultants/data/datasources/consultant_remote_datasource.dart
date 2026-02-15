import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/doctor_model.dart';
import '../models/appointment_model.dart';

class ConsultantRemoteDatasource {
  final FirebaseFirestore firestore;

  ConsultantRemoteDatasource(this.firestore);

  /// [specialty] null = all doctors.
  Future<List<DoctorModel>> getDoctors({String? specialty}) async {
    Query<Map<String, dynamic>> q = firestore.collection('doctors');
    if (specialty != null && specialty.isNotEmpty) {
      q = q.where('speciality', isEqualTo: specialty);
    }
    final snapshot = await q.get();
    return snapshot.docs
        .map((e) => DoctorModel.fromJson(e.id, e.data()))
        .toList();
  }

  /// Returns document id of the created appointment.
  Future<String> bookAppointment(AppointmentModel appointment) async {
    final ref = await firestore.collection('appointments').add(appointment.toJson());
    return ref.id;
  }

  /// Booked time slots for a doctor on a given date (e.g. ["09:00", "10:30"]).
  /// Use appointmentDate at midnight (local or UTC consistently) for query.
  Future<List<String>> getBookedSlots(String doctorId, DateTime date) async {
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
