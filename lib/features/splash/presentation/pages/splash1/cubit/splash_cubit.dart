import 'dart:async';
/// Cubit for the splash screen: decides whether to navigate to auth, onboard, or dashboard.
/// Uses [AuthRepository] and local flags (onboard completed, user profile) for the decision.
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fitzee_new/core/services/crashlytics_service.dart';
import 'package:fitzee_new/core/services/local_storage_service.dart';
import 'package:fitzee_new/core/services/user_profile_service.dart';

part 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashInitial()) {
    _initSplash();
  }

  Timer? _timer;

  Future<void> _initSplash() async {
    emit(SplashLoading());
    
    // Wait for splash animation
    await Future.delayed(const Duration(seconds: 2));
    
    final isAuthenticated = await LocalStorageService.isAuthenticated();
    var isOnboardCompleted = await LocalStorageService.isOnboardCompleted();
    final userId = await LocalStorageService.getUserId();

    if (isAuthenticated && userId != null && userId.isNotEmpty) {
      await CrashlyticsService.setUserIdentifier(userId);
    } else {
      await CrashlyticsService.clearUser();
    }

    // Existing user: restore onboard status from Firestore if local was cleared (e.g. after sign out)
    if (isAuthenticated && !isOnboardCompleted && userId != null && userId.isNotEmpty) {
      final profile = await UserProfileService.getUserProfile(userId);
      if (profile != null && profile.isComplete) {
        await LocalStorageService.setOnboardCompleted(true);
        isOnboardCompleted = true;
      }
    }

    if (isAuthenticated && isOnboardCompleted) {
      emit(SplashNavigateToDashboard());
    } else if (isAuthenticated && !isOnboardCompleted) {
      emit(SplashNavigateToOnboard());
    } else {
      emit(SplashNavigateToAuth());
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
