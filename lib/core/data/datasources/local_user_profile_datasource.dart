/// Local data source for user profile: SQLite (Drift) as source of truth.
/// Supports soft delete (deletedAt). UI is decoupled; repositories use this.
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:fitzee_new/core/database/app_database.dart';
import 'package:fitzee_new/core/database/database_provider.dart';
import 'package:fitzee_new/features/onboard/domain/entities/user_profile.dart';

class LocalUserProfileDataSource {
  LocalUserProfileDataSource() : _db = appDatabase;
  final AppDatabase _db;

  /// Returns the current user profile for [userId] from SQLite, or null if none or soft-deleted.
  Future<UserProfile?> getByUserId(String? userId) async {
    if (userId == null || userId.isEmpty) return null;
    final rows = await (_db.select(_db.localUserProfiles)
          ..where((t) => t.userId.equals(userId) & t.deletedAt.isNull()))
        .get();
    final row = rows.isEmpty ? null : rows.single;
    if (row == null) return null;
    try {
      final map = jsonDecode(row.payload) as Map<String, dynamic>;
      return UserProfile.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  /// Saves [profile] to SQLite. Replaces existing row for the same userId (upsert).
  /// Sets syncStatus to pending so sync service can push to Firebase.
  Future<void> upsert(UserProfile profile) async {
    final userId = profile.userId;
    if (userId == null || userId.isEmpty) return;
    final now = DateTime.now();
    final payload = jsonEncode(profile.toJson());
    await _db.into(_db.localUserProfiles).insert(
          LocalUserProfilesCompanion.insert(
            userId: userId,
            payload: payload,
            createdAt: now,
            updatedAt: now,
            syncStatus: Value(AppDatabase.syncStatusPending),
          ),
          onConflict: DoUpdate(
            (old) => LocalUserProfilesCompanion(
              payload: Value(payload),
              updatedAt: Value(now),
              syncStatus: Value(AppDatabase.syncStatusPending),
              deletedAt: const Value(null),
            ),
          ),
        );
  }

  /// Soft delete: set deletedAt so the row is excluded from reads and sync can push delete to Firebase.
  Future<void> softDelete(String userId) async {
    final now = DateTime.now();
    await (_db.update(_db.localUserProfiles)..where((t) => t.userId.equals(userId)))
        .write(LocalUserProfilesCompanion(
      updatedAt: Value(now),
      deletedAt: Value(now),
      syncStatus: Value(AppDatabase.syncStatusPending),
    ));
  }

  /// Marks the row as synced (after successful Firebase push). Optionally set [firestoreId].
  Future<void> markSynced(String userId, {String? firestoreId}) async {
    await (_db.update(_db.localUserProfiles)..where((t) => t.userId.equals(userId)))
        .write(LocalUserProfilesCompanion(
      syncStatus: Value(AppDatabase.syncStatusSynced),
      firestoreId: Value(firestoreId),
    ));
  }

  /// Returns all rows that need sync (syncStatus == pending, deletedAt null or not).
  Future<List<LocalUserProfile>> getPendingSync() async {
    return await (_db.select(_db.localUserProfiles)
          ..where((t) => t.syncStatus.equals(AppDatabase.syncStatusPending)))
        .get();
  }
}
