import 'package:flutter/painting.dart';

/// Border radius tokens.
abstract final class D3Radius {
  static const double xs   = 8;
  static const double sm   = 10;
  static const double md   = 12;
  static const double lg   = 14;
  static const double xl   = 20;
  static const double full = 999;

  static const BorderRadius circularXs   = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius circularSm   = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius circularMd   = BorderRadius.all(Radius.circular(md));
  static const BorderRadius circularLg   = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius circularXl   = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius circularFull = BorderRadius.all(Radius.circular(full));

  D3Radius._();
}
