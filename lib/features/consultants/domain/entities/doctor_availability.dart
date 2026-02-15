/// Day of week: 1 = Monday, 7 = Sunday (DateTime.weekday).
/// [slots] e.g. ["09:00", "09:30", "10:00"]
class DoctorAvailability {
  final int dayOfWeek;
  final List<String> slots;

  const DoctorAvailability({
    required this.dayOfWeek,
    required this.slots,
  });
}
