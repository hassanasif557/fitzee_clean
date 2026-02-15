/// One meal slot (breakfast, lunch, or dinner) in a daily suggested meal plan.
/// [reason] explains why AI suggested this (e.g. diabetes-friendly, fat loss goal).
/// [alternatives] are replacement options if the user wants to swap this meal.
/// [precautions] are healthy-eating tips (e.g. limit paratha, use less oil).
class MealSlot {
  final String name;
  final String description;
  final int calories;
  final List<String> ingredients;
  final String instructions;
  /// Why this meal was suggested (user's goal, conditions, diet).
  final String reason;
  /// Replacement options if user wants a different meal for this slot.
  final List<String> alternatives;
  /// Healthy tips: portion limits, use less oil, etc. (especially for oily/fried items).
  final List<String> precautions;

  const MealSlot({
    required this.name,
    this.description = '',
    this.calories = 0,
    this.ingredients = const [],
    this.instructions = '',
    this.reason = '',
    this.alternatives = const [],
    this.precautions = const [],
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'calories': calories,
        'ingredients': ingredients,
        'instructions': instructions,
        'reason': reason,
        'alternatives': alternatives,
        'precautions': precautions,
      };

  factory MealSlot.fromJson(Map<String, dynamic> json) {
    final ing = json['ingredients'];
    final alt = json['alternatives'];
    final prec = json['precautions'];
    return MealSlot(
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      ingredients: ing is List ? ing.map((e) => e.toString()).toList() : [],
      instructions: json['instructions'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      alternatives: alt is List ? alt.map((e) => e.toString()).toList() : [],
      precautions: prec is List ? prec.map((e) => e.toString()).toList() : [],
    );
  }
}

/// Daily suggested meal plan: breakfast, lunch, dinner. From AI/backend.
class DailyMealPlan {
  final MealSlot? breakfast;
  final MealSlot? lunch;
  final MealSlot? dinner;
  final String? planName;
  final int dailyCalories;

  const DailyMealPlan({
    this.breakfast,
    this.lunch,
    this.dinner,
    this.planName,
    this.dailyCalories = 0,
  });

  bool get hasAnyMeal =>
      breakfast != null || lunch != null || dinner != null;

  /// Parses a backend slot: { meal, reason, alternatives } or legacy string/Map.
  static MealSlot? _parseSlot(String name, dynamic value) {
    if (value == null) return null;
    if (value is Map) {
      final m = Map<String, dynamic>.from(value);
      // New format: { meal, reason, alternatives }
      final mealStr = m['meal'] as String?;
      if (mealStr != null && mealStr.trim().isNotEmpty) {
        return MealSlot(
          name: name,
          description: mealStr.trim(),
          reason: (m['reason'] as String?)?.trim() ?? '',
          alternatives: m['alternatives'] is List
              ? (m['alternatives'] as List).map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList()
              : [],
          precautions: m['precautions'] is List
              ? (m['precautions'] as List).map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList()
              : [],
        );
      }
      // Legacy Map format (description, etc.)
      return MealSlot.fromJson(m..['name'] = name);
    }
    if (value is String && value.trim().isNotEmpty) {
      return MealSlot(name: name, description: value.trim());
    }
    return null;
  }

  static DailyMealPlan? fromBackendResponse(Map<String, dynamic> data) {
    try {
      MealSlot? breakfast = _parseSlot('Breakfast', data['breakfast']);
      MealSlot? lunch = _parseSlot('Lunch', data['lunch']);
      MealSlot? dinner = _parseSlot('Dinner', data['dinner']);
      if (breakfast == null && lunch == null && dinner == null) {
        final mealPlan = data['mealPlan'];
        if (mealPlan is String && mealPlan.isNotEmpty) {
          return DailyMealPlan(
            breakfast: MealSlot(
              name: 'Daily plan',
              description: mealPlan,
              instructions: '',
            ),
            planName: 'Suggested',
          );
        }
        return null;
      }
      return DailyMealPlan(
        breakfast: breakfast,
        lunch: lunch,
        dinner: dinner,
        planName: data['planName'] as String? ?? 'Suggested',
        dailyCalories: (data['dailyCalories'] as num?)?.toInt() ?? 0,
      );
    } catch (_) {
      return null;
    }
  }
}
