import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore collection: workout.
/// Document id: userId_dateKey. All workout-related daily data: steps, caloriesBurned, exerciseMinutes.
class FirestoreWorkoutService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'workout';

  static String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static Future<void> saveWorkoutData({
    required String userId,
    required DateTime date,
    required int steps,
    int? caloriesBurned,
    int? exerciseMinutes,
  }) async {
    try {
      final dateKey = _dateKey(date);
      final data = <String, dynamic>{
        'userId': userId,
        'date': date.toIso8601String(),
        'steps': steps,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (caloriesBurned != null) data['caloriesBurned'] = caloriesBurned;
      if (exerciseMinutes != null) data['exerciseMinutes'] = exerciseMinutes;
      await _firestore
          .collection(_collection)
          .doc('${userId}_$dateKey')
          .set(data, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save workout data to Firestore: $e');
    }
  }

  static Future<Map<String, dynamic>?> getWorkoutForDate(
    String userId,
    DateTime date,
  ) async {
    try {
      final dateKey = _dateKey(date);
      final doc = await _firestore
          .collection(_collection)
          .doc('${userId}_$dateKey')
          .get();
      if (!doc.exists) return null;
      return doc.data();
    } catch (e) {
      throw Exception('Failed to get workout data from Firestore: $e');
    }
  }

  /// All workout entries for user (dateKey -> data), sorted by date desc.
  static Future<Map<String, Map<String, dynamic>>> getAllWorkoutData(
    String userId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();
      final map = <String, Map<String, dynamic>>{};
      for (final doc in snapshot.docs) {
        final d = doc.data();
        final dateStr = d['date'] as String?;
        if (dateStr != null) {
          final date = DateTime.parse(dateStr);
          final dateKey = _dateKey(date);
          map[dateKey] = d;
        }
      }
      return map;
    } catch (e) {
      throw Exception('Failed to get workout data from Firestore: $e');
    }
  }
}
