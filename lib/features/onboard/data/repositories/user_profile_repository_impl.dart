import 'package:fitzee_new/core/services/local_storage_service.dart';
import 'package:fitzee_new/core/services/user_profile_service.dart';
import 'package:fitzee_new/features/onboard/domain/entities/user_profile.dart';
import 'package:fitzee_new/features/onboard/domain/repositories/user_profile_repository.dart';

/// Implementation of [UserProfileRepository] (Clean Architecture: data layer).
/// Delegates to [UserProfileService] so domain/presentation do not depend on the service directly.
class UserProfileRepositoryImpl implements UserProfileRepository {
  @override
  Future<UserProfile?> getProfile(String? userId) =>
      UserProfileService.getUserProfile(userId);

  @override
  Future<void> saveProfile(UserProfile profile) =>
      UserProfileService.saveUserProfile(profile);
}
