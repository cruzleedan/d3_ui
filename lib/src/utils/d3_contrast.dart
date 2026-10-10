import 'dart:math' as math;
import 'dart:ui';

/// WCAG contrast ratio between two opaque colours, from 1 to 21.
double d3ContrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

/// [foreground] if it already reaches [minRatio] against [background];
/// otherwise the nearest shade of it that does, darkened on a light
/// background and lightened on a dark one.
///
/// For text that borrows a semantic colour (amber "warning", green
/// "success") which is fine as an icon or border but too faint as words. The
/// default 4.5 is the WCAG AA minimum for normal-size text.
Color d3EnsureContrast(
  Color foreground,
  Color background, {
  double minRatio = 4.5,
}) {
  if (d3ContrastRatio(foreground, background) >= minRatio) return foreground;
  final towards = background.computeLuminance() > 0.5
      ? const Color(0xFF000000)
      : const Color(0xFFFFFFFF);
  for (var t = 0.05; t <= 1.0; t += 0.05) {
    final candidate = Color.lerp(foreground, towards, t)!;
    if (d3ContrastRatio(candidate, background) >= minRatio) return candidate;
  }
  return towards;
}
