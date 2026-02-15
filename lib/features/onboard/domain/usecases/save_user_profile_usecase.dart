import 'package:fitzee_new/features/onboard/domain/entities/user_profile.dart';
import 'package:fitzee_new/features/onboard/domain/repositories/user_profile_repository.dart';

/// Use case: save user profile (Clean Architecture: domain).
/// Used by [ProfileCubit] and [OnboardCubit] so UI does not call the repository/service directly.
class SaveUserProfileUseCase {
  final UserProfileRepository _repository;

  SaveUserProfileUseCase(this._repository);

  Future<void> call(UserProfile profile) => _repository.saveProfile(profile);
}
