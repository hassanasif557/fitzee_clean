import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
  });

  Future<UserCredential> verifyOtp({
    required String verificationId,
    required String otp,
  });
}
