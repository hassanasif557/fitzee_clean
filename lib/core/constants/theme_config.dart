import 'package:flutter/material.dart';
import 'app_colors.dart';

class ThemeConfig {
  ThemeConfig._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primaryGreen,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryGreen,
        secondary: AppColors.secondaryGreen,
        background: AppColors.backgroundLight,
        surface: AppColors.backgroundLightDark,
        error: AppColors.errorRed,
        onPrimary: AppColors.textWhite,
        onSecondary: AppColors.textWhite,
        onBackground: AppColors.textBlack,
        onSurface: AppColors.textBlack,
        onError: AppColors.textWhite,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: AppColors.textBlack,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: AppColors.textBlack,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: AppColors.textBlack,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: TextStyle(
          color: AppColors.textBlack,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: AppColors.textBlack,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: AppColors.textBlack,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: AppColors.textBlack,
        ),
        bodyMedium: TextStyle(
          color: AppColors.textBlack,
        ),
        bodySmall: TextStyle(
          color: AppColors.textGray,
        ),
        labelLarge: TextStyle(
          color: AppColors.textBlack,
        ),
        labelMedium: TextStyle(
          color: AppColors.textGray,
        ),
        labelSmall: TextStyle(
          color: AppColors.textGrayDark,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryGreen,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryGreen,
        secondary: AppColors.secondaryGreen,
        background: AppColors.backgroundDark,
        surface: AppColors.backgroundDarkLight,
        error: AppColors.errorRed,
        onPrimary: AppColors.textBlack,
        onSecondary: AppColors.textBlack,
        onBackground: AppColors.textWhite,
        onSurface: AppColors.textWhite,
        onError: AppColors.textWhite,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: AppColors.textWhite,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: AppColors.textWhite,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: AppColors.textWhite,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: TextStyle(
          color: AppColors.textWhite,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: AppColors.textWhite,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: AppColors.textWhite,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: AppColors.textWhite,
        ),
        bodyMedium: TextStyle(
          color: AppColors.textWhite,
        ),
        bodySmall: TextStyle(
          color: AppColors.textGray,
        ),
        labelLarge: TextStyle(
          color: AppColors.textWhite,
        ),
        labelMedium: TextStyle(
          color: AppColors.textGray,
        ),
        labelSmall: TextStyle(
          color: AppColors.textGrayDark,
        ),
      ),
    );
  }
}

