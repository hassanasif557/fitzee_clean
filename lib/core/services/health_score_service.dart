import 'package:fitzee_new/features/onboard/domain/entities/user_profile.dart';
import 'package:fitzee_new/core/services/daily_data_service.dart';
import 'package:fitzee_new/core/services/ai_coaching_service.dart';

/// Service to calculate health score based on BMI and user profile data
class HealthScoreService {
  /// Calculate BMI from height (cm) and weight (kg)
  /// BMI = weight (kg) / (height (m))^2
  static double calculateBMI(double? heightCm, double? weightKg) {
    if (heightCm == null || weightKg == null || heightCm <= 0 || weightKg <= 0) {
      return 0.0;
    }
    
    // Convert height from cm to meters
    final heightM = heightCm / 100.0;
    
    // Calculate BMI
    final bmi = weightKg / (heightM * heightM);
    return bmi;
  }

  /// Get BMI category based on BMI value
  static String getBMICategory(double bmi) {
    if (bmi < 18.5) {
      return 'Underweight';
    } else if (bmi < 25) {
      return 'Normal';
    } else if (bmi < 30) {
      return 'Overweight';
    } else {
      return 'Obese';
    }
  }

  /// Get score label based on score value
  static String getScoreLabel(int score) {
    if (score >= 90) {
      return 'Excellent';
    } else if (score >= 75) {
      return 'Good';
    } else if (score >= 50) {
      return 'Average';
    } else {
      return 'Needs Improvement';
    }
  }

  /// Calculate BMI Score (0-100)
  static int bmiScore(double bmi) {
    if (bmi >= 18.5 && bmi <= 24.9) return 100;
    if (bmi >= 25 && bmi <= 29.9) return 70;
    if (bmi >= 30) return 40;
    return 50; // Underweight
  }

  /// Calculate Sleep Score (0-100)
  static int sleepScore(double hours) {
    if (hours >= 7 && hours <= 9) return 100;
    if (hours >= 6) return 70;
    return 40;
  }

  /// Calculate Steps Score (0-100)
  static int stepsScore(int steps) {
    if (steps >= 10000) return 100;
    if (steps >= 7000) return 70;
    return 40;
  }

  /// Calculate Workout Score (0-100)
  static int workoutScore(int daysPerWeek) {
    if (daysPerWeek >= 5) return 100;
    if (daysPerWeek >= 3) return 70;
    return 40;
  }

  /// Calculate Calorie Score (0-100)
  static int calorieScore(int consumed, int recommended) {
    final diff = (consumed - recommended).abs();
    if (diff <= 200) return 100;
    if (diff <= 500) return 70;
    return 40;
  }

  /// Calculate recommended daily calories based on user profile
  static int calculateRecommendedCalories(UserProfile? profile) {
    if (profile == null || profile.weight == null || profile.height == null || profile.age == null || profile.gender == null) {
      return 2000; // Default
    }

    // Using Mifflin-St Jeor Equation for BMR
    double bmr;
    final weight = profile.weight!;
    final height = profile.height! / 100; // Convert to meters
    final age = profile.age!;
    
    if (profile.gender!.toLowerCase() == 'male') {
      bmr = 10 * weight + 6.25 * (height * 100) - 5 * age + 5;
    } else {
      bmr = 10 * weight + 6.25 * (height * 100) - 5 * age - 161;
    }

    // Activity multiplier based on exercise frequency
    double activityMultiplier = 1.2; // Sedentary
    final exerciseDays = profile.exerciseFrequencyPerWeek ?? 0;
    if (exerciseDays >= 5) {
      activityMultiplier = 1.725; // Very active
    } else if (exerciseDays >= 3) {
      activityMultiplier = 1.55; // Moderately active
    } else if (exerciseDays >= 1) {
      activityMultiplier = 1.375; // Lightly active
    }

    return (bmr * activityMultiplier).round();
  }

  /// Calculate Workout Type Score (0-100)
  static int workoutTypeScore(String? type) {
    if (type == null) return 60;
    
    switch (type.toLowerCase()) {
      case 'hiit':
        return 100;
      case 'strength':
        return 90;
      case 'cardio':
        return 80;
      case 'yoga':
        return 70;
      default:
        return 60;
    }
  }

  /// Calculate Food Preference Score (0-100)
  static int foodPreferenceScore(String? food) {
    if (food == null) return 60;
    
    switch (food.toLowerCase()) {
      case 'vegetables':
      case 'lean protein':
        return 100;
      case 'home food':
        return 80;
      case 'fast food':
        return 40;
      default:
        return 60;
    }
  }

  /// Calculate Health Score (0-100) - Weighted formula
  static int calculateHealthScoreValue({
    required int bmi,
    required int sleep,
    required int steps,
    required int workout,
    required int calories,
  }) {
    return ((bmi * 0.3) +
            (sleep * 0.2) +
            (steps * 0.2) +
            (workout * 0.2) +
            (calories * 0.1))
        .round();
  }

  /// Calculate Fitness Score (0-100)
  static int calculateFitnessScoreValue({
    required int steps,
    required int workouts,
    required int workoutType,
    required int sleep,
  }) {
    return ((steps * 0.3) +
            (workouts * 0.4) +
            (workoutType * 0.2) +
            (sleep * 0.1))
        .round();
  }

  /// Calculate Nutrition Score (0-100)
  static int calculateNutritionScoreValue({
    required int calorieScore,
    required int foodScore,
  }) {
    return ((calorieScore * 0.6) + (foodScore * 0.4)).round();
  }

  /// Calculate Overall Wellness Score (Optional)
  static int calculateOverallScore(int health, int fitness, int nutrition) {
    return ((health * 0.4) +
            (fitness * 0.35) +
            (nutrition * 0.25))
        .round();
  }

  /// Main method to calculate health score based on user profile and daily data
  /// Returns a score from 0-100 with breakdown
  static Future<Map<String, dynamic>> calculateHealthScore(UserProfile? profile) async {
    if (profile == null) {
      return _getDefaultHealthScore();
    }

    final height = profile.height;
    final weight = profile.weight;

    // Check if we have minimum required data
    if (height == null || weight == null || height <= 0 || weight <= 0) {
      return _getDefaultHealthScore();
    }

    // Calculate BMI
    final bmi = calculateBMI(height, weight);
    final bmiCategory = getBMICategory(bmi);
    final bmiScoreValue = bmiScore(bmi);

    // Get daily data (use average of last 7 days or yesterday's data)
    final averageData = await DailyDataService.getAverageData(7);
    final yesterdayData = await DailyDataService.getYesterdayData();
    
    // Use yesterday's data if available, otherwise use average
    final dailyData = yesterdayData ?? averageData;
    
    final steps = dailyData['steps'] as int? ?? 0;
    final calories = dailyData['calories'] as int? ?? 0;
    final sleepHours = dailyData['sleepHours'] as double? ?? (profile.averageSleepHours ?? 0.0);

    // Calculate recommended calories
    final recommendedCalories = calculateRecommendedCalories(profile);

    // Calculate individual scores
    final sleepScoreValue = sleepScore(sleepHours);
    final stepsScoreValue = stepsScore(steps);
    final workoutDays = profile.exerciseFrequencyPerWeek ?? profile.trainingDaysPerWeek ?? 0;
    final workoutScoreValue = workoutScore(workoutDays);
    final calorieScoreValue = calorieScore(calories, recommendedCalories);

    // Calculate main health score
    final healthScoreValue = calculateHealthScoreValue(
      bmi: bmiScoreValue,
      sleep: sleepScoreValue,
      steps: stepsScoreValue,
      workout: workoutScoreValue,
      calories: calorieScoreValue,
    );

    // Get workout preferences for fitness score
    final workoutPreferences = await AICoachingService.getWorkoutPreferences();
    final workoutType = workoutPreferences['preferredWorkoutType'] as String?;
    final workoutTypeScoreValue = workoutTypeScore(workoutType);

    // Calculate fitness score
    final fitnessScoreValue = calculateFitnessScoreValue(
      steps: stepsScoreValue,
      workouts: workoutScoreValue,
      workoutType: workoutTypeScoreValue,
      sleep: sleepScoreValue,
    );

    // Get diet preferences for nutrition score
    final dietPreferences = await AICoachingService.getDietPreferences();
    // Try to get food preference from diet preferences
    String? foodPreference;
    if (dietPreferences.isNotEmpty) {
      // Check common keys for food preference
      foodPreference = dietPreferences['foodPreference'] as String? ?? 
                      dietPreferences['preferredFood'] as String? ??
                      dietPreferences['dietType'] as String?;
    }
    final foodScoreValue = foodPreferenceScore(foodPreference);

    // Calculate nutrition score
    final nutritionScoreValue = calculateNutritionScoreValue(
      calorieScore: calorieScoreValue,
      foodScore: foodScoreValue,
    );

    // Calculate recovery score (based on sleep and stress)
    final stressLevel = profile.stressLevel ?? 5;
    final recoveryScoreValue = _calculateRecoveryScore(sleepHours, stressLevel);

    // Calculate overall wellness score
    final overallScoreValue = calculateOverallScore(
      healthScoreValue,
      fitnessScoreValue,
      nutritionScoreValue,
    );

    // Generate recommendations
    final recommendations = _generateRecommendations(
      bmi,
      bmiCategory,
      workoutDays,
      sleepHours,
      stressLevel,
      steps,
      calories,
      recommendedCalories,
    );

    return {
      'score': healthScoreValue,
      'scoreLabel': getScoreLabel(healthScoreValue),
      'overallScore': overallScoreValue,
      'overallScoreLabel': getScoreLabel(overallScoreValue),
      'bmi': double.parse(bmi.toStringAsFixed(1)),
      'bmiCategory': bmiCategory,
      'breakdown': {
        'fitness': fitnessScoreValue,
        'fitnessLabel': getScoreLabel(fitnessScoreValue),
        'nutrition': nutritionScoreValue,
        'nutritionLabel': getScoreLabel(nutritionScoreValue),
        'recovery': recoveryScoreValue,
        'recoveryLabel': getScoreLabel(recoveryScoreValue),
      },
      'componentScores': {
        'bmi': bmiScoreValue,
        'sleep': sleepScoreValue,
        'steps': stepsScoreValue,
        'workout': workoutScoreValue,
        'calories': calorieScoreValue,
      },
      'recommendations': recommendations,
      'dailyData': {
        'steps': steps,
        'calories': calories,
        'recommendedCalories': recommendedCalories,
        'sleepHours': sleepHours,
      },
    };
  }

  static int _calculateRecoveryScore(double sleepHours, int stressLevel) {
    double score = 100.0;
    
    // Adjust based on sleep
    if (sleepHours >= 7 && sleepHours <= 9) {
      // Optimal sleep
    } else if (sleepHours >= 6 && sleepHours < 7) {
      score -= 10;
    } else if (sleepHours > 9 && sleepHours <= 10) {
      score -= 5;
    } else {
      score -= 20;
    }
    
    // Adjust based on stress (1-10, lower is better)
    score -= ((stressLevel - 1) / 9) * 20;
    
    if (score > 100) score = 100;
    if (score < 0) score = 0;
    return score.round();
  }

  static List<String> _generateRecommendations(
    double bmi,
    String bmiCategory,
    int workoutDays,
    double sleepHours,
    int stressLevel,
    int steps,
    int calories,
    int recommendedCalories,
  ) {
    final recommendations = <String>[];

    // BMI-based recommendations
    if (bmiCategory == 'Underweight') {
      recommendations.add('Consider consulting with a nutritionist to develop a healthy weight gain plan');
    } else if (bmiCategory == 'Overweight' || bmiCategory == 'Obese') {
      recommendations.add('Aim for gradual weight loss through a balanced diet and regular exercise');
    } else {
      recommendations.add('Maintain your current healthy weight through balanced nutrition');
    }

    // Steps recommendations
    if (steps < 7000) {
      recommendations.add('Try to reach at least 7,000 steps daily for better health');
    } else if (steps < 10000) {
      recommendations.add('Great job! Aim for 10,000 steps daily for optimal health');
    }

    // Workout recommendations
    if (workoutDays < 3) {
      recommendations.add('Try to exercise at least 3-4 times per week for optimal health');
    } else if (workoutDays >= 3 && workoutDays < 5) {
      recommendations.add('Great job! Consider adding 1-2 more workout days per week');
    }

    // Sleep recommendations
    if (sleepHours < 7) {
      recommendations.add('Aim for 7-9 hours of sleep per night for better recovery');
    } else if (sleepHours > 9) {
      recommendations.add('Consider if excessive sleep might indicate underlying health issues');
    }

    // Calorie recommendations
    final calorieDiff = calories - recommendedCalories;
    if (calorieDiff.abs() > 500) {
      if (calorieDiff > 0) {
        recommendations.add('Consider reducing calorie intake to align with your recommended daily calories');
      } else {
        recommendations.add('Consider increasing calorie intake to meet your daily energy needs');
      }
    }

    // Stress recommendations
    if (stressLevel > 7) {
      recommendations.add('High stress levels detected. Consider stress management techniques like meditation or yoga');
    }

    // Ensure we have at least 3 recommendations
    while (recommendations.length < 3) {
      recommendations.add('Stay hydrated and maintain a balanced diet');
    }

    return recommendations.take(3).toList();
  }

  static Map<String, dynamic> _getDefaultHealthScore() {
    return {
      'score': 75,
      'scoreLabel': 'Good',
      'overallScore': 75,
      'overallScoreLabel': 'Good',
      'bmi': 0.0,
      'bmiCategory': 'Unknown',
      'breakdown': {
        'fitness': 70,
        'fitnessLabel': 'Average',
        'nutrition': 75,
        'nutritionLabel': 'Good',
        'recovery': 80,
        'recoveryLabel': 'Good',
      },
      'componentScores': {
        'bmi': 50,
        'sleep': 70,
        'steps': 40,
        'workout': 40,
        'calories': 70,
      },
      'recommendations': [
        'Complete your profile with height and weight to get accurate health score',
        'Maintain regular exercise routine',
        'Focus on quality sleep',
      ],
      'dailyData': {
        'steps': 0,
        'calories': 0,
        'recommendedCalories': 2000,
        'sleepHours': 0.0,
      },
    };
  }
}
