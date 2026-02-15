/// Repository for account cleanup on sign-out and account deletion (Clean Architecture: domain).
/// Implementation clears Google sign-in, FCM token, local storage, and app-specific data.
/// Used by [SignOutUseCase] and [DeleteAccountUseCase] so UI/cubits do not call services directly.
abstract class AccountCleanupRepository {
  /// Performs all cleanup after user signs out: Google sign-out, clear FCM token,
  /// clear local user data and app caches. Does not throw; caller handles navigation.
  Future<void> signOut({String? userId});

  /// Deletes user data from cloud (Firestore, FCM token) **while still authenticated**.
  /// Call this **before** [FirebaseAuth.currentUser?.delete()] so Firestore rules allow the delete.
  Future<void> deleteUserDataFromCloud(String userId);

  /// Performs local cleanup after Firebase account is deleted: Google sign-out, clear local data.
  /// Call after [FirebaseAuth.currentUser?.delete()].
  Future<void> afterAccountDeleted(String userId);
}
