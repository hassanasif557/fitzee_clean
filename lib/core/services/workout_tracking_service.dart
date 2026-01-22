import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitzee_new/core/models/exercise.dart';
import 'package:uuid/uuid.dart';

/// Service to track workout sessions and progress
class WorkoutTrackingService {
  static const String _workoutSessionsKey = 'workout_sessions';
  static const String _workoutPlanKey = 'current_workout_plan';
  static const String _workoutStreakKey = 'workout_streak';
  static const String _lastWorkoutDateKey = 'last_workout_date';

  /// Save workout plan
  static Future<void> saveWorkoutPlan(Map<String, dynamic> planJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_workoutPlanKey, jsonEncode(planJson));
  }

  /// Get current workout plan
  static Future<Map<String, dynamic>?> getWorkoutPlan() async {
    final prefs = await SharedPreferences.getInstance();
    final planString = prefs.getString(_workoutPlanKey);
    if (planString != null) {
      return jsonDecode(planString) as Map<String, dynamic>;
    }
    return null;
  }

  /// Create a new workout session
  static WorkoutSession createWorkoutSession(String workoutDayId) {
    return WorkoutSession(
      id: const Uuid().v4(),
      workoutDayId: workoutDayId,
      startTime: DateTime.now(),
      completedExercises: [],
    );
  }

  /// Save workout session
  static Future<void> saveWorkoutSession(WorkoutSession session) async {
    final prefs = await SharedPreferences.getInstance();
    final allSessions = await getAllWorkoutSessions();
    allSessions.add(session);
    
    final sessionsJson = allSessions.map((s) => s.toJson()).toList();
    await prefs.setString(_workoutSessionsKey, jsonEncode(sessionsJson));
    
    // Update streak
    await _updateStreak(session.startTime);
  }

  /// Get all workout sessions
  static Future<List<WorkoutSession>> getAllWorkoutSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsString = prefs.getString(_workoutSessionsKey);
    
    if (sessionsString == null) {
      return [];
    }
    
    try {
      final data = jsonDecode(sessionsString) as List;
      return data.map((json) => WorkoutSession.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get workout sessions for a date
  static Future<List<WorkoutSession>> getSessionsForDate(DateTime date) async {
    final allSessions = await getAllWorkoutSessions();
    final dateKey = _formatDate(date);
    
    return allSessions.where((session) {
      final sessionDateKey = _formatDate(session.startTime);
      return sessionDateKey == dateKey;
    }).toList();
  }

  /// Get today's workout sessions
  static Future<List<WorkoutSession>> getTodaySessions() async {
    return getSessionsForDate(DateTime.now());
  }

  /// Get workout streak
  static Future<int> getWorkoutStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_workoutStreakKey) ?? 0;
  }

  /// Update workout streak
  static Future<void> _updateStreak(DateTime workoutDate) async {
    final prefs = await SharedPreferences.getInstance();
    final lastWorkoutDateString = prefs.getString(_lastWorkoutDateKey);
    final currentStreak = prefs.getInt(_workoutStreakKey) ?? 0;
    
    if (lastWorkoutDateString == null) {
      // First workout
      await prefs.setInt(_workoutStreakKey, 1);
      await prefs.setString(_lastWorkoutDateKey, _formatDate(workoutDate));
      return;
    }
    
    final lastWorkoutDate = DateTime.parse('${lastWorkoutDateString}T00:00:00');
    final workoutDateOnly = DateTime(workoutDate.year, workoutDate.month, workoutDate.day);
    final lastDateOnly = DateTime(lastWorkoutDate.year, lastWorkoutDate.month, lastWorkoutDate.day);
    
    final daysDifference = workoutDateOnly.difference(lastDateOnly).inDays;
    
    if (daysDifference == 0) {
      // Same day, don't update streak
      return;
    } else if (daysDifference == 1) {
      // Consecutive day, increment streak
      await prefs.setInt(_workoutStreakKey, currentStreak + 1);
      await prefs.setString(_lastWorkoutDateKey, _formatDate(workoutDate));
    } else {
      // Streak broken, reset to 1
      await prefs.setInt(_workoutStreakKey, 1);
      await prefs.setString(_lastWorkoutDateKey, _formatDate(workoutDate));
    }
  }

  /// Get weekly workout summary
  static Future<Map<String, dynamic>> getWeeklySummary() async {
    final now = DateTime.now();
    final sessions = <WorkoutSession>[];
    int totalCalories = 0;
    int totalDuration = 0;
    int workoutsCompleted = 0;
    
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final daySessions = await getSessionsForDate(date);
      sessions.addAll(daySessions);
      
      for (final session in daySessions) {
        if (session.isCompleted) {
          workoutsCompleted++;
          totalCalories += session.caloriesBurned ?? 0;
          if (session.endTime != null) {
            totalDuration += session.endTime!.difference(session.startTime).inMinutes;
          }
        }
      }
    }
    
    return {
      'totalWorkouts': workoutsCompleted,
      'totalCalories': totalCalories,
      'totalDuration': totalDuration,
      'averagePerDay': workoutsCompleted / 7,
    };
  }

  /// Get monthly workout summary
  static Future<Map<String, dynamic>> getMonthlySummary() async {
    final now = DateTime.now();
    final sessions = <WorkoutSession>[];
    int totalCalories = 0;
    int totalDuration = 0;
    int workoutsCompleted = 0;
    
    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      final daySessions = await getSessionsForDate(date);
      sessions.addAll(daySessions);
      
      for (final session in daySessions) {
        if (session.isCompleted) {
          workoutsCompleted++;
          totalCalories += session.caloriesBurned ?? 0;
          if (session.endTime != null) {
            totalDuration += session.endTime!.difference(session.startTime).inMinutes;
          }
        }
      }
    }
    
    return {
      'totalWorkouts': workoutsCompleted,
      'totalCalories': totalCalories,
      'totalDuration': totalDuration,
      'averagePerDay': workoutsCompleted / 30,
    };
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
