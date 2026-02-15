/// A single medical info entry (blood pressure, sugar level, or custom).
/// Stores date, time, description/label, and value(s).
class MedicalEntry {
  final String id;
  final DateTime dateTime;
  /// 'blood_pressure' | 'sugar_level' | 'custom'
  final String type;
  final String label;
  /// For blood pressure: systolic. For sugar/custom: numeric value.
  final double? valuePrimary;
  /// For blood pressure: diastolic. Null for others.
  final int? valueSecondary;
  /// For custom text value (e.g. "70 kg").
  final String? valueText;
  /// Optional note/description.
  final String? description;

  MedicalEntry({
    required this.id,
    required this.dateTime,
    required this.type,
    required this.label,
    this.valuePrimary,
    this.valueSecondary,
    this.valueText,
    this.description,
  });

  /// Display value for list/detail (e.g. "120/80 mmHg", "100 mg/dL", "70 kg").
  String get displayValue {
    if (type == 'blood_pressure' &&
        valuePrimary != null &&
        valueSecondary != null) {
      return '${valuePrimary!.toInt()}/${valueSecondary} mmHg';
    }
    if (type == 'sugar_level' && valuePrimary != null) {
      return '${valuePrimary!.toStringAsFixed(0)} mg/dL';
    }
    if (valueText != null && valueText!.isNotEmpty) return valueText!;
    if (valuePrimary != null) return valuePrimary!.toStringAsFixed(1);
    return '—';
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id': id,
      'dateTime': dateTime.toIso8601String(),
      'type': type,
      'label': label,
    };
    if (valuePrimary != null) map['valuePrimary'] = valuePrimary;
    if (valueSecondary != null) map['valueSecondary'] = valueSecondary;
    if (valueText != null) map['valueText'] = valueText;
    if (description != null) map['description'] = description;
    return map;
  }

  factory MedicalEntry.fromJson(Map<String, dynamic> json) {
    return MedicalEntry(
      id: json['id'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      type: json['type'] as String,
      label: json['label'] as String,
      valuePrimary: json['valuePrimary'] != null
          ? (json['valuePrimary'] as num).toDouble()
          : null,
      valueSecondary: json['valueSecondary'] as int?,
      valueText: json['valueText'] as String?,
      description: json['description'] as String?,
    );
  }
}
