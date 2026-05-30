import 'package:flutter/material.dart';
import 'package:d3_ui/src/tokens/d3_colors.dart';
import 'package:d3_ui/src/themes/d3_theme_extension.dart';

/// Factory that builds [ThemeData] from design system tokens.
/// This is the single entry point for theming — apps never construct
/// ThemeData directly.
abstract final class D3AppTheme {
  /// Default light theme.
  static ThemeData light({D3TokensExtension? overrides}) {
    return _build(
      brightness: Brightness.light,
      colors: D3ColorTokens.light,
      extension: overrides ?? D3TokensExtension.light,
    );
  }

  /// Default dark theme.
  static ThemeData dark({D3TokensExtension? overrides}) {
    return _build(
      brightness: Brightness.dark,
      colors: D3ColorTokens.dark,
      extension: overrides ?? D3TokensExtension.dark,
    );
  }

  static ThemeData _build({
    required Brightness brightness,
    required D3ColorTokens colors,
    required D3TokensExtension extension,
  }) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,

      // Seed the Material ColorScheme from our primary token.
      // This ensures M3 components that we haven't overridden yet
      // still look coherent.
      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.primary,
        brightness: brightness,
        surface: colors.surface,
        error: colors.error,
      ).copyWith(
        primary: colors.primary,
        onPrimary: colors.onPrimary,
        surface: colors.surface,
        onSurface: colors.onSurface,
        outline: colors.outline,
        error: colors.error,
        onError: colors.onError,
      ),

      scaffoldBackgroundColor: colors.surface,

      // Remove all default component decorations — we style everything
      // through our own tokens.
      elevatedButtonTheme: const ElevatedButtonThemeData(
        style: ButtonStyle(elevation: WidgetStatePropertyAll(0)),
      ),
      filledButtonTheme: const FilledButtonThemeData(
        style: ButtonStyle(elevation: WidgetStatePropertyAll(0)),
      ),
      outlinedButtonTheme: const OutlinedButtonThemeData(
        style: ButtonStyle(elevation: WidgetStatePropertyAll(0)),
      ),

      splashFactory:
          isDark ? InkSparkle.splashFactory : InkRipple.splashFactory,

      // Register our custom tokens.
      extensions: [extension],
    );
  }

  D3AppTheme._();
}
