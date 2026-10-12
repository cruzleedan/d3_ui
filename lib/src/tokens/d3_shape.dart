import 'package:flutter/painting.dart';

import 'package:d3_ui/src/tokens/d3_radius.dart';

/// Corner radii and card outline for the surfaces, so a brand can reshape them.
///
/// The scale keeps [D3Radius]'s names. A widget asks for a step rather than a
/// number, so changing the scale reshapes every widget that uses it. Defaults
/// equal the fixed [D3Radius] values, so an app that sets nothing looks the
/// same as before.
class D3ShapeTokens {
  const D3ShapeTokens({
    this.xs = D3Radius.xs,
    this.sm = D3Radius.sm,
    this.md = D3Radius.md,
    this.lg = D3Radius.lg,
    this.xl = D3Radius.xl,
    this.cardBorder,
    this.cardBorderWidth = 1,
  });

  final double xs;
  final double sm;
  final double md;

  /// Cards, list groups, info cards.
  final double lg;

  /// Sheets (top corners), dialogs.
  final double xl;

  /// The outline of a card. `null` keeps the default (the palette's `outline`
  /// at 40%); a brand sets it, for example to its text colour at 10%.
  final Color? cardBorder;
  final double cardBorderWidth;

  static const defaults = D3ShapeTokens();

  BorderRadius circular(double radius) => BorderRadius.circular(radius);
  BorderRadius get circularXs => BorderRadius.circular(xs);
  BorderRadius get circularSm => BorderRadius.circular(sm);
  BorderRadius get circularMd => BorderRadius.circular(md);
  BorderRadius get circularLg => BorderRadius.circular(lg);
  BorderRadius get circularXl => BorderRadius.circular(xl);

  D3ShapeTokens copyWith({
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    Color? cardBorder,
    double? cardBorderWidth,
  }) => D3ShapeTokens(
    xs: xs ?? this.xs,
    sm: sm ?? this.sm,
    md: md ?? this.md,
    lg: lg ?? this.lg,
    xl: xl ?? this.xl,
    cardBorder: cardBorder ?? this.cardBorder,
    cardBorderWidth: cardBorderWidth ?? this.cardBorderWidth,
  );
}
