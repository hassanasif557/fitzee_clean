import 'package:fitzee_new/core/services/daily_data_service.dart';
import 'package:fitzee_new/core/services/daily_nutrition_service.dart';
import 'package:fitzee_new/core/services/google_sign_in_service.dart';
import 'package:fitzee_new/core/models/meal_preferences.dart';
import 'package:fitzee_new/core/services/local_storage_service.dart';
import 'package:fitzee_new/core/services/meal_preferences_service.dart';
import 'package:fitzee_new/core/services/medical_entry_service.dart';
import 'package:fitzee_new/core/services/notification_service.dart';
import 'package:fitzee_new/core/services/workout_tracking_service.dart';
import 'package:fitzee_new/core/services/firestore_user_profile_service.dart';
import 'package:fitzee_new/features/auth/domain/repositories/account_cleanup_repository.dart';

/// Implementation of [AccountCleanupRepository] (Clean Architecture: data layer).
/// Uses core services to clear all user-related data on sign-out or account deletion.
class AccountCleanupRepositoryImpl implements AccountCleanupRepository {
  @override
  Future<void> signOut({String? userId}) async {
    await GoogleSignInService.signOut();
    if (userId != null) {
      await NotificationService.clearTokenForUserOnSignOut(userId);
    }
    await LocalStorageService.clearAllUserDataOnSignOut();
    await MealPreferencesService.save(const MealPreferences());
    await DailyDataService.clearLocalData();
    await MedicalEntryService.clearLocalData();
    await DailyNutritionService.clearLocalData();
    await WorkoutTrackingService.clearLocalData();
  }

  /// Delete Firestore profile and FCM token while user is still authenticated (before Auth user.delete()).
  @override
  Future<void> deleteUserDataFromCloud(String userId) async {
    await FirestoreUserProfileService.deleteUserProfile(userId);
    await NotificationService.clearTokenForUserOnSignOut(userId);
  }

  @override
  Future<void> afterAccountDeleted(String userId) async {
    await GoogleSignInService.signOut();
    await LocalStorageService.clearAllUserDataOnSignOut();
    await MealPreferencesService.save(const MealPreferences());
    await DailyDataService.clearLocalData();
    await MedicalEntryService.clearLocalData();
    await DailyNutritionService.clearLocalData();
    await WorkoutTrackingService.clearLocalData();
  }
}
