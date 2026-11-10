import 'package:flutter/material.dart';

abstract final class AppColors {
  static const navy = Color(0xFF10144C);
  static const violet = Color(0xFF33239A);
  static const turquoise = Color(0xFF00A99A);
  static const green = Color(0xFF32C875);
}

ThemeData crearTema(Brightness brillo) {
  final oscuro = brillo == Brightness.dark;
  final esquema =
      ColorScheme.fromSeed(
        seedColor: AppColors.navy,
        brightness: brillo,
      ).copyWith(
        primary: oscuro ? const Color(0xFFBDB8FF) : AppColors.violet,
        onPrimary: oscuro ? const Color(0xFF21146D) : Colors.white,
        primaryContainer: oscuro
            ? const Color(0xFF39336C)
            : const Color(0xFFE8E5FF),
        onPrimaryContainer: oscuro
            ? const Color(0xFFE5DFFF)
            : const Color(0xFF21146D),
        secondary: oscuro ? const Color(0xFF75E4D4) : AppColors.turquoise,
        onSecondary: oscuro ? const Color(0xFF003731) : Colors.white,
        secondaryContainer: oscuro
            ? const Color(0xFF005047)
            : const Color(0xFFBDF3E9),
        onSecondaryContainer: oscuro
            ? const Color(0xFFBDF3E9)
            : const Color(0xFF003731),
        tertiary: oscuro ? const Color(0xFF8BE6A8) : AppColors.green,
        surface: oscuro ? const Color(0xFF11142D) : const Color(0xFFF8F8FF),
        onSurface: oscuro ? const Color(0xFFE7E8FF) : const Color(0xFF191A36),
        onSurfaceVariant: oscuro
            ? const Color(0xFFC4C5DD)
            : const Color(0xFF484968),
        outline: oscuro ? const Color(0xFF8D8EAA) : const Color(0xFF777994),
        error: oscuro ? const Color(0xFFFFB4AB) : const Color(0xFFBA1A1A),
      );

  return ThemeData(
    useMaterial3: true,
    colorScheme: esquema,
    scaffoldBackgroundColor: esquema.surface,
    fontFamily: 'Inter',
    appBarTheme: AppBarTheme(
      backgroundColor: esquema.surface,
      foregroundColor: esquema.onSurface,
    ),
    cardTheme: CardThemeData(
      color: oscuro ? const Color(0xFF1B1E3A) : Colors.white,
      surfaceTintColor: Colors.transparent,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: esquema.surface,
      indicatorColor: esquema.primaryContainer,
      labelTextStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 11)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 48),
        backgroundColor: esquema.primary,
        foregroundColor: esquema.onPrimary,
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
      fillColor: oscuro ? const Color(0xFF202342) : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: esquema.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: esquema.outline),
      ),
    ),
  );
}

final appTheme = crearTema(Brightness.light);
final darkAppTheme = crearTema(Brightness.dark);
