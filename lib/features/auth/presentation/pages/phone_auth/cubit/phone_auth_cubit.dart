import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fitzee_new/core/services/local_storage_service.dart';
import 'package:fitzee_new/core/services/notification_service.dart';
import 'package:fitzee_new/core/services/user_profile_service.dart';
import '../../../../domain/usecases/send_otp_usecase.dart';
import '../../../../domain/usecases/verify_otp_usecase.dart';

part 'phone_auth_state.dart';

class PhoneAuthCubit extends Cubit<PhoneAuthState> {
  final SendOtpUseCase sendOtpUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;

  PhoneAuthCubit({
    required this.sendOtpUseCase,
    required this.verifyOtpUseCase,
  }) : super(PhoneAuthInitial());

  Future<void> sendOtp(String phoneNumber) async {
    emit(PhoneAuthLoading());
    try {
      await sendOtpUseCase(
        phoneNumber: phoneNumber,
        onCodeSent: (verificationId) {
          emit(OtpSent(verificationId));
        },
      );
    } catch (e) {
      emit(PhoneAuthError(e.toString()));
    }
  }

  Future<void> verifyOtp({
    required String verificationId,
    required String otp,
  }) async {
    emit(PhoneAuthLoading());
    try {
      final userCredential = await verifyOtpUseCase(
        verificationId: verificationId,
        otp: otp,
      );
      final userId = userCredential.user?.uid ?? '';
      
      await LocalStorageService.saveAuthState(
        isAuthenticated: true,
        userId: userId,
      );
      await NotificationService.saveTokenForUser(userId);

      var isOnboardCompleted = await LocalStorageService.isOnboardCompleted();
      // Existing user: restore onboard from Firestore if profile exists and is complete
      if (!isOnboardCompleted && userId.isNotEmpty) {
        final profile = await UserProfileService.getUserProfile(userId);
        if (profile != null && profile.isComplete) {
          await LocalStorageService.setOnboardCompleted(true);
          isOnboardCompleted = true;
        }
      }
      
      emit(PhoneAuthSuccess(userId, isOnboardCompleted));
    } catch (e) {
      emit(PhoneAuthError(e.toString()));
    }
  }
}
