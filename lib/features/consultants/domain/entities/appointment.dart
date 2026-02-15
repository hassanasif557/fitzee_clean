class Appointment {
  /// Firestore document id (null for new appointments).
  final String? id;
  final String doctorId;
  final String doctorName;
  final String userId;
  final String appointmentTime;
  final DateTime appointmentDate;
  final int price;
  final String status;
  final String paymentStatus;
  final DateTime createdAt;

  Appointment({
    this.id,
    required this.doctorId,
    required this.doctorName,
    required this.userId,
    required this.appointmentTime,
    required this.appointmentDate,
    required this.price,
    required this.status,
    required this.paymentStatus,
    required this.createdAt,
  });
}
