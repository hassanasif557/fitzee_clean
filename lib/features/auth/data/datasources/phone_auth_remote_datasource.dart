import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

abstract class PhoneAuthRemoteDataSource {
  Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
  });

  Future<UserCredential> verifyOtp({
    required String verificationId,
    required String otp,
  });
}

class PhoneAuthRemoteDataSourceImpl
    implements PhoneAuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;

  PhoneAuthRemoteDataSourceImpl(this._firebaseAuth);

  @override
  Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
  }) async {
    final completer = Completer<void>();
    bool codeSent = false;

    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-verification completed (usually on Android)
        if (!completer.isCompleted) {
          await _firebaseAuth.signInWithCredential(credential);
          completer.complete();
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        if (!completer.isCompleted) {
          String errorMessage = 'Phone verification failed';
          switch (e.code) {
            case 'invalid-phone-number':
              errorMessage = 'Invalid phone number format';
              break;
            case 'too-many-requests':
              errorMessage = 'Too many requests. Please try again later';
              break;
            case 'quota-exceeded':
              errorMessage = 'SMS quota exceeded. Please try again later';
              break;
            case 'billing-not-enabled':
            case 'BILLING_NOT_ENABLED':
              errorMessage =
                  'Phone authentication requires billing to be enabled in Firebase Console. Please contact support.';
              break;
            default:
              // Check if error message contains billing info
              if (e.message?.contains('BILLING_NOT_ENABLED') == true ||
                  e.message?.contains('billing') == true) {
                errorMessage =
                    'Phone authentication requires billing to be enabled in Firebase Console. Please contact support.';
              } else {
                errorMessage = e.message ?? 'Phone verification failed';
              }
          }
          completer.completeError(Exception(errorMessage));
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        if (!codeSent) {
          codeSent = true;
          onCodeSent(verificationId);
          if (!completer.isCompleted) {
            completer.complete();
          }
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Auto-retrieval timeout (usually on Android)
        // If code wasn't sent yet, we can still use this verificationId
        if (!codeSent && !completer.isCompleted) {
          codeSent = true;
          onCodeSent(verificationId);
          completer.complete();
        }
      },
    );

    return completer.future;
  }

  @override
  Future<UserCredential> verifyOtp({
    required String verificationId,
    required String otp,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      return await _firebaseAuth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'OTP verification failed';
      switch (e.code) {
        case 'invalid-verification-code':
          errorMessage = 'Invalid OTP code';
          break;
        case 'session-expired':
          errorMessage = 'OTP session expired. Please request a new code';
          break;
        default:
          errorMessage = e.message ?? 'OTP verification failed';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }
}
