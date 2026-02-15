import 'package:flutter/material.dart';
import 'package:fitzee_new/core/constants/app_colors.dart';

/// Theme-aware colors so light/dark mode changes backgrounds and text.
extension ThemeContext on BuildContext {
  Color get themeScaffoldBg => Theme.of(this).scaffoldBackgroundColor;
  Color get themeSurface => Theme.of(this).colorScheme.surface;
  Color get themeOnSurface => Theme.of(this).colorScheme.onSurface;
  Color get themePrimary => Theme.of(this).colorScheme.primary;
  Color get themeOnPrimary => Theme.of(this).colorScheme.onPrimary;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// Primary green (same in both themes for accent)
  Color get accentGreen => AppColors.primaryGreen;
  Color get errorRed => AppColors.errorRed;
}
