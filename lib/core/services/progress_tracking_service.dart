import 'package:fitzee_new/core/services/daily_data_service.dart';
import 'package:fitzee_new/core/services/health_score_service.dart';
import 'package:fitzee_new/features/onboard/domain/entities/user_profile.dart';

/// Service to track and analyze daily progress
class ProgressTrackingService {
  /// Get progress data for the last N days
  static Future<List<Map<String, dynamic>>> getProgressData(int days) async {
    final allData = await DailyDataService.getAllDailyData();
    final now = DateTime.now();
    final progressData = <Map<String, dynamic>>[];

    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = _formatDate(date);
      final data = allData[dateKey];

      if (data != null) {
        progressData.add({
          'date': date,
          'dateKey': dateKey,
          'steps': data['steps'] as int? ?? 0,
          'calories': data['calories'] as int? ?? 0,
          'sleepHours': data['sleepHours'] as double? ?? 0.0,
        });
      } else {
        // Add empty entry for missing days
        progressData.add({
          'date': date,
          'dateKey': dateKey,
          'steps': 0,
          'calories': 0,
          'sleepHours': 0.0,
        });
      }
    }

    return progressData;
  }

  /// Calculate health scores for progress tracking
  static Future<List<Map<String, dynamic>>> getHealthScoreProgress(
    UserProfile? profile,
    int days,
  ) async {
    final progressData = await getProgressData(days);
    final healthScores = <Map<String, dynamic>>[];

    for (final data in progressData) {
      if (data['steps'] == 0 && data['calories'] == 0 && data['sleepHours'] == 0.0) {
        healthScores.add({
          'date': data['date'],
          'score': null,
          'bmi': null,
        });
        continue;
      }

      // Calculate health score for this day
      final bmi = HealthScoreService.calculateBMI(profile?.height, profile?.weight);
      final bmiScore = HealthScoreService.bmiScore(bmi);
      final sleepScore = HealthScoreService.sleepScore(data['sleepHours'] as double);
      final stepsScore = HealthScoreService.stepsScore(data['steps'] as int);
      final workoutDays = profile?.exerciseFrequencyPerWeek ?? profile?.trainingDaysPerWeek ?? 0;
      final workoutScore = HealthScoreService.workoutScore(workoutDays);
      final recommendedCalories = HealthScoreService.calculateRecommendedCalories(profile);
      final calorieScore = HealthScoreService.calorieScore(
        data['calories'] as int,
        recommendedCalories,
      );

      final score = HealthScoreService.calculateHealthScoreValue(
        bmi: bmiScore,
        sleep: sleepScore,
        steps: stepsScore,
        workout: workoutScore,
        calories: calorieScore,
      );

      healthScores.add({
        'date': data['date'],
        'score': score,
        'bmi': bmi > 0 ? bmi : null,
      });
    }

    return healthScores;
  }

  /// Calculate trends and statistics
  static Future<Map<String, dynamic>> calculateTrends(int days) async {
    final progressData = await getProgressData(days);
    
    if (progressData.isEmpty) {
      return {
        'stepsTrend': 0,
        'caloriesTrend': 0,
        'sleepTrend': 0.0,
        'stepsAverage': 0,
        'caloriesAverage': 0,
        'sleepAverage': 0.0,
        'stepsBest': 0,
        'caloriesBest': 0,
        'sleepBest': 0.0,
        'stepsWorst': 0,
        'caloriesWorst': 0,
        'sleepWorst': 0.0,
        'consistency': 0.0,
      };
    }

    // Filter out days with no data
    final validData = progressData.where((d) => 
      d['steps'] > 0 || d['calories'] > 0 || d['sleepHours'] > 0
    ).toList();

    if (validData.isEmpty) {
      return {
        'stepsTrend': 0,
        'caloriesTrend': 0,
        'sleepTrend': 0.0,
        'stepsAverage': 0,
        'caloriesAverage': 0,
        'sleepAverage': 0.0,
        'stepsBest': 0,
        'caloriesBest': 0,
        'sleepBest': 0.0,
        'stepsWorst': 0,
        'caloriesWorst': 0,
        'sleepWorst': 0.0,
        'consistency': 0.0,
      };
    }

    // Calculate averages
    final stepsSum = validData.fold<int>(0, (sum, d) => sum + (d['steps'] as int));
    final caloriesSum = validData.fold<int>(0, (sum, d) => sum + (d['calories'] as int));
    final sleepSum = validData.fold<double>(0.0, (sum, d) => sum + (d['sleepHours'] as double));

    final count = validData.length;
    final stepsAverage = (stepsSum / count).round();
    final caloriesAverage = (caloriesSum / count).round();
    final sleepAverage = sleepSum / count;

    // Calculate best and worst
    final stepsBest = validData.map((d) => d['steps'] as int).reduce((a, b) => a > b ? a : b);
    final stepsWorst = validData.map((d) => d['steps'] as int).reduce((a, b) => a < b ? a : b);
    final caloriesBest = validData.map((d) => d['calories'] as int).reduce((a, b) => a > b ? a : b);
    final caloriesWorst = validData.map((d) => d['calories'] as int).reduce((a, b) => a < b ? a : b);
    final sleepBest = validData.map((d) => d['sleepHours'] as double).reduce((a, b) => a > b ? a : b);
    final sleepWorst = validData.map((d) => d['sleepHours'] as double).reduce((a, b) => a < b ? a : b);

    // Calculate trends (comparing first half vs second half)
    int stepsTrend = 0;
    double sleepTrend = 0.0;
    int caloriesTrend = 0;

    if (validData.length >= 4) {
      final halfPoint = validData.length ~/ 2;
      final firstHalf = validData.sublist(0, halfPoint);
      final secondHalf = validData.sublist(halfPoint);

      final firstHalfStepsAvg = (firstHalf.fold<int>(0, (sum, d) => sum + (d['steps'] as int)) / firstHalf.length).round();
      final secondHalfStepsAvg = (secondHalf.fold<int>(0, (sum, d) => sum + (d['steps'] as int)) / secondHalf.length).round();
      stepsTrend = secondHalfStepsAvg - firstHalfStepsAvg;

      final firstHalfCaloriesAvg = (firstHalf.fold<int>(0, (sum, d) => sum + (d['calories'] as int)) / firstHalf.length).round();
      final secondHalfCaloriesAvg = (secondHalf.fold<int>(0, (sum, d) => sum + (d['calories'] as int)) / secondHalf.length).round();
      caloriesTrend = secondHalfCaloriesAvg - firstHalfCaloriesAvg;

      final firstHalfSleepAvg = firstHalf.fold<double>(0.0, (sum, d) => sum + (d['sleepHours'] as double)) / firstHalf.length;
      final secondHalfSleepAvg = secondHalf.fold<double>(0.0, (sum, d) => sum + (d['sleepHours'] as double)) / secondHalf.length;
      sleepTrend = secondHalfSleepAvg - firstHalfSleepAvg;
    }

    // Calculate consistency (percentage of days with data)
    final consistency = (validData.length / days) * 100;

    return {
      'stepsTrend': stepsTrend,
      'caloriesTrend': caloriesTrend,
      'sleepTrend': sleepTrend,
      'stepsAverage': stepsAverage,
      'caloriesAverage': caloriesAverage,
      'sleepAverage': sleepAverage,
      'stepsBest': stepsBest,
      'caloriesBest': caloriesBest,
      'sleepBest': sleepBest,
      'stepsWorst': stepsWorst,
      'caloriesWorst': caloriesWorst,
      'sleepWorst': sleepWorst,
      'consistency': consistency,
      'totalDays': days,
      'dataDays': validData.length,
    };
  }

  /// Generate suggestions based on progress trends
  static Future<List<String>> generateSuggestions(
    UserProfile? profile,
    int days,
  ) async {
    final trends = await calculateTrends(days);
    final suggestions = <String>[];

    // Steps suggestions
    if (trends['stepsAverage'] < 7000) {
      suggestions.add('📈 Your average steps (${trends['stepsAverage']}) is below the recommended 7,000. Try to increase daily walking.');
    } else if (trends['stepsAverage'] < 10000) {
      suggestions.add('🎯 Great progress! You\'re averaging ${trends['stepsAverage']} steps. Aim for 10,000 steps daily for optimal health.');
    } else {
      suggestions.add('🌟 Excellent! You\'re consistently hitting 10,000+ steps. Keep up the amazing work!');
    }

    if (trends['stepsTrend'] < -500) {
      suggestions.add('⚠️ Your step count has decreased recently. Try to maintain or increase your daily activity.');
    } else if (trends['stepsTrend'] > 500) {
      suggestions.add('📊 Great improvement! Your step count is trending upward. Keep it up!');
    }

    // Sleep suggestions
    if (trends['sleepAverage'] < 7) {
      suggestions.add('😴 Your average sleep (${trends['sleepAverage'].toStringAsFixed(1)}h) is below recommended 7-9 hours. Prioritize better sleep.');
    } else if (trends['sleepAverage'] > 9) {
      suggestions.add('💤 You\'re getting ${trends['sleepAverage'].toStringAsFixed(1)}h of sleep on average. While good, excessive sleep might indicate other issues.');
    } else {
      suggestions.add('✨ Excellent sleep habits! You\'re maintaining 7-9 hours consistently.');
    }

    if (trends['sleepTrend'] < -0.5) {
      suggestions.add('⚠️ Your sleep duration has decreased. Ensure you\'re getting enough rest for recovery.');
    }

    // Calories suggestions
    final recommendedCalories = HealthScoreService.calculateRecommendedCalories(profile);
    final calorieDiff = trends['caloriesAverage'] - recommendedCalories;
    
    if (calorieDiff.abs() > 500) {
      if (calorieDiff > 0) {
        suggestions.add('🍽️ Your average calories (${trends['caloriesAverage']}) is significantly above recommended (${recommendedCalories}). Consider adjusting your diet.');
      } else {
        suggestions.add('⚡ Your average calories (${trends['caloriesAverage']}) is below recommended (${recommendedCalories}). Ensure you\'re eating enough for your activity level.');
      }
    } else {
      suggestions.add('✅ Your calorie intake is well-balanced with your recommended daily needs.');
    }

    // Consistency suggestions
    if (trends['consistency'] < 50) {
      suggestions.add('📝 You\'re only logging data ${trends['consistency'].toStringAsFixed(0)}% of the time. Consistent tracking helps you see real progress!');
    } else if (trends['consistency'] < 80) {
      suggestions.add('📊 Good tracking consistency! Try to log daily for more accurate insights.');
    } else {
      suggestions.add('🎉 Excellent tracking consistency! Your dedication to logging data is paying off.');
    }

    // Best day celebration
    if (trends['stepsBest'] >= 10000) {
      suggestions.add('🏆 Your best day had ${trends['stepsBest']} steps! That\'s an amazing achievement!');
    }

    return suggestions.take(5).toList();
  }

  /// Get weekly summary
  static Future<Map<String, dynamic>> getWeeklySummary(UserProfile? profile) async {
    final trends = await calculateTrends(7);
    final healthScores = await getHealthScoreProgress(profile, 7);
    
    // Calculate average health score
    final validScores = healthScores.where((s) => s['score'] != null).toList();
    final avgHealthScore = validScores.isEmpty 
        ? 0 
        : (validScores.fold<int>(0, (sum, s) => sum + (s['score'] as int)) / validScores.length).round();

    return {
      ...trends,
      'averageHealthScore': avgHealthScore,
      'healthScoreLabel': HealthScoreService.getScoreLabel(avgHealthScore),
    };
  }

  /// Get monthly summary
  static Future<Map<String, dynamic>> getMonthlySummary(UserProfile? profile) async {
    final trends = await calculateTrends(30);
    final healthScores = await getHealthScoreProgress(profile, 30);
    
    // Calculate average health score
    final validScores = healthScores.where((s) => s['score'] != null).toList();
    final avgHealthScore = validScores.isEmpty 
        ? 0 
        : (validScores.fold<int>(0, (sum, s) => sum + (s['score'] as int)) / validScores.length).round();

    return {
      ...trends,
      'averageHealthScore': avgHealthScore,
      'healthScoreLabel': HealthScoreService.getScoreLabel(avgHealthScore),
    };
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
