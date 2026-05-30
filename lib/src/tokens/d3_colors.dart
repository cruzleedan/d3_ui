import 'package:flutter/painting.dart';

/// Raw color primitives. Never use these directly in widgets —
/// reference semantic tokens via [D3ColorTokens] instead.
abstract final class D3ColorPrimitives {
  // Blues
  static const blue300 = Color(0xFF93AEFF);
  static const blue400 = Color(0xFF6C8FFF);
  static const blue500 = Color(0xFF5B73E8);
  static const blue600 = Color(0xFF4F6EE0);

  // Greens
  static const green400 = Color(0xFF34D399);
  static const green500 = Color(0xFF10B981);

  // Reds
  static const red400 = Color(0xFFF87171);
  static const red500 = Color(0xFFEF4444);
  static const red600 = Color(0xFFDC2626);

  // Ambers
  static const amber400 = Color(0xFFFBBF24);
  static const amber500 = Color(0xFFF59E0B);

  // Neutrals — dark
  static const neutral950 = Color(0xFF080A12);
  static const neutral900 = Color(0xFF0F1117);
  static const neutral850 = Color(0xFF13151F);
  static const neutral800 = Color(0xFF1A1D27);
  static const neutral750 = Color(0xFF1E2235);
  static const neutral700 = Color(0xFF22263A);
  static const neutral600 = Color(0xFF2A2F45);
  static const neutral500 = Color(0xFF2E3350);
  static const neutral400 = Color(0xFF64748B);
  static const neutral300 = Color(0xFF94A3B8);
  static const neutral200 = Color(0xFFCBD5E1);
  static const neutral100 = Color(0xFFE2E8F0);
  static const neutral50  = Color(0xFFF1F5F9);
  static const white      = Color(0xFFFFFFFF);

  D3ColorPrimitives._();
}

/// Semantic color tokens. Consume these in ThemeExtension and widgets.
class D3ColorTokens {
  const D3ColorTokens({
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.surface,
    required this.surfaceVariant,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.outline,
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.scrim,
  });

  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;     // tonal fill (primary @ ~12-15%)
  final Color onPrimaryContainer;   // tonal label

  final Color secondary;
  final Color onSecondary;

  final Color surface;
  final Color surfaceVariant;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color outline;

  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;
  final Color error;
  final Color onError;
  final Color errorContainer;       // danger tonal fill
  final Color onErrorContainer;     // danger tonal label

  final Color scrim;                // overlays, modals

  // ── Predefined light ──────────────────────────────────────────────────────

  static const light = D3ColorTokens(
    primary:             D3ColorPrimitives.blue500,
    onPrimary:           D3ColorPrimitives.white,
    primaryContainer:    Color(0x1F5B73E8), // blue500 @ 12%
    onPrimaryContainer:  D3ColorPrimitives.blue500,
    secondary:           D3ColorPrimitives.neutral400,
    onSecondary:         D3ColorPrimitives.white,
    surface:             D3ColorPrimitives.white,
    surfaceVariant:      D3ColorPrimitives.neutral50,
    onSurface:           D3ColorPrimitives.neutral900,
    onSurfaceVariant:    D3ColorPrimitives.neutral400,
    outline:             D3ColorPrimitives.neutral200,
    success:             D3ColorPrimitives.green500,
    onSuccess:           D3ColorPrimitives.white,
    warning:             D3ColorPrimitives.amber500,
    onWarning:           D3ColorPrimitives.white,
    error:               D3ColorPrimitives.red600,
    onError:             D3ColorPrimitives.white,
    errorContainer:      Color(0x1FDC2626), // red600 @ 12%
    onErrorContainer:    D3ColorPrimitives.red600,
    scrim:               Color(0x80000000),
  );

  // ── Predefined dark ───────────────────────────────────────────────────────

  static const dark = D3ColorTokens(
    primary:             D3ColorPrimitives.blue400,
    onPrimary:           D3ColorPrimitives.white,
    primaryContainer:    Color(0x266C8FFF), // blue400 @ 15%
    onPrimaryContainer:  D3ColorPrimitives.blue400,
    secondary:           D3ColorPrimitives.neutral300,
    onSecondary:         D3ColorPrimitives.neutral900,
    surface:             D3ColorPrimitives.neutral900,
    surfaceVariant:      D3ColorPrimitives.neutral800,
    onSurface:           D3ColorPrimitives.neutral100,
    onSurfaceVariant:    D3ColorPrimitives.neutral300,
    outline:             D3ColorPrimitives.neutral500,
    success:             D3ColorPrimitives.green400,
    onSuccess:           D3ColorPrimitives.neutral900,
    warning:             D3ColorPrimitives.amber400,
    onWarning:           D3ColorPrimitives.neutral900,
    error:               D3ColorPrimitives.red400,
    onError:             D3ColorPrimitives.neutral900,
    errorContainer:      Color(0x26F87171), // red400 @ 15%
    onErrorContainer:    D3ColorPrimitives.red400,
    scrim:               Color(0x99000000),
  );
}
