import '../entities/doctor.dart';
import '../entities/appointment.dart';

abstract class ConsultantRepository {
  /// [specialty] null = all doctors.
  Future<List<Doctor>> getDoctors({String? specialty});
  Future<String> bookAppointment(Appointment appointment);
}
