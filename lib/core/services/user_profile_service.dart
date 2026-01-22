import 'package:fitzee_new/core/services/connectivity_service.dart';
import 'package:fitzee_new/core/services/firestore_user_profile_service.dart';
import 'package:fitzee_new/core/services/local_storage_service.dart';
import 'package:fitzee_new/features/onboard/domain/entities/user_profile.dart';

/// Unified service that handles user profile operations
/// with automatic fallback to local storage when offline
class UserProfileService {
  /// Save user profile - saves to both Firestore (if online) and local storage
  static Future<void> saveUserProfile(UserProfile profile) async {
    // Always save to local storage first for offline support
    await LocalStorageService.saveUserProfile(profile);

    // If online, also save to Firestore
    final hasInternet = await ConnectivityService.hasInternetConnection();
    if (hasInternet && profile.userId != null && profile.userId!.isNotEmpty) {
      try {
        await FirestoreUserProfileService.saveUserProfile(profile);
      } catch (e) {
        // If Firestore save fails, local storage already has the data
        // Log error but don't throw - app can continue with local data
        print('Warning: Failed to save to Firestore, using local storage: $e');
      }
    }
  }

  /// Get user profile - tries Firestore if online, falls back to local storage
  static Future<UserProfile?> getUserProfile(String? userId) async {
    // Check internet connection
    final hasInternet = await ConnectivityService.hasInternetConnection();

    // If online and userId is provided, try Firestore first
    if (hasInternet && userId != null && userId.isNotEmpty) {
      try {
        final firestoreProfile =
            await FirestoreUserProfileService.getUserProfile(userId);
        
        // If found in Firestore, sync to local storage and return
        if (firestoreProfile != null) {
          await LocalStorageService.saveUserProfile(firestoreProfile);
          return firestoreProfile;
        }
      } catch (e) {
        // If Firestore fails, fall back to local storage
        print('Warning: Failed to get from Firestore, using local storage: $e');
      }
    }

    // Fall back to local storage (offline or Firestore unavailable)
    return await LocalStorageService.getUserProfile();
  }

  /// Update user profile - updates both Firestore (if online) and local storage
  static Future<void> updateUserProfile(UserProfile profile) async {
    // Always update local storage first
    await LocalStorageService.saveUserProfile(profile);

    // If online, also update Firestore
    final hasInternet = await ConnectivityService.hasInternetConnection();
    if (hasInternet && profile.userId != null && profile.userId!.isNotEmpty) {
      try {
        await FirestoreUserProfileService.updateUserProfile(profile);
      } catch (e) {
        // If Firestore update fails, local storage already has the data
        print('Warning: Failed to update Firestore, using local storage: $e');
      }
    }
  }

  /// Delete user profile from both Firestore and local storage
  static Future<void> deleteUserProfile(String userId) async {
    // Delete from local storage
    await LocalStorageService.clearUserProfile();

    // If online, also delete from Firestore
    final hasInternet = await ConnectivityService.hasInternetConnection();
    if (hasInternet) {
      try {
        await FirestoreUserProfileService.deleteUserProfile(userId);
      } catch (e) {
        print('Warning: Failed to delete from Firestore: $e');
      }
    }
  }

  /// Sync local profile to Firestore when connection is restored
  /// This can be called when app detects internet connection is restored
  static Future<void> syncLocalToFirestore(String? userId) async {
    if (userId == null || userId.isEmpty) return;

    final hasInternet = await ConnectivityService.hasInternetConnection();
    if (!hasInternet) return;

    try {
      final localProfile = await LocalStorageService.getUserProfile();
      if (localProfile != null) {
        await FirestoreUserProfileService.saveUserProfile(localProfile);
      }
    } catch (e) {
      print('Warning: Failed to sync local profile to Firestore: $e');
    }
  }
}
