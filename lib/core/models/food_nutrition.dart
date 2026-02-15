/// Model for food nutrition information
class FoodNutrition {
  final double calories;
  final double protein; // in grams
  final double carbs; // in grams
  final double fat; // in grams
  final double? fiber; // in grams (optional)

  FoodNutrition({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber,
  });

  /// Calculate nutrition for a given amount in grams
  /// Formula: value = (food_value_per_100g * grams) / 100
  FoodNutrition calculateForGrams(double grams) {
    return FoodNutrition(
      calories: (calories * grams) / 100,
      protein: (protein * grams) / 100,
      carbs: (carbs * grams) / 100,
      fat: (fat * grams) / 100,
      fiber: fiber != null ? (fiber! * grams) / 100 : null,
    );
  }

  /// Sum multiple nutrition items
  static FoodNutrition sum(List<FoodNutrition> items) {
    return FoodNutrition(
      calories: items.fold(0.0, (sum, item) => sum + item.calories),
      protein: items.fold(0.0, (sum, item) => sum + item.protein),
      carbs: items.fold(0.0, (sum, item) => sum + item.carbs),
      fat: items.fold(0.0, (sum, item) => sum + item.fat),
      fiber: items.any((item) => item.fiber != null)
          ? items.fold<double>(0.0, (sum, item) => sum + (item.fiber ?? 0.0))
          : null,
    );
  }

  /// Calculate macro calories
  /// Protein: 4 cal/g, Carbs: 4 cal/g, Fat: 9 cal/g
  double get macroCalories => (protein * 4) + (carbs * 4) + (fat * 9);

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
    };
  }

  /// Create from JSON
  factory FoodNutrition.fromJson(Map<String, dynamic> json) {
    return FoodNutrition(
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      fiber: json['fiber'] != null ? (json['fiber'] as num).toDouble() : null,
    );
  }

  FoodNutrition copyWith({
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    double? fiber,
  }) {
    return FoodNutrition(
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      fiber: fiber ?? this.fiber,
    );
  }
}

/// Model for a food item with portion
class FoodEntry {
  final String foodId;
  final String foodName;
  final String portionType;
  final double grams;
  final FoodNutrition nutrition;
  final DateTime date;
  final String mealType; // 'breakfast', 'lunch', 'dinner', 'snack'

  FoodEntry({
    required this.foodId,
    required this.foodName,
    required this.portionType,
    required this.grams,
    required this.nutrition,
    required this.date,
    required this.mealType,
  });

  Map<String, dynamic> toJson() {
    return {
      'foodId': foodId,
      'foodName': foodName,
      'portionType': portionType,
      'grams': grams,
      'nutrition': nutrition.toJson(),
      'date': date.toIso8601String(),
      'mealType': mealType,
    };
  }

  factory FoodEntry.fromJson(Map<String, dynamic> json) {
    return FoodEntry(
      foodId: json['foodId'] as String,
      foodName: json['foodName'] as String,
      portionType: json['portionType'] as String,
      grams: (json['grams'] as num).toDouble(),
      nutrition: FoodNutrition.fromJson(json['nutrition'] as Map<String, dynamic>),
      date: DateTime.parse(json['date'] as String),
      mealType: json['mealType'] as String,
    );
  }
}
