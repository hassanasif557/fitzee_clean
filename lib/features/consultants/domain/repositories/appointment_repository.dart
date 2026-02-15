import '../entities/appointment.dart';

abstract class AppointmentRepository {
  Future<String> saveAppointment(Appointment appointment);
  Future<List<Appointment>> getUserAppointments(String userId);
  Future<List<String>> getBookedSlots(String doctorId, DateTime date);
}
