import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/consultant_repository.dart';
import 'consultant_state.dart';

class ConsultantCubit extends Cubit<ConsultantState> {
  final ConsultantRepository repository;

  ConsultantCubit(this.repository) : super(ConsultantLoading());

  /// [specialty] null or empty = all doctors.
  Future<void> loadDoctors({String? specialty}) async {
    try {
      final doctors = await repository.getDoctors(specialty: specialty);
      emit(ConsultantLoaded(doctors, selectedSpecialty: specialty));
    } catch (e, stackTrace) {
      debugPrint('❌ loadDoctors error: $e');
      debugPrintStack(stackTrace: stackTrace);
      emit(ConsultantError(e.toString()));
    }
  }
}

