import 'package:equatable/equatable.dart';
import 'package:fitzee_new/features/onboard/domain/entities/user_profile.dart';

/// Base state for profile screen (Bloc/Cubit state management).
sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any load.
class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

/// Profile is being loaded.
class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

/// Profile loaded successfully; [profile] may be null if none exists.
class ProfileLoaded extends ProfileState {
  final UserProfile? profile;

  const ProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

/// Profile is being saved (e.g. from edit screen).
class ProfileSaving extends ProfileState {
  const ProfileSaving();
}

/// Profile was saved successfully; [profile] is the updated profile.
class ProfileSaveSuccess extends ProfileState {
  final UserProfile profile;

  const ProfileSaveSuccess(this.profile);

  @override
  List<Object?> get props => [profile];
}

/// An error occurred (load or save).
class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
