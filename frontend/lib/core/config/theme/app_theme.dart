import 'package:flutter/material.dart';
import 'color_schemes.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: AppColors.lightColorScheme,

    // Form field theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightColorScheme.surface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      prefixIconColor: AppColors.lightColorScheme.primary,
    ),

    // Card theme
    cardTheme: CardTheme(
      elevation: 0,
      color: AppColors.lightColorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    // Button themes
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: AppColors.darkColorScheme,
    // textTheme: AppTextTheme.darkTextTheme,

    // Form field theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkColorScheme.surface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      prefixIconColor: AppColors.darkColorScheme.primary,
    ),

    // Card theme
    cardTheme: CardTheme(
      elevation: 0,
      color: AppColors.darkColorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    // Button themes
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );
}
