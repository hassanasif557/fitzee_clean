part of 'splash_cubit.dart';

sealed class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object> get props => [];
}

final class SplashInitial extends SplashState {}

final class SplashLoading extends SplashState {}

final class SplashNavigateToAuth extends SplashState {}

final class SplashNavigateToOnboard extends SplashState {}

final class SplashNavigateToDashboard extends SplashState {}
