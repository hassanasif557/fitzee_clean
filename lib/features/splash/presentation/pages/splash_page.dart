import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:fitzee_new/core/constants/app_colors.dart';
import 'package:fitzee_new/features/splash/presentation/pages/splash1/cubit/splash_cubit.dart';
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

  Widget _buildFallbackLogo(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryGreen.withOpacity(0.9),
            AppColors.primaryGreenDark,
          ],
        ),
        borderRadius: BorderRadius.circular(size * 0.22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        'F',
        style: TextStyle(
          fontSize: size * 0.5,
          fontWeight: FontWeight.w300,
          color: Colors.white,
          letterSpacing: 0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;

    // Responsive sizes: logo, wordmark, tagline
    double logoSize;
    double wordmarkFontSize;
    double taglineFontSize;

    if (screenWidth < 360) {
      logoSize = screenWidth * 0.28;
      wordmarkFontSize = screenWidth * 0.14;
      taglineFontSize = screenWidth * 0.032;
    } else if (screenWidth < 480) {
      logoSize = screenWidth * 0.30;
      wordmarkFontSize = screenWidth * 0.15;
      taglineFontSize = screenWidth * 0.034;
    } else {
      logoSize = screenWidth * 0.26;
      wordmarkFontSize = screenWidth * 0.13;
      taglineFontSize = screenWidth * 0.030;
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
                      // Fitzee logo (F icon)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(logoSize * 0.22),
                        child: Image.asset(
                          'assets/icon/app_icon.png',
                          width: logoSize,
                          height: logoSize,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildFallbackLogo(logoSize),
                        ),
                      ),
                      const SizedBox(height: 28),
                      // Fitzee wordmark – elegant gradient + glow
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white,
                            AppColors.primaryGreenLight,
                            AppColors.primaryGreen,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ).createShader(bounds),
                        child: Text(
                          'Fitzee',
                          style: TextStyle(
                            fontSize: wordmarkFontSize,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 8,
                            color: Colors.white,
                            height: 1.15,
                            shadows: [
                              Shadow(
                                color: AppColors.primaryGreen.withOpacity(0.6),
                                blurRadius: 24,
                                offset: const Offset(0, 0),
                              ),
                              Shadow(
                                color: AppColors.primaryGreen.withOpacity(0.35),
                                blurRadius: 48,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Tagline
                      Text(
                        'splash.tagline'.tr(),
                        style: TextStyle(
                          color: AppColors.textWhite.withOpacity(0.85),
                          fontSize: taglineFontSize,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 4,
                        ),
                      ),
                      const Spacer(flex: 3),
                      LoadingIndicatorWidget(),
                      SizedBox(height: screenSize.height * 0.1),
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

