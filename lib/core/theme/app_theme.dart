import 'package:flutter/material.dart';

abstract final class AppColors {
  static const canvas = Color(0xFFF9F9FF);
  static const surface = Colors.white;
  static const ink = Color(0xFF111C2D);
  static const muted = Color(0xFF444651);
  static const outline = Color(0xFFC5C5D3);
  static const cobalt = Color(0xFF1E3A8A);
  static const blue = Color(0xFF316BF3);
  static const mint = Color(0xFF6FFBBE);
  static const softBlue = Color(0xFFE7EEFF);
  static const error = Color(0xFFBA1A1A);
}

final appTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: AppColors.canvas,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.blue,
    brightness: Brightness.light,
  ),
  fontFamily: 'Inter',
  navigationBarTheme: const NavigationBarThemeData(
    labelTextStyle: WidgetStatePropertyAll(TextStyle(fontSize: 11)),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size(48, 48),
      backgroundColor: AppColors.cobalt,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      minimumSize: const Size(48, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.outline),
    ),
  ),
);
