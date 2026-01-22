import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/datasources/phone_auth_remote_datasource.dart';
import '../../../data/repositories_impl/auth_repository_impl.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/usecases/send_otp_usecase.dart';
import '../../../domain/usecases/verify_otp_usecase.dart';
import '../../pages/phone_auth/cubit/phone_auth_cubit.dart';

class AuthDI {
  static PhoneAuthCubit getPhoneAuthCubit() {
    final firebaseAuth = FirebaseAuth.instance;
    final remoteDataSource = PhoneAuthRemoteDataSourceImpl(firebaseAuth);
    final repository = AuthRepositoryImpl(remoteDataSource);
    final sendOtpUseCase = SendOtpUseCase(repository);
    final verifyOtpUseCase = VerifyOtpUseCase(repository);
    
    return PhoneAuthCubit(
      sendOtpUseCase: sendOtpUseCase,
      verifyOtpUseCase: verifyOtpUseCase,
    );
  }
}
