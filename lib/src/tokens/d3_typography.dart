import 'package:flutter/painting.dart';

/// Typography scale tokens.
/// Font sizes are in sp — Flutter scales these with system text size automatically.
/// Never set textScaleFactor manually; let the system handle it.
abstract final class D3TypeScale {
  // Display
  static const double displayLgSize = 32;
  static const double displayMdSize = 28;
  static const double displaySmSize = 24;

  // Headline
  static const double headlineLgSize = 22;
  static const double headlineMdSize = 20;
  static const double headlineSmSize = 18;

  // Title
  static const double titleLgSize = 17;
  static const double titleMdSize = 15;
  static const double titleSmSize = 14;

  // Body
  static const double bodyLgSize = 16;
  static const double bodyMdSize = 14;
  static const double bodySmSize = 13;

  // Label
  static const double labelLgSize = 12;
  static const double labelMdSize = 11;
  static const double labelSmSize = 10;

  // Button labels
  static const double btnXsSize = 12;
  static const double btnSmSize = 13;
  static const double btnMdSize = 14;
  static const double btnLgSize = 15;
  static const double btnXlSize = 16;

  D3TypeScale._();
}

abstract final class D3TypeFace {
  /// Letter spacing for button labels — slightly tightened for modern feel.
  static const double btnLetterSpacing = -0.1;

  /// Line heights (as multipliers)
  static const double tight = 1.2;
  static const double normal = 1.5;
  static const double relaxed = 1.75;

  D3TypeFace._();
}

/// Helper to build consistent TextStyle for buttons.
TextStyle d3ButtonTextStyle({
  required double fontSize,
  required Color color,
}) {
  return TextStyle(
    fontSize: fontSize,
    fontWeight: FontWeight.w600,
    letterSpacing: D3TypeFace.btnLetterSpacing,
    color: color,
    height: D3TypeFace.tight,
    leadingDistribution: TextLeadingDistribution.even,
  );
}
