import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:fitzee_new/core/constants/app_colors.dart';
import 'package:fitzee_new/features/splash/presentation/pages/splash1/cubit/splash_cubit.dart';
import 'package:fitzee_new/features/splash/presentation/core/widgets/app_icon_widget.dart';
import 'package:fitzee_new/features/splash/presentation/core/widgets/loading_indicator_widget.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeIn,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeOut,
      ),
    );

    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;

    // Mobile-only responsive sizes based on screen width
    // Small phones (320-360px)
    // Normal phones (360-480px)
    // Large phones (480-600px)
    double iconSize;
    double titleFontSize;
    double taglineFontSize;

    if (screenWidth < 360) {
      // Small phones
      iconSize = screenWidth * 0.25;
      titleFontSize = screenWidth * 0.12;
      taglineFontSize = screenWidth * 0.035;
    } else if (screenWidth < 480) {
      // Normal phones
      iconSize = screenWidth * 0.25;
      titleFontSize = screenWidth * 0.12;
      taglineFontSize = screenWidth * 0.035;
    } else {
      // Large phones / Small tablets (still mobile-oriented)
      iconSize = screenWidth * 0.22;
      titleFontSize = screenWidth * 0.11;
      taglineFontSize = screenWidth * 0.032;
    }

    return BlocProvider(
      create: (context) => SplashCubit(),
      child: BlocListener<SplashCubit, SplashState>(
        listener: (context, state) {
          if (mounted) {
            if (state is SplashNavigateToDashboard) {
              context.go('/dashboard');
            } else if (state is SplashNavigateToOnboard) {
              context.go('/onboard');
            } else if (state is SplashNavigateToAuth) {
              context.go('/phone_auth');
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
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 2),
                      // App Icon
                      AppIconWidget(size: iconSize),
                      const SizedBox(height: 32),
                      // App Name with glow effect
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            AppColors.primaryGreen,
                            AppColors.primaryGreenLight,
                            AppColors.primaryGreen,
                          ],
                        ).createShader(bounds),
                        child: Text(
                          'splash.app_name'.tr(),
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                            shadows: [
                              Shadow(
                                color: AppColors.primaryGreen.withOpacity(0.8),
                                blurRadius: 20,
                                offset: const Offset(0, 0),
                              ),
                              Shadow(
                                color: AppColors.primaryGreen.withOpacity(0.5),
                                blurRadius: 40,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Tagline
                      Text(
                        'splash.tagline'.tr(),
                        style: TextStyle(
                          color: AppColors.textWhite,
                          fontSize: taglineFontSize,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 2,
                        ),
                      ),
                      const Spacer(flex: 3),
                      // Loading Indicator
                      LoadingIndicatorWidget(),
                      SizedBox(
                        height: screenSize.height * 0.1,
                      ),
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

