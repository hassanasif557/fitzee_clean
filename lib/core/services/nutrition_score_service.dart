import 'package:fitzee_new/core/models/food_nutrition.dart';
import 'package:fitzee_new/core/services/health_score_service.dart';
import 'package:fitzee_new/features/onboard/domain/entities/user_profile.dart';

/// Service to calculate nutrition scores based on macro ratios
class NutritionScoreService {
  /// Recommended macro ratios (as percentage of total calories)
  static const double carbsMinPercent = 45;
  static const double carbsMaxPercent = 65;
  static const double proteinMinPercent = 10;
  static const double proteinMaxPercent = 35;
  static const double fatMinPercent = 20;
  static const double fatMaxPercent = 35;

  /// Calculate nutrition score (0-100) based on macro balance
  static int calculateNutritionScore(FoodNutrition nutrition, UserProfile? profile) {
    final totalCalories = nutrition.macroCalories;
    
    if (totalCalories == 0) {
      return 50; // Neutral score if no data
    }

    // Calculate macro percentages
    final carbsPercent = (nutrition.carbs * 4 / totalCalories) * 100;
    final proteinPercent = (nutrition.protein * 4 / totalCalories) * 100;
    final fatPercent = (nutrition.fat * 9 / totalCalories) * 100;

    // Score each macro (0-100)
    final carbsScore = _scoreMacro(carbsPercent, carbsMinPercent, carbsMaxPercent);
    final proteinScore = _scoreMacro(proteinPercent, proteinMinPercent, proteinMaxPercent);
    final fatScore = _scoreMacro(fatPercent, fatMinPercent, fatMaxPercent);

    // Weighted average (carbs 40%, protein 35%, fat 25%)
    final totalScore = (carbsScore * 0.4) + (proteinScore * 0.35) + (fatScore * 0.25);

    // Adjust based on total calories vs recommended
    final recommendedCalories = HealthScoreService.calculateRecommendedCalories(profile);
    if (recommendedCalories > 0) {
      final calorieRatio = nutrition.calories / recommendedCalories;
      double calorieScore = 100;
      
      if (calorieRatio < 0.7 || calorieRatio > 1.3) {
        calorieScore = 60; // Too low or too high
      } else if (calorieRatio < 0.85 || calorieRatio > 1.15) {
        calorieScore = 80; // Slightly off
      }
      
      // Combine macro score (70%) with calorie score (30%)
      return ((totalScore * 0.7) + (calorieScore * 0.3)).round();
    }

    return totalScore.round();
  }

  /// Score a macro based on whether it's within recommended range
  static int _scoreMacro(double percent, double min, double max) {
    if (percent >= min && percent <= max) {
      return 100; // Perfect
    } else if (percent < min) {
      // Below minimum - score decreases as it gets further
      final diff = min - percent;
      final maxDiff = min; // Worst case is 0%
      return (100 - (diff / maxDiff * 50)).round().clamp(0, 100);
    } else {
      // Above maximum - score decreases as it gets further
      final diff = percent - max;
      final maxDiff = 100 - max; // Worst case is 100%
      return (100 - (diff / maxDiff * 50)).round().clamp(0, 100);
    }
  }

  /// Get macro breakdown analysis
  static Map<String, dynamic> getMacroAnalysis(FoodNutrition nutrition) {
    final totalCalories = nutrition.macroCalories;
    
    if (totalCalories == 0) {
      return {
        'carbsPercent': 0.0,
        'proteinPercent': 0.0,
        'fatPercent': 0.0,
        'carbsStatus': 'no_data',
        'proteinStatus': 'no_data',
        'fatStatus': 'no_data',
      };
    }

    final carbsPercent = (nutrition.carbs * 4 / totalCalories) * 100;
    final proteinPercent = (nutrition.protein * 4 / totalCalories) * 100;
    final fatPercent = (nutrition.fat * 9 / totalCalories) * 100;

    return {
      'carbsPercent': carbsPercent,
      'proteinPercent': proteinPercent,
      'fatPercent': fatPercent,
      'carbsStatus': _getMacroStatus(carbsPercent, carbsMinPercent, carbsMaxPercent),
      'proteinStatus': _getMacroStatus(proteinPercent, proteinMinPercent, proteinMaxPercent),
      'fatStatus': _getMacroStatus(fatPercent, fatMinPercent, fatMaxPercent),
    };
  }

  static String _getMacroStatus(double percent, double min, double max) {
    if (percent >= min && percent <= max) {
      return 'optimal';
    } else if (percent < min) {
      return 'low';
    } else {
      return 'high';
    }
  }

  /// Get recommendations based on macro analysis
  static List<String> getRecommendations(FoodNutrition nutrition, UserProfile? profile) {
    final recommendations = <String>[];
    final analysis = getMacroAnalysis(nutrition);
    final recommendedCalories = HealthScoreService.calculateRecommendedCalories(profile);

    // Calorie recommendations
    if (recommendedCalories > 0) {
      final calorieDiff = nutrition.calories - recommendedCalories;
      if (calorieDiff.abs() > 500) {
        if (calorieDiff > 0) {
          recommendations.add('Your calorie intake is ${calorieDiff.round()} kcal above recommended. Consider reducing portion sizes.');
        } else {
          recommendations.add('Your calorie intake is ${calorieDiff.abs().round()} kcal below recommended. Ensure you\'re eating enough for your activity level.');
        }
      }
    }

    // Macro recommendations
    if (analysis['carbsStatus'] == 'low') {
      recommendations.add('Your carb intake is low. Include more whole grains, fruits, and vegetables.');
    } else if (analysis['carbsStatus'] == 'high') {
      recommendations.add('Your carb intake is high. Consider balancing with more protein and healthy fats.');
    }

    if (analysis['proteinStatus'] == 'low') {
      final exerciseDays = profile?.exerciseFrequencyPerWeek ?? 0;
      if (exerciseDays >= 3) {
        recommendations.add('Your protein intake is low. As an active person, aim for higher protein to support muscle recovery.');
      } else {
        recommendations.add('Your protein intake is low. Include lean meats, fish, eggs, or plant-based proteins.');
      }
    } else if (analysis['proteinStatus'] == 'high') {
      recommendations.add('Your protein intake is high. This is good for muscle maintenance, but ensure you\'re also getting enough carbs for energy.');
    }

    if (analysis['fatStatus'] == 'low') {
      recommendations.add('Your fat intake is low. Include healthy fats from nuts, avocados, and olive oil.');
    } else if (analysis['fatStatus'] == 'high') {
      recommendations.add('Your fat intake is high. Focus on healthy fats and consider reducing saturated fats.');
    }

    // Ensure at least one recommendation
    if (recommendations.isEmpty) {
      recommendations.add('Great job! Your macro balance looks good. Keep maintaining this balance.');
    }

    return recommendations.take(3).toList();
  }
}
