import '../../domain/entities/doctor.dart';

abstract class ConsultantState {}

class ConsultantLoading extends ConsultantState {}

class ConsultantLoaded extends ConsultantState {
  final List<Doctor> doctors;
  final String? selectedSpecialty;
  ConsultantLoaded(this.doctors, {this.selectedSpecialty});
}

class ConsultantError extends ConsultantState {
  final String message;
  ConsultantError(this.message);
}

