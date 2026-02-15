import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:fitzee_new/core/constants/app_colors.dart';
import 'package:fitzee_new/core/services/crashlytics_service.dart';
import 'package:fitzee_new/core/services/google_sign_in_service.dart';
import 'package:fitzee_new/core/services/local_storage_service.dart';
import 'package:fitzee_new/core/services/notification_service.dart';
import 'package:fitzee_new/core/services/user_profile_service.dart';
import 'cubit/phone_auth_cubit.dart';
import '../../core/di/auth_di.dart';

class PhoneNumberScreen extends StatefulWidget {
  const PhoneNumberScreen({super.key});

  @override
  State<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  CountryCode _selectedCountryCode = CountryCode.fromCountryCode('IN');
  bool _isGoogleSignInLoading = false;

  @override
  void initState() {
    super.initState();
    _clearGoogleCacheSoAccountPickerShows();
  }

  /// So that "Sign in with Google" shows account picker instead of auto-selecting last account.
  Future<void> _clearGoogleCacheSoAccountPickerShows() async {
    try {
      await GoogleSignInService.clearCachedAccount();
    } catch (_) {}
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'auth.phone_required'.tr();
    }
    if (value.length < 10) {
      return 'auth.phone_invalid'.tr();
    }
    return null;
  }

  /// User-friendly message for Google Sign-In platform errors (e.g. SHA-1, client ID).
  String _googleSignInErrorMessage(PlatformException e) {
    final code = e.code;
    final msg = e.message ?? '';
    if (code == 'sign_in_failed' ||
        msg.toLowerCase().contains('sign in failed') ||
        msg.toLowerCase().contains('developer error') ||
        code == '10') {
      return 'Google sign-in failed. Add your app SHA-1 in Firebase Console (Project settings > Your apps > Android) and re-download google-services.json.';
    }
    if (code == 'network_error' || msg.toLowerCase().contains('network')) {
      return 'Network error. Check your connection and try again.';
    }
    return msg.isNotEmpty ? msg : 'Google sign-in failed. Try again.';
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isGoogleSignInLoading = true);
    try {
      final userCredential =
          await GoogleSignInService.signInWithGoogle();
      final userId = userCredential.user?.uid ?? '';
      if (userId.isEmpty) {
        throw Exception('Google sign-in did not return a user');
      }
      await LocalStorageService.saveAuthState(
        isAuthenticated: true,
        userId: userId,
      );
      await CrashlyticsService.setUserIdentifier(userId);
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
      if (!mounted) return;
      if (isOnboardCompleted) {
        context.go('/dashboard');
      } else {
        context.go('/onboard');
      }
    } on PlatformException catch (e) {
      if (!mounted) return;
      if (e.code == 'sign_in_canceled' ||
          (e.message ?? '').toLowerCase().contains('cancel')) {
        setState(() => _isGoogleSignInLoading = false);
        return;
      }
      final String message = _googleSignInErrorMessage(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.errorRed,
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().replaceFirst('Exception: ', '');
      if (message.toLowerCase().contains('cancelled')) {
        setState(() => _isGoogleSignInLoading = false);
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.errorRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _isGoogleSignInLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;

    return BlocProvider(
      create: (context) => AuthDI.getPhoneAuthCubit(),
      child: BlocListener<PhoneAuthCubit, PhoneAuthState>(
        listener: (context, state) {
          if (state is OtpSent) {
            if (mounted) {
              context.go('/otp', extra: state.verificationId);
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
                        // Title
                        Text(
                          'auth.phone_title'.tr(),
                          style: TextStyle(
                            fontSize: screenWidth < 360 ? 24 : 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textWhite,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'auth.phone_subtitle'.tr(),
                          style: TextStyle(
                            fontSize: screenWidth < 360 ? 14 : 16,
                            color: AppColors.textGray,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        // Phone Number Input with Country Code Picker
                        Row(
                          children: [
                            // Country Code Picker
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.backgroundDarkLight,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.borderGreen,
                                ),
                              ),
                              child: CountryCodePicker(
                                onChanged: (CountryCode countryCode) {
                                  setState(() {
                                    _selectedCountryCode = countryCode;
                                  });
                                },
                                initialSelection: _selectedCountryCode.code,
                                favorite: const ['+91', 'IN', '+1', 'US'],
                                showCountryOnly: false,
                                showOnlyCountryWhenClosed: false,
                                alignLeft: false,
                                showFlagDialog: true,
                                backgroundColor: AppColors.backgroundDarkLight,
                                textStyle: const TextStyle(
                                  color: AppColors.textWhite,
                                  fontSize: 16,
                                ),
                                dialogTextStyle: const TextStyle(
                                  color: AppColors.textWhite,
                                ),
                                searchDecoration: InputDecoration(
                                  hintText: 'Search country',
                                  hintStyle: TextStyle(
                                    color: AppColors.textGray,
                                  ),
                                  filled: true,
                                  fillColor: AppColors.backgroundDarkLight,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AppColors.borderGreen,
                                    ),
                                  ),
                                ),
                                dialogBackgroundColor:
                                    AppColors.backgroundDarkBlueGreen,
                                flagDecoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 0,
                                ),
                                builder: (countryCode) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        countryCode?.dialCode ?? '+91',
                                        style: const TextStyle(
                                          color: AppColors.textWhite,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.arrow_drop_down,
                                        color: AppColors.textWhite,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Phone Number Input
                            Expanded(
                              child: TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                style: const TextStyle(
                                  color: AppColors.textWhite,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'auth.phone_hint'.tr(),
                                  hintStyle: const TextStyle(
                                    color: AppColors.textGray,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.phone,
                                    color: AppColors.primaryGreen,
                                  ),
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
                                validator: _validatePhoneNumber,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        // Continue Button
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
                                          final fullPhoneNumber =
                                              '${_selectedCountryCode.dialCode}${_phoneController.text}';
                                          context
                                              .read<PhoneAuthCubit>()
                                              .sendOtp(fullPhoneNumber);
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
                                        'auth.continue'.tr(),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        // Divider with "or"
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1,
                                color: AppColors.borderGreen,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                'or',
                                style: TextStyle(
                                  color: AppColors.textGray,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 1,
                                color: AppColors.borderGreen,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Sign in with Google
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton.icon(
                            onPressed: _isGoogleSignInLoading ? null : _signInWithGoogle,
                            icon: _isGoogleSignInLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.primaryGreen,
                                      ),
                                    ),
                                  )
                                : Icon(
                                    Icons.g_mobiledata_rounded,
                                    size: 28,
                                    color: AppColors.textWhite,
                                  ),
                            label: Text(
                              _isGoogleSignInLoading
                                  ? 'Signing in...'
                                  : 'Sign in with Google',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textWhite,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: AppColors.borderGreen,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor:
                                  AppColors.backgroundDarkLight.withOpacity(0.5),
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
