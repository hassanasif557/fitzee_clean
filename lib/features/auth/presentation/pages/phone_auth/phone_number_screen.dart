import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:fitzee_new/core/constants/app_colors.dart';
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
