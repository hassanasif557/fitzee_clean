import '../repositories/auth_repository.dart';

class SendOtpUseCase {
  final AuthRepository repository;

  SendOtpUseCase(this.repository);

  Future<void> call({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
  }) {
    return repository.sendOtp(
      phoneNumber: phoneNumber,
      onCodeSent: onCodeSent,
    );
  }
}
