import 'food_nutrition.dart';

/// Model for a food item in the database
class FoodItem {
  final String id;
  final String name;
  final String category; // 'grains', 'protein', 'vegetables', 'fruits', 'dairy', etc.
  final FoodNutrition nutritionPer100g;

  FoodItem({
    required this.id,
    required this.name,
    required this.category,
    required this.nutritionPer100g,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'nutritionPer100g': nutritionPer100g.toJson(),
    };
  }

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      nutritionPer100g: FoodNutrition.fromJson(json['nutritionPer100g'] as Map<String, dynamic>),
    );
  }
}
