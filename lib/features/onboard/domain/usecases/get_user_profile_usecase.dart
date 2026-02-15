import 'package:fitzee_new/features/onboard/domain/entities/user_profile.dart';
import 'package:fitzee_new/features/onboard/domain/repositories/user_profile_repository.dart';

/// Use case: load user profile by userId (Clean Architecture: domain).
/// Used by [ProfileCubit] and [OnboardCubit] so UI does not call the repository/service directly.
class GetUserProfileUseCase {
  final UserProfileRepository _repository;

  GetUserProfileUseCase(this._repository);

  Future<UserProfile?> call(String? userId) => _repository.getProfile(userId);
}
