import 'package:flutter/material.dart';
import 'package:d3_ui/src/tokens/d3_colors.dart';
import 'package:d3_ui/src/themes/d3_theme_extension.dart';

/// Factory that builds [ThemeData] from design system tokens.
/// This is the single entry point for theming — apps never construct
/// ThemeData directly.
///
/// Apps can pass custom [D3ColorTokens] to use a different color palette
/// (e.g. a green brand instead of the default blue), and inject additional
/// [ThemeExtension] objects (e.g. app-specific component tokens).
abstract final class D3AppTheme {
  /// Default light theme.
  ///
  /// [colors] overrides the default [D3ColorTokens.light] palette.
  /// [inputTokens] overrides individual input field tokens — applied on top of
  /// [D3InputTokens.defaults] via copyWith, so only set what you want to change.
  /// [buttonTokens] overrides individual button tokens similarly.
  /// [overrides] replaces the entire [D3TokensExtension] — prefer the above
  /// targeted parameters unless you need to replace everything at once.
  /// [extraExtensions] additional [ThemeExtension] objects merged into the theme.
  static ThemeData light({
    D3ColorTokens? colors,
    D3InputTokens? inputTokens,
    D3ButtonTokens? buttonTokens,
    D3TokensExtension? overrides,
    List<ThemeExtension<dynamic>> extraExtensions = const [],
  }) {
    final effectiveColors = colors ?? D3ColorTokens.light;
    final effectiveExtension = overrides ??
        D3TokensExtension.light.copyWith(
          colors: effectiveColors,
          inputTokens: inputTokens,
          buttonTokens: buttonTokens,
        );
    return _build(
      brightness: Brightness.light,
      colors: effectiveColors,
      extension: effectiveExtension,
      extraExtensions: extraExtensions,
    );
  }

  /// Default dark theme.
  ///
  /// [colors] overrides the default [D3ColorTokens.dark] palette.
  /// [inputTokens] overrides individual input field tokens.
  /// [buttonTokens] overrides individual button tokens.
  /// [overrides] replaces the entire [D3TokensExtension].
  /// [extraExtensions] additional [ThemeExtension] objects merged into the theme.
  static ThemeData dark({
    D3ColorTokens? colors,
    D3InputTokens? inputTokens,
    D3ButtonTokens? buttonTokens,
    D3TokensExtension? overrides,
    List<ThemeExtension<dynamic>> extraExtensions = const [],
  }) {
    final effectiveColors = colors ?? D3ColorTokens.dark;
    final effectiveExtension = overrides ??
        D3TokensExtension.dark.copyWith(
          colors: effectiveColors,
          inputTokens: inputTokens,
          buttonTokens: buttonTokens,
        );
    return _build(
      brightness: Brightness.dark,
      colors: effectiveColors,
      extension: effectiveExtension,
      extraExtensions: extraExtensions,
    );
  }

  static ThemeData _build({
    required Brightness brightness,
    required D3ColorTokens colors,
    required D3TokensExtension extension,
    List<ThemeExtension<dynamic>> extraExtensions = const [],
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

      // Register our custom tokens plus any app-specific extensions.
      extensions: [extension, ...extraExtensions],
    );
  }

  D3AppTheme._();
}
