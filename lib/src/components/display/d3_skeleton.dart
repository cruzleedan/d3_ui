import 'package:flutter/material.dart';
import 'package:d3_ui/d3_ui.dart';

// ─────────────────────────────────────────────────────────────────────────────
// _ShimmerGradient — shared animation
// ─────────────────────────────────────────────────────────────────────────────

/// Inherited widget that shares a single shimmer [AnimationController] across
/// the whole subtree. Wrap a skeleton section in [D3Shimmer] once and nest
/// any number of [D3SkeletonBox] / [D3SkeletonText] inside.
class D3Shimmer extends StatefulWidget {
  const D3Shimmer({
    super.key,
    required this.child,
  });

  final Widget child;

  // ignore: library_private_types_in_public_api
  static _D3ShimmerState? of(BuildContext context) {
    return context.findAncestorStateOfType<_D3ShimmerState>();
  }

  @override
  State<D3Shimmer> createState() => _D3ShimmerState();
}

class _D3ShimmerState extends State<D3Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController.unbounded(
      vsync: this)
    ..repeat(min: -0.5, max: 1.5, period: const Duration(milliseconds: 1200));

  Animation<double> get shimmerAnimation => _controller;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

// ─────────────────────────────────────────────────────────────────────────────
// _SkeletonShader — renders the animated gradient fill
// ─────────────────────────────────────────────────────────────────────────────

class _SkeletonShader extends StatefulWidget {
  const _SkeletonShader({
    required this.child,
    required this.borderRadius,
  });

  final Widget child;
  final BorderRadius borderRadius;

  @override
  State<_SkeletonShader> createState() => _SkeletonShaderState();
}

class _SkeletonShaderState extends State<_SkeletonShader> {
  late Listenable _shimmer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _shimmer =
        D3Shimmer.of(context)?.shimmerAnimation ?? kAlwaysCompleteAnimation;
    _shimmer.addListener(_onShimmer);
  }

  void _onShimmer() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _shimmer.removeListener(_onShimmer);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    final percent = D3Shimmer.of(context)?.shimmerAnimation.value ?? 0.0;

    // Base is a visible mid-gray (outline token); highlight is the surface
    // color (lighter). The wave is always a lighter band on a gray base,
    // visible in both light and dark mode.
    final baseColor = colors.outline;
    final highlightColor = colors.surface;

    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [baseColor, highlightColor, baseColor],
            stops: [
              (percent - 0.3).clamp(0.0, 1.0),
              percent.clamp(0.0, 1.0),
              (percent + 0.3).clamp(0.0, 1.0),
            ],
          ),
        ),
        child: widget.child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// D3SkeletonBox
// ─────────────────────────────────────────────────────────────────────────────

/// A shimmering rectangular placeholder. Nest inside [D3Shimmer] for a
/// synchronised animation across multiple skeletons on the same screen.
///
/// ```dart
/// D3Shimmer(
///   child: Column(
///     children: [
///       D3SkeletonBox(height: 200, borderRadius: D3Radius.circularMd),
///       SizedBox(height: D3Spacing.s12),
///       D3SkeletonText(lines: 3),
///     ],
///   ),
/// )
/// ```
class D3SkeletonBox extends StatelessWidget {
  const D3SkeletonBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = D3Radius.circularSm,
  });

  final double? width;
  final double height;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: width,
        height: height,
        child: _SkeletonShader(
          borderRadius: borderRadius,
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// D3SkeletonText
// ─────────────────────────────────────────────────────────────────────────────

/// A column of shimmering text-line placeholders. The last line is narrower
/// by default to mimic natural paragraph text.
///
/// ```dart
/// D3SkeletonText(lines: 2)
/// D3SkeletonText(lines: 3, lineHeight: 14, spacing: 10)
/// ```
class D3SkeletonText extends StatelessWidget {
  const D3SkeletonText({
    super.key,
    this.lines = 3,
    this.lineHeight = 13,
    this.spacing = D3Spacing.s8,
    this.lastLineWidthFraction = 0.6,
  });

  final int lines;
  final double lineHeight;
  final double spacing;

  /// Width fraction for the last line (0.0–1.0). Defaults to 60 %.
  final double lastLineWidthFraction;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < lines; i++) ...[
          if (i > 0) SizedBox(height: spacing),
          LayoutBuilder(
            builder: (context, constraints) {
              final isLast = i == lines - 1;
              final width = isLast && lines > 1
                  ? constraints.maxWidth * lastLineWidthFraction
                  : constraints.maxWidth;
              return D3SkeletonBox(
                width: width,
                height: lineHeight,
              );
            },
          ),
        ],
      ],
    );
  }
}
