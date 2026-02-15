import '../../domain/entities/doctor.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/repositories/consultant_repository.dart';
import '../datasources/consultant_remote_datasource.dart';
import '../models/appointment_model.dart';

class ConsultantRepositoryImpl implements ConsultantRepository {
  final ConsultantRemoteDatasource datasource;

  ConsultantRepositoryImpl(this.datasource);

  @override
  Future<List<Doctor>> getDoctors({String? specialty}) =>
      datasource.getDoctors(specialty: specialty);

  @override
  Future<String> bookAppointment(Appointment appointment) {
    return datasource.bookAppointment(
      AppointmentModel.fromEntity(appointment),
    );
  }
}
