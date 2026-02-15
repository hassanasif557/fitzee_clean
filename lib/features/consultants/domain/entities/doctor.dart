import 'doctor_availability.dart';

class Doctor {
  final String id;
  final String name;
  final String speciality;
  final double rating;
  final int reviews;
  final int pricePerHour;
  /// Legacy: used when [availability] is empty (e.g. old Firestore data).
  final List<String> availableTimes;
  /// Per-day time slots. dayOfWeek 1=Mon..7=Sun. Used for date/slot booking.
  final List<DoctorAvailability> availability;
  final String imageUrl;
  final int yearsExperience;
  final int patients;
  final String bio;
  final bool aiEnabled;

  Doctor({
    required this.id,
    required this.name,
    required this.speciality,
    required this.rating,
    required this.reviews,
    required this.pricePerHour,
    required this.availableTimes,
    List<DoctorAvailability>? availability,
    required this.imageUrl,
    required this.yearsExperience,
    required this.patients,
    required this.bio,
    required this.aiEnabled,
  }) : availability = availability ?? const [];

  /// Slots for a given weekday (1=Mon..7=Sun). Uses [availability] or [availableTimes].
  List<String> slotsForWeekday(int dayOfWeek) {
    final day = availability.where((a) => a.dayOfWeek == dayOfWeek).toList();
    if (day.isNotEmpty) return day.expand((e) => e.slots).toSet().toList()..sort();
    return availableTimes;
  }

  /// Weekdays this doctor has availability (1=Mon..7=Sun).
  List<int> get availableWeekdays {
    if (availability.isEmpty) return List.generate(7, (i) => i + 1);
    return availability.map((a) => a.dayOfWeek).toSet().toList()..sort();
  }
}
