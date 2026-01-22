import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fitzee_new/core/services/local_storage_service.dart';

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
    
    // Check authentication and onboard status
    final isAuthenticated = await LocalStorageService.isAuthenticated();
    final isOnboardCompleted =
        await LocalStorageService.isOnboardCompleted();
    
    if (isAuthenticated && isOnboardCompleted) {
      // User is logged in and completed onboard - go to dashboard
      emit(SplashNavigateToDashboard());
    } else if (isAuthenticated && !isOnboardCompleted) {
      // User is logged in but hasn't completed onboard - go to onboard
      emit(SplashNavigateToOnboard());
    } else {
      // User is not logged in - go to phone auth
      emit(SplashNavigateToAuth());
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
