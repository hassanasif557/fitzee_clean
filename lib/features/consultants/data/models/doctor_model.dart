import '../../domain/entities/doctor.dart';
import 'doctor_availability_model.dart';

class DoctorModel extends Doctor {
  DoctorModel({
    required super.id,
    required super.name,
    required super.speciality,
    required super.rating,
    required super.reviews,
    required super.pricePerHour,
    required super.availableTimes,
    super.availability,
    required super.imageUrl,
    required super.yearsExperience,
    required super.patients,
    required super.bio,
    required super.aiEnabled,
  });

  factory DoctorModel.fromJson(String id, Map<String, dynamic> json) {
    int _toInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is double) return value.toInt();
      return 0;
    }

    double _toDouble(dynamic value) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    List<String> _toStringList(dynamic value) {
      if (value is List) return value.map((e) => e.toString()).toList();
      return [];
    }

    final availability = DoctorAvailabilityModel.fromJsonList(json['availability']);

    return DoctorModel(
      id: id,
      name: json['name'] ?? '',
      speciality: json['speciality'] ?? '',
      rating: _toDouble(json['rating']),
      reviews: _toInt(json['reviews']),
      pricePerHour: _toInt(json['pricePerHour']),
      availableTimes: _toStringList(json['availableTimes']),
      availability: availability.isNotEmpty ? availability : null,
      imageUrl: json['imageUrl'] ?? '',
      yearsExperience: _toInt(json['yearsExperience']),
      patients: _toInt(json['patients']),
      bio: json['bio'] ?? '',
      aiEnabled: json['aiEnabled'] ?? false,
    );
  }
}
