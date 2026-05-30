import 'package:flutter/animation.dart';

/// Motion tokens — durations and curves.
/// All widgets reference these; never hardcode durations.
abstract final class D3Motion {
  // Durations
  static const Duration instant  = Duration(milliseconds: 0);
  static const Duration fast     = Duration(milliseconds: 100);
  static const Duration base     = Duration(milliseconds: 200);
  static const Duration moderate = Duration(milliseconds: 300);
  static const Duration slow     = Duration(milliseconds: 400);

  // Curves
  static const Curve standard    = Curves.easeInOut;
  static const Curve decelerate  = Curves.easeOut;
  static const Curve accelerate  = Curves.easeIn;

  /// Snappy spring — used for press release, dismissals.
  static const Curve spring      = Curves.elasticOut;

  /// Gentle enter — content appearing on screen.
  static const Curve enter       = Curves.easeOutCubic;

  /// Exit — content leaving screen.
  static const Curve exit        = Curves.easeInCubic;

  D3Motion._();
}

/// Button-specific animation constants.
abstract final class D3ButtonMotion {
  static const Duration pressDown  = Duration(milliseconds: 100);
  static const Duration pressUp    = Duration(milliseconds: 200);
  static const Curve    pressDownCurve = Curves.easeIn;
  static const Curve    pressUpCurve   = Curves.elasticOut;
  static const double   pressScale    = 0.96;
  static const double   pressOpacity  = 0.85;

  D3ButtonMotion._();
}
