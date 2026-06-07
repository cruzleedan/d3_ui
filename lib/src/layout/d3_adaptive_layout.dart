import 'package:flutter/widgets.dart';

/// M3 Expressive window-size classes (5-tier, May 2025 spec).
/// https://m3.material.io/foundations/layout/applying-layout/window-size-classes
enum D3WindowSize {
  compact, //    0 – 599 dp
  medium, //   600 – 839 dp
  expanded, //  840 – 1199 dp
  large, //    1200 – 1599 dp
  extraLarge; // 1600+ dp

  factory D3WindowSize.fromWidth(double width) {
    if (width < D3AdaptiveLayout.kMedium) return D3WindowSize.compact;
    if (width < D3AdaptiveLayout.kExpanded) return D3WindowSize.medium;
    if (width < D3AdaptiveLayout.kLarge) return D3WindowSize.expanded;
    if (width < D3AdaptiveLayout.kExtraLarge) return D3WindowSize.large;
    return D3WindowSize.extraLarge;
  }

  /// True when the layout is wide enough for a persistent side rail / two-pane
  /// layout (expanded, large, or extra-large).
  bool get isExpandedOrWider =>
      this == D3WindowSize.expanded ||
      this == D3WindowSize.large ||
      this == D3WindowSize.extraLarge;
}

/// Breakpoint constants and helpers for adaptive layouts.
///
/// Use [D3AdaptiveLayout.of] to read the current window size class from
/// [MediaQuery], or [D3AdaptiveLayout.fromConstraints] inside a
/// [LayoutBuilder] to respond to pane width instead of screen width.
abstract final class D3AdaptiveLayout {
  // Screen-level breakpoints
  static const double kMedium = 600.0;
  static const double kExpanded = 840.0;
  static const double kLarge = 1200.0;
  static const double kExtraLarge = 1600.0;

  // Pane-level supporting-panel breakpoints (use with LayoutBuilder)
  static const double kSupportingPanelSide = 720.0;
  static const double kSupportingPanelCompact = 500.0;

  /// Current window size class derived from [MediaQuery].
  static D3WindowSize of(BuildContext context) =>
      D3WindowSize.fromWidth(MediaQuery.sizeOf(context).width);

  /// Window size class derived from [BoxConstraints.maxWidth].
  /// Prefer this inside [LayoutBuilder] so you respond to pane width, not
  /// the full screen width.
  static D3WindowSize fromConstraints(BoxConstraints constraints) =>
      D3WindowSize.fromWidth(constraints.maxWidth);
}
