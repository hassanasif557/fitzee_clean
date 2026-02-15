import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/medical_entry.dart';

/// Firestore collection: medical_info (medical data entries)
/// Document: auto-id. Fields: userId, dateTime, type, label, valuePrimary?, valueSecondary?, valueText?, description?
class FirestoreMedicalEntryService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'medical_info';

  static Future<void> saveMedicalEntry(String userId, MedicalEntry entry) async {
    try {
      final data = entry.toJson();
      data['userId'] = userId;
      if (entry.id.startsWith('med_')) {
        await _firestore.collection(_collection).doc(entry.id).set(data, SetOptions(merge: true));
      } else {
        await _firestore.collection(_collection).add(data);
      }
    } catch (e) {
      throw Exception('Failed to save medical entry to Firestore: $e');
    }
  }

  static Future<List<MedicalEntry>> getMedicalEntries(
    String userId, {
    int? limit,
  }) async {
    try {
      Query<Map<String, dynamic>> q = _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('dateTime', descending: true);
      if (limit != null) q = q.limit(limit);
      final snapshot = await q.get();
      return snapshot.docs
          .map((doc) {
            final d = doc.data();
            d['id'] = doc.id;
            return MedicalEntry.fromJson(d);
          })
          .toList();
    } catch (e) {
      throw Exception('Failed to get medical entries from Firestore: $e');
    }
  }

  static Future<List<MedicalEntry>> getMedicalEntriesForDate(
    String userId,
    DateTime date,
  ) async {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('dateTime', isGreaterThanOrEqualTo: dayStart.toIso8601String())
          .where('dateTime', isLessThan: dayEnd.toIso8601String())
          .orderBy('dateTime', descending: true)
          .get();
      return snapshot.docs
          .map((doc) {
            final d = doc.data();
            d['id'] = doc.id;
            return MedicalEntry.fromJson(d);
          })
          .toList();
    } catch (e) {
      throw Exception('Failed to get medical entries for date from Firestore: $e');
    }
  }

  /// All entries grouped by date (dateKey -> list), sorted by date desc.
  static Future<Map<String, List<MedicalEntry>>> getEntriesGroupedByDate(
    String userId,
  ) async {
    final all = await getMedicalEntries(userId);
    final byDate = <String, List<MedicalEntry>>{};
    for (final e in all) {
      final key = _formatDate(e.dateTime);
      byDate.putIfAbsent(key, () => []).add(e);
    }
    for (final list in byDate.values) {
      list.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    }
    return byDate;
  }

  static String _formatDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}
