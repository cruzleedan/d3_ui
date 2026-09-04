import 'package:material_ui/material_ui.dart';
import 'package:d3_ui/d3_ui.dart';

// ─────────────────────────────────────────────────────────────────────────────
// D3ListTileSkeleton
// ─────────────────────────────────────────────────────────────────────────────

/// A shimmering placeholder shaped like [D3ListTile] — a leading circle
/// followed by a title line and an optional subtitle line. Repeat inside a
/// [D3Shimmer] to mimic a loading list.
///
/// ```dart
/// D3Shimmer(
///   child: Column(
///     children: List.generate(
///       6,
///       (_) => const D3ListTileSkeleton(),
///     ),
///   ),
/// )
/// ```
class D3ListTileSkeleton extends StatelessWidget {
  const D3ListTileSkeleton({
    super.key,
    this.showLeading = true,
    this.showSubtitle = true,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 14,
      vertical: 10,
    ),
  });

  /// Whether to show the leading circle, matching [D3ListTile.leading].
  final bool showLeading;

  /// Whether to show a second, narrower line under the title.
  final bool showSubtitle;

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showLeading) ...[
            const D3SkeletonBox(
              width: 36,
              height: 36,
              borderRadius: D3Radius.circularMd,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const D3SkeletonBox(height: 14, width: double.infinity),
                if (showSubtitle) ...[
                  const SizedBox(height: 6),
                  D3SkeletonBox(
                    height: 12,
                    width: MediaQuery.sizeOf(context).width * 0.4,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// D3FormSkeleton
// ─────────────────────────────────────────────────────────────────────────────

/// A shimmering placeholder for a form: a label-width line above an
/// input-height box, repeated for [fieldCount] fields.
///
/// ```dart
/// D3Shimmer(
///   child: D3FormSkeleton(fieldCount: 4),
/// )
/// ```
class D3FormSkeleton extends StatelessWidget {
  const D3FormSkeleton({
    super.key,
    this.fieldCount = 3,
    this.fieldSpacing = D3Spacing.s16,
  });

  /// Number of label + input rows to render.
  final int fieldCount;

  /// Vertical gap between fields.
  final double fieldSpacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < fieldCount; i++) ...[
          if (i > 0) SizedBox(height: fieldSpacing),
          const D3SkeletonBox(height: 12, width: 96),
          const SizedBox(height: D3Spacing.s6),
          const D3SkeletonBox(height: 48, width: double.infinity),
        ],
      ],
    );
  }
}
