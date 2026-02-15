import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/medical_entry.dart';
import 'connectivity_service.dart';
import 'firestore_medical_entry_service.dart';
import 'local_storage_service.dart';

/// Service to store medical entries (blood pressure, sugar level, custom).
/// Saves to local and to Firestore (medical_info collection) when online.
class MedicalEntryService {
  static const String _key = 'medical_entries';

  static Future<void> saveMedicalEntry(MedicalEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await _getAllLocal();
    list.add(entry);
    final jsonList = list.map((e) => e.toJson()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));

    final hasInternet = await ConnectivityService.hasInternetConnection();
    if (hasInternet) {
      try {
        final userId = await LocalStorageService.getUserId();
        if (userId != null && userId.isNotEmpty) {
          await FirestoreMedicalEntryService.saveMedicalEntry(userId, entry);
        }
      } catch (e) {
        print('Warning: Failed to save medical entry to Firestore: $e');
      }
    }
  }

  static Future<List<MedicalEntry>> _getAllLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => MedicalEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<List<MedicalEntry>> getAllMedicalEntries() async {
    final hasInternet = await ConnectivityService.hasInternetConnection();
    if (hasInternet) {
      try {
        final userId = await LocalStorageService.getUserId();
        if (userId != null && userId.isNotEmpty) {
          final fromFirestore =
              await FirestoreMedicalEntryService.getMedicalEntries(userId);
          if (fromFirestore.isNotEmpty) {
            return fromFirestore;
          }
        }
      } catch (e) {
        print('Warning: Failed to get medical entries from Firestore: $e');
      }
    }
    return _getAllLocal();
  }

  static Future<List<MedicalEntry>> getMedicalEntriesForDate(
    DateTime date,
  ) async {
    final hasInternet = await ConnectivityService.hasInternetConnection();
    if (hasInternet) {
      try {
        final userId = await LocalStorageService.getUserId();
        if (userId != null && userId.isNotEmpty) {
          return await FirestoreMedicalEntryService.getMedicalEntriesForDate(
            userId,
            date,
          );
        }
      } catch (e) {
        print('Warning: Failed to get medical entries from Firestore: $e');
      }
    }
    final all = await _getAllLocal();
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    return all
        .where((e) =>
            !e.dateTime.isBefore(dayStart) && e.dateTime.isBefore(dayEnd))
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  static Future<List<MedicalEntry>> getTodayMedicalEntries() async {
    return getMedicalEntriesForDate(DateTime.now());
  }

  static Future<void> deleteMedicalEntry(String id) async {
    final list = await _getAllLocal();
    list.removeWhere((e) => e.id == id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(list.map((e) => e.toJson()).toList()));
  }

  /// Clear local medical entries (call on sign out for security).
  static Future<void> clearLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static String _formatDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  /// All entries grouped by date (dateKey -> list), sorted by date desc.
  /// When online, fetches from Firestore; otherwise local.
  static Future<Map<String, List<MedicalEntry>>> getEntriesGroupedByDate() async {
    final hasInternet = await ConnectivityService.hasInternetConnection();
    if (hasInternet) {
      try {
        final userId = await LocalStorageService.getUserId();
        if (userId != null && userId.isNotEmpty) {
          return await FirestoreMedicalEntryService.getEntriesGroupedByDate(
            userId,
          );
        }
      } catch (e) {
        print('Warning: Failed to get medical entries from Firestore: $e');
      }
    }
    final all = await _getAllLocal();
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
}
