import 'package:fitzee_new/core/services/crashlytics_service.dart';
import 'package:fitzee_new/features/auth/domain/repositories/account_cleanup_repository.dart';

/// Use case: delete user data from cloud (Firestore, FCM) **before** Auth user is deleted.
/// Call this first while still authenticated; then caller performs [FirebaseAuth.currentUser?.delete()],
/// then sign-out use case for local cleanup.
class DeleteAccountUseCase {
  final AccountCleanupRepository _accountCleanupRepository;

  DeleteAccountUseCase(this._accountCleanupRepository);

  Future<void> call(String userId) async {
    await CrashlyticsService.setLastAction('delete_account');
    await _accountCleanupRepository.deleteUserDataFromCloud(userId);
    await CrashlyticsService.clearUser();
  }
}
