import 'package:fitzee_new/core/services/crashlytics_service.dart';
import 'package:fitzee_new/core/services/local_storage_service.dart';
import 'package:fitzee_new/features/auth/domain/repositories/account_cleanup_repository.dart';

/// Use case: sign out the current user (Clean Architecture: domain).
/// Records last action for Crashlytics, then delegates cleanup to [AccountCleanupRepository].
/// Used by [DashboardCubit] so UI only calls cubit.signOut() and listens for success.
class SignOutUseCase {
  final AccountCleanupRepository _accountCleanupRepository;

  SignOutUseCase(this._accountCleanupRepository);

  Future<void> call() async {
    await CrashlyticsService.setLastAction('sign_out');
    final userId = await LocalStorageService.getUserId();
    await _accountCleanupRepository.signOut(userId: userId);
    await CrashlyticsService.clearUser();
  }
}
