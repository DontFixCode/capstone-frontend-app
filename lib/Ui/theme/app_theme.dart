import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const primary = Color(0xFF2563EB);
  static const secondary = Color(0xFFDBEAFE);
  static const background = Color(0xFFF8FAFC);
  static const text = Color(0xFF1E293B);
  static const accent = Color(0xFFFED7AA);

  static final light = _buildLightTheme();

  static ThemeData _buildLightTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: secondary,
      onPrimaryContainer: text,
      secondary: secondary,
      onSecondary: text,
      secondaryContainer: secondary,
      onSecondaryContainer: text,
      tertiary: accent,
      onTertiary: text,
      tertiaryContainer: accent,
      onTertiaryContainer: text,
      surface: background,
      onSurface: text,
    );
    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: text,
        surfaceTintColor: Colors.transparent,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
    );

    return theme.copyWith(
      textTheme: theme.textTheme.apply(bodyColor: text, displayColor: text),
    );
  }
}
