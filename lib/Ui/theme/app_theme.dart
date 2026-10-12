import 'package:flutter/material.dart';

abstract final class AppTheme {
  // Brand expression and user actions deliberately have separate roles.
  static const background = Color(0xFFF7F4EE);
  static const surface = Color(0xFFFFFDFA);
  static const surfaceMuted = Color(0xFFE5E0D8);
  static const text = Color(0xFF292724);
  static const border = text;
  static const brand = Color(0xFF623D3D);
  static const action = Color(0xFF345C55);
  static const actionSurface = Color(0xFFE5EBE7);
  static const brandSurface = Color(0xFFEDE2DD);
  static const onAction = Colors.white;
  // Secondary text and fine borders use the same charcoal with lower opacity.
  static const textMuted = Color(0xC2292724);
  static const borderMuted = Color(0x59292724);
  static const corners = BorderRadius.all(Radius.circular(4));

  static BoxDecoration panel({bool raised = false, Color color = surface}) =>
      BoxDecoration(
        color: color,
        borderRadius: corners,
        border: Border.all(color: border, width: raised ? 1.5 : 1),
        boxShadow: raised
            ? const [BoxShadow(color: border, offset: Offset(4, 4))]
            : null,
      );

  static final light = _buildLightTheme();

  static ThemeData _buildLightTheme() {
    const shape = RoundedRectangleBorder(borderRadius: corners);
    final inputBorder = OutlineInputBorder(
      borderRadius: corners,
      borderSide: BorderSide(color: borderMuted),
    );
    final scheme = ColorScheme.fromSeed(
      seedColor: action,
      brightness: Brightness.light,
      primary: action,
      onPrimary: onAction,
      primaryContainer: actionSurface,
      onPrimaryContainer: text,
      secondary: brand,
      onSecondary: onAction,
      secondaryContainer: brandSurface,
      onSecondaryContainer: text,
      tertiary: action,
      onTertiary: onAction,
      tertiaryContainer: actionSurface,
      onTertiaryContainer: text,
      surface: surface,
      onSurface: text,
      onSurfaceVariant: textMuted,
      surfaceDim: surfaceMuted,
      surfaceBright: surface,
      surfaceContainerLowest: surface,
      surfaceContainerLow: background,
      surfaceContainer: surfaceMuted,
      surfaceContainerHigh: surfaceMuted,
      surfaceContainerHighest: surfaceMuted,
      outline: border,
      outlineVariant: borderMuted,
      inverseSurface: text,
      onInverseSurface: surface,
      surfaceTint: Colors.transparent,
    );
    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: text,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: DividerThemeData(
        color: borderMuted,
        thickness: 1,
        space: 32,
      ),
      cardTheme: const CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: corners,
          side: BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: const BorderSide(color: action, width: 2),
        ),
        labelStyle: TextStyle(color: textMuted),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: action,
          foregroundColor: onAction,
          minimumSize: const Size(48, 52),
          shape: shape,
          side: const BorderSide(color: border),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: action,
          shape: shape,
          side: const BorderSide(color: border),
          minimumSize: const Size(48, 48),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: action, shape: shape),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceMuted,
        selectedColor: actionSurface,
        side: BorderSide(color: borderMuted),
        shape: shape,
        labelStyle: const TextStyle(color: text),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: corners,
          side: BorderSide(color: border),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: action,
        foregroundColor: onAction,
        shape: shape,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: text,
        contentTextStyle: TextStyle(color: surface),
      ),
    );
    return theme.copyWith(
      textTheme: theme.textTheme.apply(bodyColor: text, displayColor: text),
    );
  }
}
