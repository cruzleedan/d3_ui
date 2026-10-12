import 'package:flutter/painting.dart';

import 'package:d3_ui/src/tokens/d3_colors.dart';

/// One status colour's three parts, as a badge draws it: [text] on a [tint]
/// background with a [border]. [tint] and [border] may be translucent (the
/// colour at some opacity), so they composite over whatever surface they sit
/// on.
class D3StatusColor {
  const D3StatusColor({
    required this.text,
    required this.tint,
    required this.border,
  });

  final Color text;
  final Color tint;
  final Color border;

  /// [text] lifted to at least [minRatio] (default WCAG AA, 4.5:1) against
  /// [tint] composited over [surface]. For small badge text where a brand's own
  /// shade falls just short.
  Color readableTextOn(Color surface, {double minRatio = 4.5}) =>
      _ensureContrast(text, Color.alphaBlend(tint, surface), minRatio);

  static Color _ensureContrast(Color fg, Color bg, double minRatio) {
    // Same rule as d3EnsureContrast; kept private here to avoid an import cycle
    // with utils.
    double ratio(Color a, Color b) {
      final la = a.computeLuminance();
      final lb = b.computeLuminance();
      final hi = la > lb ? la : lb;
      final lo = la > lb ? lb : la;
      return (hi + 0.05) / (lo + 0.05);
    }

    if (ratio(fg, bg) >= minRatio) return fg;
    final towards = bg.computeLuminance() > 0.5
        ? const Color(0xFF000000)
        : const Color(0xFFFFFFFF);
    for (var t = 0.05; t <= 1.0; t += 0.05) {
      final candidate = Color.lerp(fg, towards, t)!;
      if (ratio(candidate, bg) >= minRatio) return candidate;
    }
    return towards;
  }
}

/// Status colours for badges and highlights: success, warning, destructive and
/// neutral. Defaults are derived from a palette ([D3StatusTokens.fromColors]),
/// so an app that sets nothing still gets matching badges; a brand with its own
/// status palette sets them explicitly (for example from a design-token file).
class D3StatusTokens {
  const D3StatusTokens({
    required this.success,
    required this.warning,
    required this.destructive,
    required this.neutral,
  });

  final D3StatusColor success;
  final D3StatusColor warning;
  final D3StatusColor destructive;
  final D3StatusColor neutral;

  /// Derives the four statuses from [colors]: text is the status colour, tint
  /// and border are that colour at low opacity.
  factory D3StatusTokens.fromColors(D3ColorTokens colors) {
    D3StatusColor of(Color base, {double tint = 0.15, double border = 0.5}) =>
        D3StatusColor(
          text: base,
          tint: base.withValues(alpha: tint),
          border: base.withValues(alpha: border),
        );
    return D3StatusTokens(
      success: of(colors.success),
      warning: of(colors.warning),
      destructive: of(colors.error),
      neutral: D3StatusColor(
        text: colors.onSurfaceVariant,
        tint: colors.surfaceContainerHighest,
        border: colors.outline,
      ),
    );
  }
}
