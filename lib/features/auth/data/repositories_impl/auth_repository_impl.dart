import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/phone_auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final PhoneAuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
  }) {
    return remoteDataSource.sendOtp(
      phoneNumber: phoneNumber,
      onCodeSent: onCodeSent,
    );
  }

  @override
  Future<UserCredential> verifyOtp({
    required String verificationId,
    required String otp,
  }) {
    return remoteDataSource.verifyOtp(
      verificationId: verificationId,
      otp: otp,
    );
  }
}
