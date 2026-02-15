import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/appointment.dart';

class AppointmentModel extends Appointment {
  AppointmentModel({
    super.id,
    required super.doctorId,
    required super.doctorName,
    required super.userId,
    required super.appointmentTime,
    required super.appointmentDate,
    required super.price,
    required super.status,
    required super.paymentStatus,
    required super.createdAt,
  });

  factory AppointmentModel.fromEntity(Appointment appointment) {
    return AppointmentModel(
      id: appointment.id,
      doctorId: appointment.doctorId,
      doctorName: appointment.doctorName,
      userId: appointment.userId,
      appointmentTime: appointment.appointmentTime,
      appointmentDate: appointment.appointmentDate,
      price: appointment.price,
      status: appointment.status,
      paymentStatus: appointment.paymentStatus,
      createdAt: appointment.createdAt,
    );
  }

  factory AppointmentModel.fromJson(String? id, Map<String, dynamic> json) {
    DateTime _parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      return DateTime.now();
    }

    return AppointmentModel(
      id: id,
      doctorId: json['doctorId'] ?? '',
      doctorName: json['doctorName'] ?? '',
      userId: json['userId'] ?? '',
      appointmentTime: json['appointmentTime'] ?? '',
      appointmentDate: _parseDate(json['appointmentDate']),
      price: (json['price'] ?? 0) is int
          ? json['price']
          : int.tryParse(json['price'].toString()) ?? 0,
      status: json['status'] ?? 'pending',
      paymentStatus: json['paymentStatus'] ?? 'unpaid',
      createdAt: _parseDate(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'doctorId': doctorId,
      'doctorName': doctorName,
      'userId': userId,
      'appointmentTime': appointmentTime,
      'appointmentDate': Timestamp.fromDate(appointmentDate),
      'price': price,
      'status': status,
      'paymentStatus': paymentStatus,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
