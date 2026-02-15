import 'package:bloc/bloc.dart';
import 'package:fitzee_new/core/services/local_storage_service.dart';
import 'package:fitzee_new/features/onboard/domain/entities/user_profile.dart';
import 'package:fitzee_new/features/onboard/domain/usecases/get_user_profile_usecase.dart';
import 'package:fitzee_new/features/onboard/domain/usecases/save_user_profile_usecase.dart';

import 'profile_state.dart';

/// Cubit for profile screen (Bloc/Cubit state management).
/// Loads and saves profile via use cases only (Clean Architecture).
class ProfileCubit extends Cubit<ProfileState> {
  final GetUserProfileUseCase getUserProfileUseCase;
  final SaveUserProfileUseCase saveUserProfileUseCase;

  ProfileCubit({
    required this.getUserProfileUseCase,
    required this.saveUserProfileUseCase,
  }) : super(ProfileInitial());

  /// Loads the current user's profile. Call when opening the profile screen.
  Future<void> loadProfile() async {
    if (isClosed) return;
    emit(ProfileLoading());
    try {
      final userId = await LocalStorageService.getUserId();
      final profile = await getUserProfileUseCase(userId);
      if (isClosed) return;
      if (!isClosed) {
        emit(ProfileLoaded(profile));
      }
    } catch (e) {
      if (!isClosed) {
        emit(ProfileError(e.toString()));
      }
    }
  }

  /// Saves the given profile. Call from edit profile screen after user taps Save.
  Future<bool> saveProfile(UserProfile profile) async {
    if (isClosed) return false;
    emit(ProfileSaving());
    try {
      await saveUserProfileUseCase(profile);
      if (isClosed) return false;
      if (!isClosed) {
        emit(ProfileSaveSuccess(profile));
      }
      return true;
    } catch (e) {
      if (!isClosed) {
        emit(ProfileError(e.toString()));
      }
      return false;
    }
  }
}
