import 'package:flutter/material.dart';
import 'package:d3_ui/d3_ui.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Enums
// ─────────────────────────────────────────────────────────────────────────────

enum D3AvatarSize {
  xs(24),
  sm(32),
  md(40),
  lg(52),
  xl(64);

  const D3AvatarSize(this.dimension);
  final double dimension;

  double get fontSize => switch (this) {
        D3AvatarSize.xs => 9,
        D3AvatarSize.sm => 11,
        D3AvatarSize.md => 14,
        D3AvatarSize.lg => 17,
        D3AvatarSize.xl => 21,
      };

  double get indicatorSize => switch (this) {
        D3AvatarSize.xs => 0, // no indicator at xs — too small
        D3AvatarSize.sm => 8,
        D3AvatarSize.md => 10,
        D3AvatarSize.lg => 12,
        D3AvatarSize.xl => 14,
      };

  double get indicatorBorder => switch (this) {
        D3AvatarSize.xs => 0,
        D3AvatarSize.sm => 1.5,
        D3AvatarSize.md => 2,
        D3AvatarSize.lg => 2,
        D3AvatarSize.xl => 2.5,
      };

  double get borderRadius => switch (this) {
        D3AvatarSize.xs => D3Radius.xs,
        D3AvatarSize.sm => D3Radius.sm,
        D3AvatarSize.md => D3Radius.md,
        D3AvatarSize.lg => D3Radius.lg,
        D3AvatarSize.xl => D3Radius.xl,
      };
}

enum D3AvatarShape { circle, square }

enum D3AvatarIndicator { none, online, busy, offline }

// ─────────────────────────────────────────────────────────────────────────────
// D3Avatar
// ─────────────────────────────────────────────────────────────────────────────

/// A circular or square avatar that displays a remote image when available,
/// falling back to coloured initials derived from [name].
///
/// ```dart
/// // Initials only
/// D3Avatar(name: 'Dan Lee')
///
/// // With remote image (falls back to initials on error)
/// D3Avatar(
///   name: 'Dan Lee',
///   imageUrl: 'https://example.com/avatar.jpg',
///   size: D3AvatarSize.lg,
/// )
///
/// // Square with online indicator
/// D3Avatar(
///   name: 'Dan Lee',
///   shape: D3AvatarShape.square,
///   indicator: D3AvatarIndicator.online,
/// )
/// ```
class D3Avatar extends StatelessWidget {
  const D3Avatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = D3AvatarSize.md,
    this.shape = D3AvatarShape.circle,
    this.indicator = D3AvatarIndicator.none,
    this.semanticsLabel,
  });

  /// Used to derive initials and background color.
  final String name;

  /// URL of the avatar image. Displayed via [Image.network] when provided;
  /// falls back to initials if the request fails or the URL is null.
  ///
  /// To swap to cached_network_image for disk caching, replace the
  /// [Image.network] call inside [_AvatarImage._buildImage] with:
  ///
  /// ```dart
  /// CachedNetworkImage(
  ///   imageUrl: imageUrl,
  ///   fit: BoxFit.cover,
  ///   placeholder: (_, __) => const SizedBox.shrink(),
  ///   errorWidget: (_, __, ___) => _InitialsFallback(name: name, size: size),
  /// )
  /// ```
  ///
  /// Add `cached_network_image` to pubspec.yaml and import it at the top of
  /// this file. No public API changes needed.
  final String? imageUrl;

  final D3AvatarSize size;
  final D3AvatarShape shape;
  final D3AvatarIndicator indicator;

  /// Overrides the screen-reader label. Defaults to [name].
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final hasIndicator =
        indicator != D3AvatarIndicator.none && size.indicatorSize > 0;

    Widget avatar = _AvatarImage(
      name: name,
      imageUrl: imageUrl,
      size: size,
      shape: shape,
    );

    if (hasIndicator) {
      avatar = Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          Positioned(
            bottom: 0,
            right: 0,
            child: _IndicatorDot(
              indicator: indicator,
              dotSize: size.indicatorSize,
              borderWidth: size.indicatorBorder,
              borderColor: surfaceColor,
            ),
          ),
        ],
      );
    }

    return Semantics(
      label: semanticsLabel ?? name,
      image: imageUrl != null,
      child: avatar,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AvatarImage
// ─────────────────────────────────────────────────────────────────────────────

class _AvatarImage extends StatelessWidget {
  const _AvatarImage({
    required this.name,
    required this.imageUrl,
    required this.size,
    required this.shape,
  });

  final String name;
  final String? imageUrl;
  final D3AvatarSize size;
  final D3AvatarShape shape;

  BorderRadius get _borderRadius => shape == D3AvatarShape.circle
      ? BorderRadius.circular(size.dimension / 2)
      : BorderRadius.circular(size.borderRadius);

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size.dimension,
      child: ClipRRect(
        borderRadius: _borderRadius,
        child: imageUrl != null ? _buildImage() : _buildInitials(),
      ),
    );
  }

  Widget _buildImage() {
    // ─── Swap point for cached_network_image ───────────────────────────────
    // Replace this Image.network with CachedNetworkImage (see D3Avatar.imageUrl
    // doc comment for the exact snippet).
    // ──────────────────────────────────────────────────────────────────────────
    return Image.network(
      imageUrl!,
      width: size.dimension,
      height: size.dimension,
      fit: BoxFit.cover,
      // While loading, show initials so there is never a blank frame.
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) return child;
        return _buildInitials();
      },
      // On any error (404, no network, etc.) fall back to initials.
      errorBuilder: (_, __, ___) => _buildInitials(),
    );
  }

  Widget _buildInitials() => _InitialsFallback(name: name, size: size);
}

// ─────────────────────────────────────────────────────────────────────────────
// _InitialsFallback
// ─────────────────────────────────────────────────────────────────────────────

class _InitialsFallback extends StatelessWidget {
  const _InitialsFallback({required this.name, required this.size});

  final String name;
  final D3AvatarSize size;

  /// Extracts up to 2 initials from [name]. Handles single-word names.
  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  /// Deterministic color index derived from the name so the same person
  /// always gets the same color across sessions and devices.
  static int _colorIndex(String name) {
    int hash = 0;
    for (final codeUnit in name.codeUnits) {
      hash = (hash * 31 + codeUnit) & 0x7fffffff;
    }
    return hash % _palette.length;
  }

  // (background, foreground) pairs — all from the design token palette.
  static const _palette = [
    (Color(0xFFCECBF6), Color(0xFF3C3489)), // purple
    (Color(0xFF9FE1CB), Color(0xFF085041)), // teal
    (Color(0xFFF5C4B3), Color(0xFF712B13)), // coral
    (Color(0xFFB5D4F4), Color(0xFF0C447C)), // blue
    (Color(0xFFFAC775), Color(0xFF633806)), // amber
    (Color(0xFFF4C0D1), Color(0xFF72243E)), // pink
    (Color(0xFFC0DD97), Color(0xFF27500A)), // green
  ];

  @override
  Widget build(BuildContext context) {
    final idx = _colorIndex(name);
    final (bg, fg) = _palette[idx];

    return ColoredBox(
      color: bg,
      child: SizedBox.square(
        dimension: size.dimension,
        child: Center(
          child: Text(
            _initials(name),
            style: TextStyle(
              fontSize: size.fontSize,
              fontWeight: FontWeight.w600,
              color: fg,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _IndicatorDot
// ─────────────────────────────────────────────────────────────────────────────

class _IndicatorDot extends StatelessWidget {
  const _IndicatorDot({
    required this.indicator,
    required this.dotSize,
    required this.borderWidth,
    required this.borderColor,
  });

  final D3AvatarIndicator indicator;
  final double dotSize;
  final double borderWidth;
  final Color borderColor;

  Color get _dotColor => switch (indicator) {
        D3AvatarIndicator.online  => const Color(0xFF1D9E75),
        D3AvatarIndicator.busy    => const Color(0xFFE24B4A),
        D3AvatarIndicator.offline => const Color(0xFF888780),
        D3AvatarIndicator.none    => Colors.transparent,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: dotSize,
      height: dotSize,
      decoration: BoxDecoration(
        color: _dotColor,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: borderWidth),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// D3AvatarGroup
// ─────────────────────────────────────────────────────────────────────────────

/// Displays a horizontal stack of [D3Avatar]s with configurable overlap.
/// When the list exceeds [max], the surplus is collapsed into a "+N" overflow
/// avatar that uses the same size and a neutral tinted background.
///
/// ```dart
/// D3AvatarGroup(
///   avatars: [
///     D3Avatar(name: 'Dan Lee'),
///     D3Avatar(name: 'Jane Kim'),
///     D3Avatar(name: 'Mark Santos'),
///     D3Avatar(name: 'Amy Chen'),
///     D3Avatar(name: 'Luis Reyes'),
///   ],
///   max: 4,
/// )
/// ```
class D3AvatarGroup extends StatelessWidget {
  const D3AvatarGroup({
    super.key,
    required this.avatars,
    this.max = 4,
    this.overlap = 8.0,
    this.size = D3AvatarSize.md,
  })  : assert(avatars.length > 0, 'D3AvatarGroup requires at least one avatar.'),
        assert(max >= 1, 'max must be at least 1.');

  final List<D3Avatar> avatars;

  /// Maximum number of avatars shown before collapsing into +N.
  final int max;

  /// How many pixels each avatar overlaps the previous one.
  final double overlap;

  /// Size applied to all avatars in the group and the overflow badge.
  final D3AvatarSize size;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    final visible = avatars.take(max).toList();
    final overflowCount = avatars.length - visible.length;
    final total = visible.length + (overflowCount > 0 ? 1 : 0);

    return SizedBox(
      height: size.dimension,
      width: size.dimension + (total - 1) * (size.dimension - overlap),
      child: Stack(
        children: [
          for (int i = 0; i < visible.length; i++)
            Positioned(
              left: i * (size.dimension - overlap),
              child: _BorderedAvatar(
                borderColor: colors.surface,
                size: size,
                child: D3Avatar(
                  name: visible[i].name,
                  imageUrl: visible[i].imageUrl,
                  size: size,
                  shape: visible[i].shape,
                ),
              ),
            ),

          if (overflowCount > 0)
            Positioned(
              left: visible.length * (size.dimension - overlap),
              child: _BorderedAvatar(
                borderColor: colors.surface,
                size: size,
                child: _OverflowBadge(
                  count: overflowCount,
                  size: size,
                  colors: colors,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BorderedAvatar extends StatelessWidget {
  const _BorderedAvatar({
    required this.child,
    required this.borderColor,
    required this.size,
  });

  final Widget child;
  final Color borderColor;
  final D3AvatarSize size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.dimension,
      height: size.dimension,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2),
      ),
      child: ClipOval(child: child),
    );
  }
}

class _OverflowBadge extends StatelessWidget {
  const _OverflowBadge({
    required this.count,
    required this.size,
    required this.colors,
  });

  final int count;
  final D3AvatarSize size;
  final D3ColorTokens colors;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size.dimension,
      child: ColoredBox(
        color: colors.onSurface.withValues(alpha: 0.08),
        child: Center(
          child: Text(
            '+$count',
            style: TextStyle(
              fontSize: size.fontSize,
              fontWeight: FontWeight.w600,
              color: colors.onSurfaceVariant,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}
