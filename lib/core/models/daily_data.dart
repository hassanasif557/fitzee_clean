/// Model for daily health data stored in Firestore
class DailyData {
  final String userId;
  final DateTime date;
  final int steps;
  final int calories;
  final double sleepHours;
  final int? healthScore;
  /// Optional: blood sugar level (e.g. mg/dL)
  final double? bloodSugar;
  /// Optional: blood pressure systolic (mmHg)
  final int? bloodPressureSystolic;
  /// Optional: blood pressure diastolic (mmHg)
  final int? bloodPressureDiastolic;
  /// Optional: minutes of exercise
  final int? exerciseMinutes;
  /// Optional: calories burned (e.g. from exercise) — separate from [calories] which is consumed
  final int? caloriesBurned;
  final DateTime createdAt;
  final DateTime updatedAt;

  DailyData({
    required this.userId,
    required this.date,
    required this.steps,
    required this.calories,
    required this.sleepHours,
    this.healthScore,
    this.bloodSugar,
    this.bloodPressureSystolic,
    this.bloodPressureDiastolic,
    this.exerciseMinutes,
    this.caloriesBurned,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'userId': userId,
      'date': date.toIso8601String(),
      'steps': steps,
      'calories': calories,
      'sleepHours': sleepHours,
      'healthScore': healthScore,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
    if (bloodSugar != null) map['bloodSugar'] = bloodSugar;
    if (bloodPressureSystolic != null) map['bloodPressureSystolic'] = bloodPressureSystolic;
    if (bloodPressureDiastolic != null) map['bloodPressureDiastolic'] = bloodPressureDiastolic;
    if (exerciseMinutes != null) map['exerciseMinutes'] = exerciseMinutes;
    if (caloriesBurned != null) map['caloriesBurned'] = caloriesBurned;
    return map;
  }

  factory DailyData.fromJson(Map<String, dynamic> json) {
    return DailyData(
      userId: json['userId'] as String,
      date: DateTime.parse(json['date'] as String),
      steps: (json['steps'] as num?)?.toInt() ?? 0,
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      sleepHours: (json['sleepHours'] as num?)?.toDouble() ?? 0,
      healthScore: json['healthScore'] as int?,
      bloodSugar: json['bloodSugar'] != null ? (json['bloodSugar'] as num).toDouble() : null,
      bloodPressureSystolic: json['bloodPressureSystolic'] as int?,
      bloodPressureDiastolic: json['bloodPressureDiastolic'] as int?,
      exerciseMinutes: json['exerciseMinutes'] as int?,
      caloriesBurned: json['caloriesBurned'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  DailyData copyWith({
    String? userId,
    DateTime? date,
    int? steps,
    int? calories,
    double? sleepHours,
    int? healthScore,
    double? bloodSugar,
    int? bloodPressureSystolic,
    int? bloodPressureDiastolic,
    int? exerciseMinutes,
    int? caloriesBurned,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailyData(
      userId: userId ?? this.userId,
      date: date ?? this.date,
      steps: steps ?? this.steps,
      calories: calories ?? this.calories,
      sleepHours: sleepHours ?? this.sleepHours,
      healthScore: healthScore ?? this.healthScore,
      bloodSugar: bloodSugar ?? this.bloodSugar,
      bloodPressureSystolic: bloodPressureSystolic ?? this.bloodPressureSystolic,
      bloodPressureDiastolic: bloodPressureDiastolic ?? this.bloodPressureDiastolic,
      exerciseMinutes: exerciseMinutes ?? this.exerciseMinutes,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Format date as YYYY-MM-DD for use as document ID
  static String formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

/// Model for daily nutrition data stored in Firestore
class DailyNutritionData {
  final String userId;
  final DateTime date;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final double? totalFiber;
  final int nutritionScore; // Calculated nutrition score (0-100)
  final DateTime createdAt;
  final DateTime updatedAt;

  DailyNutritionData({
    required this.userId,
    required this.date,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    this.totalFiber,
    required this.nutritionScore,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'date': date.toIso8601String(),
      'totalCalories': totalCalories,
      'totalProtein': totalProtein,
      'totalCarbs': totalCarbs,
      'totalFat': totalFat,
      'totalFiber': totalFiber,
      'nutritionScore': nutritionScore,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory DailyNutritionData.fromJson(Map<String, dynamic> json) {
    return DailyNutritionData(
      userId: json['userId'] as String,
      date: DateTime.parse(json['date'] as String),
      totalCalories: (json['totalCalories'] as num).toDouble(),
      totalProtein: (json['totalProtein'] as num).toDouble(),
      totalCarbs: (json['totalCarbs'] as num).toDouble(),
      totalFat: (json['totalFat'] as num).toDouble(),
      totalFiber: json['totalFiber'] != null ? (json['totalFiber'] as num).toDouble() : null,
      nutritionScore: json['nutritionScore'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  DailyNutritionData copyWith({
    String? userId,
    DateTime? date,
    double? totalCalories,
    double? totalProtein,
    double? totalCarbs,
    double? totalFat,
    double? totalFiber,
    int? nutritionScore,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailyNutritionData(
      userId: userId ?? this.userId,
      date: date ?? this.date,
      totalCalories: totalCalories ?? this.totalCalories,
      totalProtein: totalProtein ?? this.totalProtein,
      totalCarbs: totalCarbs ?? this.totalCarbs,
      totalFat: totalFat ?? this.totalFat,
      totalFiber: totalFiber ?? this.totalFiber,
      nutritionScore: nutritionScore ?? this.nutritionScore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
