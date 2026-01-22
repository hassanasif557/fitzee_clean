part of 'phone_auth_cubit.dart';

sealed class PhoneAuthState extends Equatable {
  const PhoneAuthState();

  @override
  List<Object> get props => [];
}

final class PhoneAuthInitial extends PhoneAuthState {}

final class PhoneAuthLoading extends PhoneAuthState {}

final class OtpSent extends PhoneAuthState {
  final String verificationId;

  const OtpSent(this.verificationId);

  @override
  List<Object> get props => [verificationId];
}

final class PhoneAuthSuccess extends PhoneAuthState {
  final String userId;
  final bool isOnboardCompleted;

  const PhoneAuthSuccess(this.userId, this.isOnboardCompleted);

  @override
  List<Object> get props => [userId, isOnboardCompleted];
}

final class PhoneAuthError extends PhoneAuthState {
  final String message;

  const PhoneAuthError(this.message);

  @override
  List<Object> get props => [message];
}
