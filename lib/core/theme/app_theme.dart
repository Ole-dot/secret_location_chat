import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.neonRed,
      secondary: AppColors.neonRed,
      surface: AppColors.surface,
      error: AppColors.neonRed,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: AppColors.neonRed,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceCard,
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      hintStyle: const TextStyle(color: AppColors.textDisabled),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: AppColors.neonRed, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: AppColors.neonRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: AppColors.neonRed, width: 1.5),
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.textPrimary),
      bodyMedium: TextStyle(color: AppColors.textPrimary),
      bodySmall: TextStyle(color: AppColors.textSecondary),
      headlineLarge: TextStyle(
        color: AppColors.neonRed,
        fontWeight: FontWeight.bold,
        letterSpacing: 3,
      ),
    ),
    dividerColor: AppColors.border,
  );

  static ThemeData get light => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    colorScheme: const ColorScheme.light(
      primary: AppColors.neonRed,
      secondary: AppColors.neonRed,
      surface: Color(0xFFFFFFFF),
      error: AppColors.neonRed,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF5F5F5),
      foregroundColor: Color(0xFF111111),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: AppColors.neonRed,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFFFFFFF),
      labelStyle: const TextStyle(color: Color(0xFF666666)),
      hintStyle: const TextStyle(color: Color(0xFFAAAAAA)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: AppColors.neonRed, width: 1.5),
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF111111)),
      bodyMedium: TextStyle(color: Color(0xFF111111)),
      bodySmall: TextStyle(color: Color(0xFF666666)),
      headlineLarge: TextStyle(
        color: AppColors.neonRed,
        fontWeight: FontWeight.bold,
        letterSpacing: 3,
      ),
    ),
    dividerColor: const Color(0xFFDDDDDD),
  );
}
