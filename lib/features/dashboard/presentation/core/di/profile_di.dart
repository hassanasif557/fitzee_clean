import 'package:fitzee_new/features/dashboard/presentation/cubit/profile_cubit.dart';
import 'package:fitzee_new/features/onboard/data/repositories/user_profile_repository_impl.dart';
import 'package:fitzee_new/features/onboard/domain/repositories/user_profile_repository.dart';
import 'package:fitzee_new/features/onboard/domain/usecases/get_user_profile_usecase.dart';
import 'package:fitzee_new/features/onboard/domain/usecases/save_user_profile_usecase.dart';

/// Dependency injection for the profile feature (Clean Architecture).
/// Provides [ProfileCubit] with use cases; use cases get [UserProfileRepository] from here.
class ProfileDi {
  static final UserProfileRepository _userProfileRepository =
      UserProfileRepositoryImpl();

  static GetUserProfileUseCase get _getUserProfileUseCase =>
      GetUserProfileUseCase(_userProfileRepository);
  static SaveUserProfileUseCase get _saveUserProfileUseCase =>
      SaveUserProfileUseCase(_userProfileRepository);

  static ProfileCubit createCubit() => ProfileCubit(
        getUserProfileUseCase: _getUserProfileUseCase,
        saveUserProfileUseCase: _saveUserProfileUseCase,
      );
}
