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
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundLightDark,
        foregroundColor: AppColors.textBlack,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textBlack),
      ),
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryGreen,
        secondary: AppColors.secondaryGreen,
        background: AppColors.backgroundLight,
        surface: AppColors.backgroundLightDark,
        error: AppColors.errorRed,
        onPrimary: AppColors.textBlack,
        onSecondary: AppColors.textBlack,
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
      scaffoldBackgroundColor: AppColors.backgroundDarkBlueGreen,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundDarkLight,
        foregroundColor: AppColors.textWhite,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textWhite),
      ),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryGreen,
        secondary: AppColors.secondaryGreen,
        background: AppColors.backgroundDarkBlueGreen,
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

