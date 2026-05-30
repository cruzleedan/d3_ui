import 'package:flutter/material.dart';
import 'package:d3_ui/d3_ui.dart';

// ─────────────────────────────────────────────────────────────────────────────
// D3Image
// ─────────────────────────────────────────────────────────────────────────────

/// A network image with a shimmer placeholder while loading and a labelled
/// fallback on error.
///
/// **Sizing** — provide [width] + [height] for a fixed box, or [width] +
/// [aspectRatio] to keep proportions without hardcoding a height.
///
/// **Grid shimmer sync** — wrap a grid in a single [D3Shimmer] and all
/// [D3Image] widgets inside it automatically share that animation controller.
/// No extra wiring needed.
///
/// ```dart
/// // Fixed size
/// D3Image(
///   url: anime.imageUrl,
///   width: 100,
///   height: 140,
/// )
///
/// // Aspect ratio (height inferred)
/// D3Image(
///   url: anime.imageUrl,
///   width: 100,
///   aspectRatio: 2 / 3,
/// )
///
/// // Synchronised shimmer grid — wrap once, all images sync automatically
/// D3Shimmer(
///   child: GridView.builder(
///     itemBuilder: (ctx, i) => D3Image(
///       url: items[i].url,
///       aspectRatio: 2 / 3,
///     ),
///   ),
/// )
/// ```
class D3Image extends StatelessWidget {
  const D3Image({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.aspectRatio,
    this.fit = BoxFit.cover,
    this.borderRadius = D3Radius.circularMd,
    this.errorIcon = Icons.image_not_supported_outlined,
    this.semanticsLabel,
  }) : assert(
          height == null || aspectRatio == null,
          'Provide height or aspectRatio, not both.',
        );

  final String? url;
  final double? width;

  /// Fixed height. Mutually exclusive with [aspectRatio].
  final double? height;

  /// Width-to-height ratio (e.g. `2/3` for portrait covers).
  /// Mutually exclusive with [height].
  final double? aspectRatio;

  final BoxFit fit;
  final BorderRadius borderRadius;
  final IconData errorIcon;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final content = url == null || url!.isEmpty
        ? _ErrorPlaceholder(icon: errorIcon)
        : _NetworkImage(
            url: url!,
            fit: fit,
            errorIcon: errorIcon,
            semanticsLabel: semanticsLabel,
          );

    Widget sized;
    if (aspectRatio != null) {
      sized = SizedBox(
        width: width,
        child: AspectRatio(aspectRatio: aspectRatio!, child: content),
      );
    } else {
      sized = SizedBox(width: width, height: height, child: content);
    }

    return ClipRRect(borderRadius: borderRadius, child: sized);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _NetworkImage
// ─────────────────────────────────────────────────────────────────────────────

class _NetworkImage extends StatelessWidget {
  const _NetworkImage({
    required this.url,
    required this.fit,
    required this.errorIcon,
    this.semanticsLabel,
  });

  final String url;
  final BoxFit fit;
  final IconData errorIcon;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: fit,
      semanticLabel: semanticsLabel,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) return child;

        const skeleton = D3SkeletonBox(
          borderRadius: BorderRadius.zero,
          height: double.infinity,
        );

        // If an ancestor D3Shimmer exists (e.g. wrapping a whole grid),
        // the D3SkeletonBox will find it automatically — no local wrapper needed.
        // Otherwise create a local D3Shimmer so standalone images still animate.
        return D3Shimmer.of(context) != null
            ? skeleton
            : const D3Shimmer(child: skeleton);
      },
      errorBuilder: (context, error, stackTrace) =>
          _ErrorPlaceholder(icon: errorIcon),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ErrorPlaceholder
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorPlaceholder extends StatelessWidget {
  const _ErrorPlaceholder({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: colors.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 4),
            Text(
              'No image',
              style: TextStyle(
                fontSize: 10,
                color: colors.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
