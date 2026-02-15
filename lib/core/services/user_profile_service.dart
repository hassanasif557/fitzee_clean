import 'package:fitzee_new/core/data/datasources/local_user_profile_datasource.dart';
import 'package:fitzee_new/core/services/connectivity_service.dart';
import 'package:fitzee_new/core/services/firestore_user_profile_service.dart';
import 'package:fitzee_new/core/services/local_storage_service.dart';
import 'package:fitzee_new/features/onboard/domain/entities/user_profile.dart';

/// Offline-first: always read from local first (SQLite then SharedPreferences). Never block on network.
/// When online, sync to/from Firestore in background. Saves go to local first, then push when connected.
class UserProfileService {
  static final LocalUserProfileDataSource _local = LocalUserProfileDataSource();

  /// Saves profile to SQLite and SharedPreferences first (source of truth), then pushes to Firestore when online.
  static Future<void> saveUserProfile(UserProfile profile) async {
    try {
      await _local.upsert(profile);
    } catch (e) {
      print('Warning: Drift save failed, using SharedPreferences only: $e');
    }
    await LocalStorageService.saveUserProfile(profile);
    final hasInternet = await ConnectivityService.hasInternetConnection();
    if (hasInternet && profile.userId != null && profile.userId!.isNotEmpty) {
      try {
        await FirestoreUserProfileService.saveUserProfile(profile);
        await _local.markSynced(profile.userId!, firestoreId: profile.userId);
      } catch (e) {
        print('Warning: Failed to save to Firestore, will retry on next sync: $e');
      }
    }
  }

  /// Always returns from local first (Drift, then SharedPreferences). Never waits on network.
  /// When online, Firestore is updated in the background for next time; current call returns local data.
  static Future<UserProfile?> getUserProfile(String? userId) async {
    UserProfile? local;
    try {
      local = await _local.getByUserId(userId);
    } catch (e) {
      print('Warning: Drift read failed, falling back to SharedPreferences: $e');
    }
    if (local == null) {
      local = await LocalStorageService.getUserProfile();
      if (local != null && userId != null && userId.isNotEmpty) {
        try {
          await _local.upsert(local);
        } catch (_) {}
      }
    }
    if (userId != null && userId.isNotEmpty) {
      ConnectivityService.hasInternetConnection().then((online) async {
        if (!online) return;
        try {
          final firestoreProfile =
              await FirestoreUserProfileService.getUserProfile(userId);
          if (firestoreProfile != null) {
            await _local.upsert(firestoreProfile);
            await _local.markSynced(userId, firestoreId: userId);
          }
        } catch (_) {}
      });
    }
    return local;
  }

  static Future<void> updateUserProfile(UserProfile profile) async {
    await saveUserProfile(profile);
  }

  /// Soft-deletes locally and deletes from Firestore when online.
  static Future<void> deleteUserProfile(String userId) async {
    try {
      await _local.softDelete(userId);
    } catch (e) {
      print('Warning: Drift softDelete failed: $e');
    }
    await LocalStorageService.clearUserProfile();
    final hasInternet = await ConnectivityService.hasInternetConnection();
    if (hasInternet) {
      try {
        await FirestoreUserProfileService.deleteUserProfile(userId);
      } catch (e) {
        print('Warning: Failed to delete from Firestore: $e');
      }
    }
  }

  /// Syncs pending local changes to Firestore when connection is restored.
  static Future<void> syncLocalToFirestore(String? userId) async {
    if (userId == null || userId.isEmpty) return;
    final hasInternet = await ConnectivityService.hasInternetConnection();
    if (!hasInternet) return;
    try {
      final localProfile = await _local.getByUserId(userId);
      if (localProfile != null) {
        await FirestoreUserProfileService.saveUserProfile(localProfile);
        await _local.markSynced(userId, firestoreId: userId);
      }
    } catch (e) {
      print('Warning: Failed to sync local profile to Firestore: $e');
    }
  }
}
