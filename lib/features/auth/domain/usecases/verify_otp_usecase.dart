import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/auth_repository.dart';

class VerifyOtpUseCase {
  final AuthRepository repository;

  VerifyOtpUseCase(this.repository);

  Future<UserCredential> call({
    required String verificationId,
    required String otp,
  }) {
    return repository.verifyOtp(
      verificationId: verificationId,
      otp: otp,
    );
  }
}
