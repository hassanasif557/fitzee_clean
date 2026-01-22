import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fitzee_new/features/onboard/domain/entities/user_profile.dart';

class FirestoreUserProfileService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'user_profiles';

  /// Save user profile to Firestore
  static Future<void> saveUserProfile(UserProfile profile) async {
    if (profile.userId == null || profile.userId!.isEmpty) {
      throw Exception('User ID is required to save profile');
    }

    try {
      final profileData = profile.toJson();
      await _firestore
          .collection(_collectionName)
          .doc(profile.userId)
          .set(profileData, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied' || 
          e.message?.contains('PERMISSION_DENIED') == true ||
          e.message?.contains('API has not been used') == true) {
        throw Exception(
          'Firestore API not enabled. Please enable Cloud Firestore API in Firebase Console: '
          'https://console.developers.google.com/apis/api/firestore.googleapis.com/overview?project=fitzee-c7e4d'
        );
      }
      throw Exception('Failed to save profile to Firestore: ${e.message}');
    } catch (e) {
      throw Exception('Failed to save profile to Firestore: $e');
    }
  }

  /// Get user profile from Firestore
  static Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final docSnapshot = await _firestore
          .collection(_collectionName)
          .doc(userId)
          .get();

      if (!docSnapshot.exists) {
        return null;
      }

      final data = docSnapshot.data();
      if (data == null) {
        return null;
      }

      return UserProfile.fromJson(data);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied' || 
          e.message?.contains('PERMISSION_DENIED') == true ||
          e.message?.contains('API has not been used') == true) {
        // Return null instead of throwing - let it fall back to local storage
        return null;
      }
      throw Exception('Failed to get profile from Firestore: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get profile from Firestore: $e');
    }
  }

  /// Update user profile in Firestore
  static Future<void> updateUserProfile(UserProfile profile) async {
    if (profile.userId == null || profile.userId!.isEmpty) {
      throw Exception('User ID is required to update profile');
    }

    try {
      final profileData = profile.toJson();
      await _firestore
          .collection(_collectionName)
          .doc(profile.userId)
          .update(profileData);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied' || 
          e.message?.contains('PERMISSION_DENIED') == true ||
          e.message?.contains('API has not been used') == true) {
        throw Exception(
          'Firestore API not enabled. Please enable Cloud Firestore API in Firebase Console: '
          'https://console.developers.google.com/apis/api/firestore.googleapis.com/overview?project=fitzee-c7e4d'
        );
      }
      throw Exception('Failed to update profile in Firestore: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update profile in Firestore: $e');
    }
  }

  /// Delete user profile from Firestore
  static Future<void> deleteUserProfile(String userId) async {
    try {
      await _firestore.collection(_collectionName).doc(userId).delete();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied' || 
          e.message?.contains('PERMISSION_DENIED') == true ||
          e.message?.contains('API has not been used') == true) {
        throw Exception(
          'Firestore API not enabled. Please enable Cloud Firestore API in Firebase Console: '
          'https://console.developers.google.com/apis/api/firestore.googleapis.com/overview?project=fitzee-c7e4d'
        );
      }
      throw Exception('Failed to delete profile from Firestore: ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete profile from Firestore: $e');
    }
  }
}
