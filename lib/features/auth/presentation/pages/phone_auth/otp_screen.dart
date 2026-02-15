import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitzee_new/core/constants/app_colors.dart';
import 'package:fitzee_new/core/services/crashlytics_service.dart';
import 'cubit/phone_auth_cubit.dart';
import '../../core/di/auth_di.dart';

class OtpScreen extends StatefulWidget {
  final String verificationId;

  const OtpScreen({
    super.key,
    required this.verificationId,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  String? _validateOtp(String? value) {
    if (value == null || value.isEmpty) {
      return 'auth.otp_required'.tr();
    }
    if (value.length != 6) {
      return 'auth.otp_invalid'.tr();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;

    return BlocProvider(
      create: (context) => AuthDI.getPhoneAuthCubit(),
      child: BlocListener<PhoneAuthCubit, PhoneAuthState>(
        listener: (context, state) {
          if (state is PhoneAuthSuccess) {
            CrashlyticsService.setUserIdentifier(state.userId);
            if (mounted) {
              if (state.isOnboardCompleted) {
                context.go('/dashboard');
              } else {
                context.go('/onboard');
              }
            }
          } else if (state is PhoneAuthError) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.errorRed,
                ),
              );
            }
          }
        },
        child: Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.backgroundDarkBlueGreen,
                  AppColors.backgroundDarkBlueGreen.withOpacity(0.98),
                  AppColors.backgroundDarkBlueGreen,
                ],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth < 360 ? 20 : 24,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        // Back Button
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: AppColors.textWhite,
                            ),
                            onPressed: () => context.go('/phone_auth'),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Title
                        Text(
                          'auth.otp_title'.tr(),
                          style: TextStyle(
                            fontSize: screenWidth < 360 ? 24 : 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textWhite,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'auth.otp_subtitle'.tr(),
                          style: TextStyle(
                            fontSize: screenWidth < 360 ? 14 : 16,
                            color: AppColors.textGray,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        // OTP Input
                        TextFormField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          style: const TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 24,
                            letterSpacing: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: '000000',
                            hintStyle: TextStyle(
                              color: AppColors.textGray.withOpacity(0.5),
                              fontSize: 24,
                              letterSpacing: 8,
                            ),
                            counterText: '',
                            filled: true,
                            fillColor: AppColors.backgroundDarkLight,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.borderGreen,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.borderGreen,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.primaryGreen,
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.errorRed,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.errorRed,
                                width: 2,
                              ),
                            ),
                          ),
                          validator: _validateOtp,
                        ),
                        const SizedBox(height: 32),
                        // Verify Button
                        BlocBuilder<PhoneAuthCubit, PhoneAuthState>(
                          builder: (context, state) {
                            final isLoading = state is PhoneAuthLoading;
                            return SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        if (_formKey.currentState!.validate()) {
                                          context
                                              .read<PhoneAuthCubit>()
                                              .verifyOtp(
                                                verificationId:
                                                    widget.verificationId,
                                                otp: _otpController.text,
                                              );
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryGreen,
                                  foregroundColor: AppColors.textBlack,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  disabledBackgroundColor:
                                      AppColors.primaryGreen.withOpacity(0.5),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            AppColors.textBlack,
                                          ),
                                        ),
                                      )
                                    : Text(
                                        'auth.verify'.tr(),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        // Resend OTP
                        TextButton(
                          onPressed: () {
                            // TODO: Implement resend OTP
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('auth.resend_otp'.tr()),
                                backgroundColor: AppColors.infoBlue,
                              ),
                            );
                          },
                          child: Text(
                            'auth.resend_otp'.tr(),
                            style: const TextStyle(
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
