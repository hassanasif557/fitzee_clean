import 'package:flutter/material.dart';
import 'package:fitzee_new/core/constants/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';

class LoadingIndicatorWidget extends StatefulWidget {
  const LoadingIndicatorWidget({super.key});

  @override
  State<LoadingIndicatorWidget> createState() => _LoadingIndicatorWidgetState();
}

class _LoadingIndicatorWidgetState extends State<LoadingIndicatorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = screenWidth > 600 ? 500.0 : screenWidth * 0.85;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Glowing dot with animation
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGreen.withOpacity(
                      0.5 + (_animation.value * 0.5),
                    ),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        // Loading text
        Text(
          'splash.initializing'.tr(),
          style: const TextStyle(
            color: AppColors.textWhite,
            fontSize: 12,
            fontWeight: FontWeight.w400,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        // Loading bar
        SizedBox(
          width: maxWidth,
          height: 4,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: AppColors.loadingBarBackground,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: Stack(
                    children: [
                      // Background
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: AppColors.loadingBarBackground,
                      ),
                      // Animated fill
                      FractionallySizedBox(
                        widthFactor: 0.3 + (_animation.value * 0.4),
                        alignment: Alignment.centerLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            gradient: LinearGradient(
                              colors: [
                                AppColors.loadingBarFill,
                                AppColors.loadingBarFill.withOpacity(0.8),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.loadingBarFill.withOpacity(0.5),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

