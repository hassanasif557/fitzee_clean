import '../../domain/entities/doctor_availability.dart';

class DoctorAvailabilityModel extends DoctorAvailability {
  DoctorAvailabilityModel({
    required super.dayOfWeek,
    required super.slots,
  });

  static List<DoctorAvailability> fromJsonList(dynamic value) {
    if (value is! List) return [];
    final list = <DoctorAvailability>[];
    for (final e in value) {
      if (e is Map<String, dynamic>) {
        final day = _toInt(e['dayOfWeek']);
        final slots = _toStringList(e['slots']);
        if (day >= 1 && day <= 7 && slots.isNotEmpty) {
          list.add(DoctorAvailabilityModel(dayOfWeek: day, slots: slots));
        }
      }
    }
    return list;
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  static List<String> _toStringList(dynamic value) {
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }
}
