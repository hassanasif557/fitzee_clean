/// Model for daily health data stored in Firestore
class DailyData {
  final String userId;
  final DateTime date;
  final int steps;
  final int calories;
  final double sleepHours;
  final int? healthScore; // Calculated health score for the day
  final DateTime createdAt;
  final DateTime updatedAt;

  DailyData({
    required this.userId,
    required this.date,
    required this.steps,
    required this.calories,
    required this.sleepHours,
    this.healthScore,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'date': date.toIso8601String(),
      'steps': steps,
      'calories': calories,
      'sleepHours': sleepHours,
      'healthScore': healthScore,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory DailyData.fromJson(Map<String, dynamic> json) {
    return DailyData(
      userId: json['userId'] as String,
      date: DateTime.parse(json['date'] as String),
      steps: json['steps'] as int,
      calories: json['calories'] as int,
      sleepHours: (json['sleepHours'] as num).toDouble(),
      healthScore: json['healthScore'] as int?,
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
