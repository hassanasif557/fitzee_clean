import 'package:fitzee_new/core/models/food_item.dart';
import 'package:fitzee_new/core/models/food_nutrition.dart';

/// Service to manage nutrition database
/// Contains common foods with nutrition data per 100g
class NutritionDatabaseService {
  // Portion size to grams mapping
  static const Map<String, double> portionToGrams = {
    'cup': 158,
    'plate': 200,
    'bowl': 250,
    'tablespoon': 15,
    'teaspoon': 5,
    'piece': 100,
    'slice': 30,
    'serving': 150,
    'small': 100,
    'medium': 150,
    'large': 200,
    'half': 100,
    'quarter': 50,
  };

  /// Get all available foods
  static List<FoodItem> getAllFoods() {
    return _foodDatabase;
  }

  /// Search foods by name
  static List<FoodItem> searchFoods(String query) {
    final lowerQuery = query.toLowerCase();
    return _foodDatabase.where((food) {
      return food.name.toLowerCase().contains(lowerQuery) ||
          food.category.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Get food by ID
  static FoodItem? getFoodById(String id) {
    try {
      return _foodDatabase.firstWhere((food) => food.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get foods by category
  static List<FoodItem> getFoodsByCategory(String category) {
    return _foodDatabase.where((food) => food.category == category).toList();
  }

  /// Get all categories
  static List<String> getCategories() {
    return _foodDatabase.map((food) => food.category).toSet().toList();
  }

  /// Get portion size in grams
  static double? getPortionGrams(String portionType) {
    return portionToGrams[portionType.toLowerCase()];
  }

  /// Get all available portion types
  static List<String> getPortionTypes() {
    return portionToGrams.keys.toList();
  }

  // Nutrition Database - Common foods (per 100g)
  // Based on USDA FoodData Central and common nutrition databases
  static final List<FoodItem> _foodDatabase = [
    // Grains & Cereals
    FoodItem(
      id: 'rice_white_cooked',
      name: 'White Rice (Cooked)',
      category: 'grains',
      nutritionPer100g: FoodNutrition(
        calories: 130,
        protein: 2.7,
        carbs: 28,
        fat: 0.3,
        fiber: 0.4,
      ),
    ),
    FoodItem(
      id: 'rice_brown_cooked',
      name: 'Brown Rice (Cooked)',
      category: 'grains',
      nutritionPer100g: FoodNutrition(
        calories: 111,
        protein: 2.6,
        carbs: 23,
        fat: 0.9,
        fiber: 1.8,
      ),
    ),
    FoodItem(
      id: 'bread_white',
      name: 'White Bread',
      category: 'grains',
      nutritionPer100g: FoodNutrition(
        calories: 265,
        protein: 9,
        carbs: 49,
        fat: 3.2,
        fiber: 2.7,
      ),
    ),
    FoodItem(
      id: 'bread_whole_wheat',
      name: 'Whole Wheat Bread',
      category: 'grains',
      nutritionPer100g: FoodNutrition(
        calories: 247,
        protein: 13,
        carbs: 41,
        fat: 4.2,
        fiber: 7,
      ),
    ),
    FoodItem(
      id: 'pasta_cooked',
      name: 'Pasta (Cooked)',
      category: 'grains',
      nutritionPer100g: FoodNutrition(
        calories: 131,
        protein: 5,
        carbs: 25,
        fat: 1.1,
        fiber: 1.8,
      ),
    ),
    FoodItem(
      id: 'oats_cooked',
      name: 'Oats (Cooked)',
      category: 'grains',
      nutritionPer100g: FoodNutrition(
        calories: 68,
        protein: 2.4,
        carbs: 12,
        fat: 1.4,
        fiber: 1.7,
      ),
    ),

    // Proteins
    FoodItem(
      id: 'chicken_breast_cooked',
      name: 'Chicken Breast (Cooked)',
      category: 'protein',
      nutritionPer100g: FoodNutrition(
        calories: 165,
        protein: 31,
        carbs: 0,
        fat: 3.6,
      ),
    ),
    FoodItem(
      id: 'chicken_thigh_cooked',
      name: 'Chicken Thigh (Cooked)',
      category: 'protein',
      nutritionPer100g: FoodNutrition(
        calories: 209,
        protein: 26,
        carbs: 0,
        fat: 10.9,
      ),
    ),
    FoodItem(
      id: 'beef_cooked',
      name: 'Beef (Cooked)',
      category: 'protein',
      nutritionPer100g: FoodNutrition(
        calories: 250,
        protein: 26,
        carbs: 0,
        fat: 15,
      ),
    ),
    FoodItem(
      id: 'fish_salmon_cooked',
      name: 'Salmon (Cooked)',
      category: 'protein',
      nutritionPer100g: FoodNutrition(
        calories: 206,
        protein: 25,
        carbs: 0,
        fat: 12,
      ),
    ),
    FoodItem(
      id: 'eggs',
      name: 'Eggs',
      category: 'protein',
      nutritionPer100g: FoodNutrition(
        calories: 155,
        protein: 13,
        carbs: 1.1,
        fat: 11,
      ),
    ),
    FoodItem(
      id: 'tofu',
      name: 'Tofu',
      category: 'protein',
      nutritionPer100g: FoodNutrition(
        calories: 76,
        protein: 8,
        carbs: 1.9,
        fat: 4.8,
      ),
    ),
    FoodItem(
      id: 'lentils_cooked',
      name: 'Lentils (Cooked)',
      category: 'protein',
      nutritionPer100g: FoodNutrition(
        calories: 116,
        protein: 9,
        carbs: 20,
        fat: 0.4,
        fiber: 7.9,
      ),
    ),
    FoodItem(
      id: 'chickpeas_cooked',
      name: 'Chickpeas (Cooked)',
      category: 'protein',
      nutritionPer100g: FoodNutrition(
        calories: 164,
        protein: 8.9,
        carbs: 27,
        fat: 2.6,
        fiber: 7.6,
      ),
    ),

    // Vegetables
    FoodItem(
      id: 'broccoli',
      name: 'Broccoli',
      category: 'vegetables',
      nutritionPer100g: FoodNutrition(
        calories: 34,
        protein: 2.8,
        carbs: 7,
        fat: 0.4,
        fiber: 2.6,
      ),
    ),
    FoodItem(
      id: 'spinach',
      name: 'Spinach',
      category: 'vegetables',
      nutritionPer100g: FoodNutrition(
        calories: 23,
        protein: 2.9,
        carbs: 3.6,
        fat: 0.4,
        fiber: 2.2,
      ),
    ),
    FoodItem(
      id: 'carrots',
      name: 'Carrots',
      category: 'vegetables',
      nutritionPer100g: FoodNutrition(
        calories: 41,
        protein: 0.9,
        carbs: 10,
        fat: 0.2,
        fiber: 2.8,
      ),
    ),
    FoodItem(
      id: 'tomatoes',
      name: 'Tomatoes',
      category: 'vegetables',
      nutritionPer100g: FoodNutrition(
        calories: 18,
        protein: 0.9,
        carbs: 3.9,
        fat: 0.2,
        fiber: 1.2,
      ),
    ),
    FoodItem(
      id: 'potatoes',
      name: 'Potatoes',
      category: 'vegetables',
      nutritionPer100g: FoodNutrition(
        calories: 77,
        protein: 2,
        carbs: 17,
        fat: 0.1,
        fiber: 2.2,
      ),
    ),
    FoodItem(
      id: 'onions',
      name: 'Onions',
      category: 'vegetables',
      nutritionPer100g: FoodNutrition(
        calories: 40,
        protein: 1.1,
        carbs: 9.3,
        fat: 0.1,
        fiber: 1.7,
      ),
    ),

    // Fruits
    FoodItem(
      id: 'apple',
      name: 'Apple',
      category: 'fruits',
      nutritionPer100g: FoodNutrition(
        calories: 52,
        protein: 0.3,
        carbs: 14,
        fat: 0.2,
        fiber: 2.4,
      ),
    ),
    FoodItem(
      id: 'banana',
      name: 'Banana',
      category: 'fruits',
      nutritionPer100g: FoodNutrition(
        calories: 89,
        protein: 1.1,
        carbs: 23,
        fat: 0.3,
        fiber: 2.6,
      ),
    ),
    FoodItem(
      id: 'orange',
      name: 'Orange',
      category: 'fruits',
      nutritionPer100g: FoodNutrition(
        calories: 47,
        protein: 0.9,
        carbs: 12,
        fat: 0.1,
        fiber: 2.4,
      ),
    ),
    FoodItem(
      id: 'grapes',
      name: 'Grapes',
      category: 'fruits',
      nutritionPer100g: FoodNutrition(
        calories: 69,
        protein: 0.7,
        carbs: 18,
        fat: 0.2,
        fiber: 0.9,
      ),
    ),

    // Dairy
    FoodItem(
      id: 'milk_whole',
      name: 'Whole Milk',
      category: 'dairy',
      nutritionPer100g: FoodNutrition(
        calories: 61,
        protein: 3.2,
        carbs: 4.8,
        fat: 3.3,
      ),
    ),
    FoodItem(
      id: 'milk_skim',
      name: 'Skim Milk',
      category: 'dairy',
      nutritionPer100g: FoodNutrition(
        calories: 34,
        protein: 3.4,
        carbs: 5,
        fat: 0.1,
      ),
    ),
    FoodItem(
      id: 'yogurt',
      name: 'Yogurt',
      category: 'dairy',
      nutritionPer100g: FoodNutrition(
        calories: 59,
        protein: 10,
        carbs: 3.6,
        fat: 0.4,
      ),
    ),
    FoodItem(
      id: 'cheese',
      name: 'Cheese',
      category: 'dairy',
      nutritionPer100g: FoodNutrition(
        calories: 402,
        protein: 25,
        carbs: 1.3,
        fat: 33,
      ),
    ),

    // Nuts & Seeds
    FoodItem(
      id: 'almonds',
      name: 'Almonds',
      category: 'nuts',
      nutritionPer100g: FoodNutrition(
        calories: 579,
        protein: 21,
        carbs: 22,
        fat: 50,
        fiber: 12,
      ),
    ),
    FoodItem(
      id: 'peanuts',
      name: 'Peanuts',
      category: 'nuts',
      nutritionPer100g: FoodNutrition(
        calories: 567,
        protein: 26,
        carbs: 16,
        fat: 49,
        fiber: 8.5,
      ),
    ),

    // Oils & Fats
    FoodItem(
      id: 'olive_oil',
      name: 'Olive Oil',
      category: 'fats',
      nutritionPer100g: FoodNutrition(
        calories: 884,
        protein: 0,
        carbs: 0,
        fat: 100,
      ),
    ),
    FoodItem(
      id: 'butter',
      name: 'Butter',
      category: 'fats',
      nutritionPer100g: FoodNutrition(
        calories: 717,
        protein: 0.9,
        carbs: 0.1,
        fat: 81,
      ),
    ),

    // Desserts & Sweets
    FoodItem(
      id: 'cake_chocolate',
      name: 'Chocolate Cake',
      category: 'desserts',
      nutritionPer100g: FoodNutrition(
        calories: 389,
        protein: 5.3,
        carbs: 52,
        fat: 18,
        fiber: 2.3,
      ),
    ),
    FoodItem(
      id: 'cake_vanilla',
      name: 'Vanilla Cake',
      category: 'desserts',
      nutritionPer100g: FoodNutrition(
        calories: 350,
        protein: 4.5,
        carbs: 50,
        fat: 15,
        fiber: 1.2,
      ),
    ),
    FoodItem(
      id: 'ice_cream',
      name: 'Ice Cream',
      category: 'desserts',
      nutritionPer100g: FoodNutrition(
        calories: 207,
        protein: 3.5,
        carbs: 24,
        fat: 11,
      ),
    ),
    FoodItem(
      id: 'cookies_chocolate_chip',
      name: 'Chocolate Chip Cookies',
      category: 'desserts',
      nutritionPer100g: FoodNutrition(
        calories: 488,
        protein: 6.1,
        carbs: 68,
        fat: 22,
        fiber: 2.4,
      ),
    ),
    FoodItem(
      id: 'donut',
      name: 'Donut',
      category: 'desserts',
      nutritionPer100g: FoodNutrition(
        calories: 452,
        protein: 5.3,
        carbs: 51,
        fat: 25,
        fiber: 1.7,
      ),
    ),
    FoodItem(
      id: 'chocolate_bar',
      name: 'Chocolate Bar',
      category: 'desserts',
      nutritionPer100g: FoodNutrition(
        calories: 546,
        protein: 7.6,
        carbs: 54,
        fat: 31,
        fiber: 5.4,
      ),
    ),
    FoodItem(
      id: 'pie_apple',
      name: 'Apple Pie',
      category: 'desserts',
      nutritionPer100g: FoodNutrition(
        calories: 265,
        protein: 2.4,
        carbs: 37,
        fat: 12,
        fiber: 1.6,
      ),
    ),
    FoodItem(
      id: 'brownie',
      name: 'Brownie',
      category: 'desserts',
      nutritionPer100g: FoodNutrition(
        calories: 466,
        protein: 6.2,
        carbs: 50,
        fat: 29,
        fiber: 3.1,
      ),
    ),
    FoodItem(
      id: 'pudding',
      name: 'Pudding',
      category: 'desserts',
      nutritionPer100g: FoodNutrition(
        calories: 142,
        protein: 2.6,
        carbs: 20,
        fat: 5.4,
      ),
    ),

    // Beverages
    FoodItem(
      id: 'orange_juice',
      name: 'Orange Juice',
      category: 'beverages',
      nutritionPer100g: FoodNutrition(
        calories: 45,
        protein: 0.7,
        carbs: 11,
        fat: 0.2,
        fiber: 0.2,
      ),
    ),
    FoodItem(
      id: 'apple_juice',
      name: 'Apple Juice',
      category: 'beverages',
      nutritionPer100g: FoodNutrition(
        calories: 46,
        protein: 0.1,
        carbs: 11,
        fat: 0.1,
        fiber: 0.2,
      ),
    ),
    FoodItem(
      id: 'soda_cola',
      name: 'Cola Soda',
      category: 'beverages',
      nutritionPer100g: FoodNutrition(
        calories: 42,
        protein: 0,
        carbs: 11,
        fat: 0,
      ),
    ),
    FoodItem(
      id: 'coffee',
      name: 'Coffee (Black)',
      category: 'beverages',
      nutritionPer100g: FoodNutrition(
        calories: 2,
        protein: 0.1,
        carbs: 0,
        fat: 0,
      ),
    ),
    FoodItem(
      id: 'tea',
      name: 'Tea',
      category: 'beverages',
      nutritionPer100g: FoodNutrition(
        calories: 2,
        protein: 0,
        carbs: 0.3,
        fat: 0,
      ),
    ),
    FoodItem(
      id: 'smoothie',
      name: 'Fruit Smoothie',
      category: 'beverages',
      nutritionPer100g: FoodNutrition(
        calories: 37,
        protein: 0.4,
        carbs: 9,
        fat: 0.1,
        fiber: 0.4,
      ),
    ),
    FoodItem(
      id: 'energy_drink',
      name: 'Energy Drink',
      category: 'beverages',
      nutritionPer100g: FoodNutrition(
        calories: 45,
        protein: 0,
        carbs: 11,
        fat: 0,
      ),
    ),

    // Snacks
    FoodItem(
      id: 'potato_chips',
      name: 'Potato Chips',
      category: 'snacks',
      nutritionPer100g: FoodNutrition(
        calories: 536,
        protein: 7,
        carbs: 53,
        fat: 35,
        fiber: 4.4,
      ),
    ),
    FoodItem(
      id: 'popcorn',
      name: 'Popcorn',
      category: 'snacks',
      nutritionPer100g: FoodNutrition(
        calories: 387,
        protein: 12,
        carbs: 78,
        fat: 4.5,
        fiber: 15,
      ),
    ),
    FoodItem(
      id: 'crackers',
      name: 'Crackers',
      category: 'snacks',
      nutritionPer100g: FoodNutrition(
        calories: 455,
        protein: 9.6,
        carbs: 61,
        fat: 18,
        fiber: 2.3,
      ),
    ),
    FoodItem(
      id: 'pretzels',
      name: 'Pretzels',
      category: 'snacks',
      nutritionPer100g: FoodNutrition(
        calories: 384,
        protein: 10.7,
        carbs: 80,
        fat: 2.9,
        fiber: 2.8,
      ),
    ),
    FoodItem(
      id: 'granola_bar',
      name: 'Granola Bar',
      category: 'snacks',
      nutritionPer100g: FoodNutrition(
        calories: 471,
        protein: 10,
        carbs: 64,
        fat: 20,
        fiber: 4.9,
      ),
    ),
    FoodItem(
      id: 'trail_mix',
      name: 'Trail Mix',
      category: 'snacks',
      nutritionPer100g: FoodNutrition(
        calories: 462,
        protein: 13,
        carbs: 44,
        fat: 30,
        fiber: 4.6,
      ),
    ),

    // Fast Food
    FoodItem(
      id: 'burger',
      name: 'Hamburger',
      category: 'fast_food',
      nutritionPer100g: FoodNutrition(
        calories: 295,
        protein: 17,
        carbs: 30,
        fat: 12,
        fiber: 1.5,
      ),
    ),
    FoodItem(
      id: 'pizza_slice',
      name: 'Pizza Slice',
      category: 'fast_food',
      nutritionPer100g: FoodNutrition(
        calories: 266,
        protein: 11,
        carbs: 33,
        fat: 10,
        fiber: 2.3,
      ),
    ),
    FoodItem(
      id: 'french_fries',
      name: 'French Fries',
      category: 'fast_food',
      nutritionPer100g: FoodNutrition(
        calories: 312,
        protein: 3.4,
        carbs: 41,
        fat: 15,
        fiber: 3.8,
      ),
    ),
    FoodItem(
      id: 'fried_chicken',
      name: 'Fried Chicken',
      category: 'fast_food',
      nutritionPer100g: FoodNutrition(
        calories: 246,
        protein: 20,
        carbs: 9.4,
        fat: 13,
        fiber: 0.5,
      ),
    ),
    FoodItem(
      id: 'hot_dog',
      name: 'Hot Dog',
      category: 'fast_food',
      nutritionPer100g: FoodNutrition(
        calories: 290,
        protein: 10,
        carbs: 18,
        fat: 20,
        fiber: 0.5,
      ),
    ),
    FoodItem(
      id: 'taco',
      name: 'Taco',
      category: 'fast_food',
      nutritionPer100g: FoodNutrition(
        calories: 226,
        protein: 9.1,
        carbs: 20,
        fat: 12,
        fiber: 2.1,
      ),
    ),
    FoodItem(
      id: 'sandwich',
      name: 'Sandwich',
      category: 'fast_food',
      nutritionPer100g: FoodNutrition(
        calories: 250,
        protein: 10,
        carbs: 30,
        fat: 10,
        fiber: 2.5,
      ),
    ),

    // More Grains
    FoodItem(
      id: 'quinoa_cooked',
      name: 'Quinoa (Cooked)',
      category: 'grains',
      nutritionPer100g: FoodNutrition(
        calories: 120,
        protein: 4.4,
        carbs: 22,
        fat: 1.9,
        fiber: 2.8,
      ),
    ),
    FoodItem(
      id: 'barley_cooked',
      name: 'Barley (Cooked)',
      category: 'grains',
      nutritionPer100g: FoodNutrition(
        calories: 123,
        protein: 2.3,
        carbs: 28,
        fat: 0.4,
        fiber: 3.8,
      ),
    ),
    FoodItem(
      id: 'couscous_cooked',
      name: 'Couscous (Cooked)',
      category: 'grains',
      nutritionPer100g: FoodNutrition(
        calories: 112,
        protein: 3.8,
        carbs: 23,
        fat: 0.2,
        fiber: 1.4,
      ),
    ),

    // More Proteins
    FoodItem(
      id: 'turkey_cooked',
      name: 'Turkey (Cooked)',
      category: 'protein',
      nutritionPer100g: FoodNutrition(
        calories: 189,
        protein: 29,
        carbs: 0,
        fat: 7.4,
      ),
    ),
    FoodItem(
      id: 'pork_cooked',
      name: 'Pork (Cooked)',
      category: 'protein',
      nutritionPer100g: FoodNutrition(
        calories: 242,
        protein: 27,
        carbs: 0,
        fat: 14,
      ),
    ),
    FoodItem(
      id: 'shrimp_cooked',
      name: 'Shrimp (Cooked)',
      category: 'protein',
      nutritionPer100g: FoodNutrition(
        calories: 99,
        protein: 24,
        carbs: 0.2,
        fat: 0.3,
      ),
    ),
    FoodItem(
      id: 'tuna_canned',
      name: 'Tuna (Canned)',
      category: 'protein',
      nutritionPer100g: FoodNutrition(
        calories: 116,
        protein: 26,
        carbs: 0,
        fat: 0.8,
      ),
    ),
    FoodItem(
      id: 'beans_black_cooked',
      name: 'Black Beans (Cooked)',
      category: 'protein',
      nutritionPer100g: FoodNutrition(
        calories: 132,
        protein: 8.9,
        carbs: 24,
        fat: 0.5,
        fiber: 8.7,
      ),
    ),
    FoodItem(
      id: 'beans_kidney_cooked',
      name: 'Kidney Beans (Cooked)',
      category: 'protein',
      nutritionPer100g: FoodNutrition(
        calories: 127,
        protein: 8.7,
        carbs: 23,
        fat: 0.5,
        fiber: 6.4,
      ),
    ),

    // More Vegetables
    FoodItem(
      id: 'bell_pepper',
      name: 'Bell Pepper',
      category: 'vegetables',
      nutritionPer100g: FoodNutrition(
        calories: 31,
        protein: 1,
        carbs: 7,
        fat: 0.3,
        fiber: 2.5,
      ),
    ),
    FoodItem(
      id: 'cucumber',
      name: 'Cucumber',
      category: 'vegetables',
      nutritionPer100g: FoodNutrition(
        calories: 16,
        protein: 0.7,
        carbs: 4,
        fat: 0.1,
        fiber: 0.5,
      ),
    ),
    FoodItem(
      id: 'lettuce',
      name: 'Lettuce',
      category: 'vegetables',
      nutritionPer100g: FoodNutrition(
        calories: 15,
        protein: 1.4,
        carbs: 2.9,
        fat: 0.2,
        fiber: 1.3,
      ),
    ),
    FoodItem(
      id: 'mushrooms',
      name: 'Mushrooms',
      category: 'vegetables',
      nutritionPer100g: FoodNutrition(
        calories: 22,
        protein: 3.1,
        carbs: 3.3,
        fat: 0.3,
        fiber: 1,
      ),
    ),
    FoodItem(
      id: 'zucchini',
      name: 'Zucchini',
      category: 'vegetables',
      nutritionPer100g: FoodNutrition(
        calories: 17,
        protein: 1.2,
        carbs: 3.4,
        fat: 0.3,
        fiber: 1,
      ),
    ),
    FoodItem(
      id: 'corn',
      name: 'Corn',
      category: 'vegetables',
      nutritionPer100g: FoodNutrition(
        calories: 86,
        protein: 3.3,
        carbs: 19,
        fat: 1.2,
        fiber: 2.7,
      ),
    ),

    // More Fruits
    FoodItem(
      id: 'strawberries',
      name: 'Strawberries',
      category: 'fruits',
      nutritionPer100g: FoodNutrition(
        calories: 32,
        protein: 0.7,
        carbs: 8,
        fat: 0.3,
        fiber: 2,
      ),
    ),
    FoodItem(
      id: 'blueberries',
      name: 'Blueberries',
      category: 'fruits',
      nutritionPer100g: FoodNutrition(
        calories: 57,
        protein: 0.7,
        carbs: 14,
        fat: 0.3,
        fiber: 2.4,
      ),
    ),
    FoodItem(
      id: 'mango',
      name: 'Mango',
      category: 'fruits',
      nutritionPer100g: FoodNutrition(
        calories: 60,
        protein: 0.8,
        carbs: 15,
        fat: 0.4,
        fiber: 1.6,
      ),
    ),
    FoodItem(
      id: 'pineapple',
      name: 'Pineapple',
      category: 'fruits',
      nutritionPer100g: FoodNutrition(
        calories: 50,
        protein: 0.5,
        carbs: 13,
        fat: 0.1,
        fiber: 1.4,
      ),
    ),
    FoodItem(
      id: 'watermelon',
      name: 'Watermelon',
      category: 'fruits',
      nutritionPer100g: FoodNutrition(
        calories: 30,
        protein: 0.6,
        carbs: 8,
        fat: 0.2,
        fiber: 0.4,
      ),
    ),
    FoodItem(
      id: 'avocado',
      name: 'Avocado',
      category: 'fruits',
      nutritionPer100g: FoodNutrition(
        calories: 160,
        protein: 2,
        carbs: 9,
        fat: 15,
        fiber: 7,
      ),
    ),

    // More Dairy
    FoodItem(
      id: 'cottage_cheese',
      name: 'Cottage Cheese',
      category: 'dairy',
      nutritionPer100g: FoodNutrition(
        calories: 98,
        protein: 11,
        carbs: 3.4,
        fat: 4.3,
      ),
    ),
    FoodItem(
      id: 'greek_yogurt',
      name: 'Greek Yogurt',
      category: 'dairy',
      nutritionPer100g: FoodNutrition(
        calories: 59,
        protein: 10,
        carbs: 3.6,
        fat: 0.4,
      ),
    ),

    // More Nuts
    FoodItem(
      id: 'walnuts',
      name: 'Walnuts',
      category: 'nuts',
      nutritionPer100g: FoodNutrition(
        calories: 654,
        protein: 15,
        carbs: 14,
        fat: 65,
        fiber: 6.7,
      ),
    ),
    FoodItem(
      id: 'cashews',
      name: 'Cashews',
      category: 'nuts',
      nutritionPer100g: FoodNutrition(
        calories: 553,
        protein: 18,
        carbs: 30,
        fat: 44,
        fiber: 3.3,
      ),
    ),
    FoodItem(
      id: 'pistachios',
      name: 'Pistachios',
      category: 'nuts',
      nutritionPer100g: FoodNutrition(
        calories: 560,
        protein: 20,
        carbs: 28,
        fat: 45,
        fiber: 10,
      ),
    ),

    // Condiments & Sauces
    FoodItem(
      id: 'ketchup',
      name: 'Ketchup',
      category: 'condiments',
      nutritionPer100g: FoodNutrition(
        calories: 112,
        protein: 1.7,
        carbs: 26,
        fat: 0.3,
        fiber: 0.4,
      ),
    ),
    FoodItem(
      id: 'mayonnaise',
      name: 'Mayonnaise',
      category: 'condiments',
      nutritionPer100g: FoodNutrition(
        calories: 680,
        protein: 1,
        carbs: 0.6,
        fat: 75,
      ),
    ),
    FoodItem(
      id: 'honey',
      name: 'Honey',
      category: 'condiments',
      nutritionPer100g: FoodNutrition(
        calories: 304,
        protein: 0.3,
        carbs: 82,
        fat: 0,
      ),
    ),
    FoodItem(
      id: 'peanut_butter',
      name: 'Peanut Butter',
      category: 'condiments',
      nutritionPer100g: FoodNutrition(
        calories: 588,
        protein: 25,
        carbs: 20,
        fat: 50,
        fiber: 6,
      ),
    ),
  ];
}
