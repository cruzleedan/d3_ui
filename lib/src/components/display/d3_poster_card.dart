import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:d3_ui/d3_ui.dart';

// ─────────────────────────────────────────────────────────────────────────────
// D3PosterCard
// ─────────────────────────────────────────────────────────────────────────────

/// A full-bleed image poster card with a frosted-glass info overlay.
///
/// Designed for media browsing grids — anime, movies, shows, books, etc.
/// The card fills its parent container entirely (use inside a fixed-height
/// grid cell or any constrained box).
///
/// ```dart
/// D3PosterCard(
///   imageUrl: 'https://example.com/cover.jpg',
///   title: 'Attack on Titan',
///   subtitle: '★ 9.0',
///   tags: const ['Action', 'Drama'],
///   badge: MyWatchlistBadge(),
///   onTap: () => context.push('/detail/1'),
///   onLongPress: () => showQuickActionsSheet(context),
/// )
/// ```
///
/// ## Badge slot
/// The [badge] widget is positioned in the top-right corner of the card.
/// Use it for status indicators, bookmarks, or any overlay action:
/// ```dart
/// badge: Icon(Icons.bookmark_rounded, color: Colors.white),
/// ```
///
/// ## Tags
/// [tags] renders small pill labels at the bottom of the info panel.
/// Pass at most 2–3 short labels to avoid crowding.
class D3PosterCard extends StatelessWidget {
  const D3PosterCard({
    super.key,
    required this.imageUrl,
    required this.title,
    this.subtitle,
    this.tags = const [],
    this.badge,
    this.onTap,
    this.onLongPress,
    this.semanticsLabel,
  });

  /// URL for the full-bleed cover image.
  final String imageUrl;

  /// Primary title shown in the frosted-glass info panel.
  final String title;

  /// Optional secondary line below [title] (e.g. a score string "★ 9.0").
  final String? subtitle;

  /// Short pill labels rendered below [subtitle] (e.g. genre names).
  /// Only the first two are shown to keep the panel compact.
  final List<String> tags;

  /// Widget anchored to the top-right corner of the card.
  /// Use for watchlist badges, bookmark icons, etc.
  final Widget? badge;

  /// Called when the card is tapped.
  final VoidCallback? onTap;

  /// Called when the card is long-pressed.
  final VoidCallback? onLongPress;

  /// Accessibility label. Defaults to [title].
  final String? semanticsLabel;

  // Limit tags to 2 at construction time so build() never allocates a list.
  List<String> get _visibleTags =>
      tags.length <= 2 ? tags : tags.sublist(0, 2);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final visibleTags = _visibleTags;

    return RepaintBoundary(
      child: Semantics(
      label: semanticsLabel ?? title,
      button: onTap != null || onLongPress != null,
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(D3Radius.lg),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Full-bleed cover image ──────────────────────────────────
              D3Image(
                url: imageUrl,
                semanticsLabel: semanticsLabel ?? title,
              ),

              // ── Gradient vignette ───────────────────────────────────────
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Color(0xCC000000),
                    ],
                    stops: [0.0, 0.45, 1.0],
                  ),
                ),
              ),

              // ── Frosted-glass info panel ────────────────────────────────
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.white],
                    stops: [0.0, 0.18],
                  ).createShader(bounds),
                  blendMode: BlendMode.dstIn,
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.45),
                        padding: const EdgeInsets.fromLTRB(
                          D3Spacing.s10,
                          D3Spacing.s16,
                          D3Spacing.s10,
                          D3Spacing.s12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              style: textTheme.labelMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                height: 1.25,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (subtitle != null) ...[
                              const SizedBox(height: D3Spacing.s2),
                              Text(
                                subtitle!,
                                style: textTheme.labelSmall?.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                            if (visibleTags.isNotEmpty) ...[
                              const SizedBox(height: D3Spacing.s6),
                              _PosterTagChips(tags: visibleTags),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Badge slot (top-right) ──────────────────────────────────
              if (badge != null)
                Positioned(
                  top: D3Spacing.s6,
                  right: D3Spacing.s6,
                  child: badge!,
                ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tag chips
// ─────────────────────────────────────────────────────────────────────────────

/// White semi-transparent pill labels for the frosted-glass info panel.
class _PosterTagChips extends StatelessWidget {
  const _PosterTagChips({required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: D3Spacing.s4,
      children: [
        for (final tag in tags)
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.45),
                width: 0.5,
              ),
              borderRadius: D3Radius.circularFull,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: D3Spacing.s8,
                vertical: 3,
              ),
              child: Text(
                tag,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                  height: 1.2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// D3PosterCardSkeleton
// ─────────────────────────────────────────────────────────────────────────────

/// Shimmer placeholder that matches the [D3PosterCard] layout.
/// Drop it into the same grid cell while data is loading.
///
/// ```dart
/// asyncAnime.when(
///   loading: () => const D3PosterCardSkeleton(),
///   data: (anime) => D3PosterCard(...),
///   error: (e, _) => ...,
/// )
/// ```
class D3PosterCardSkeleton extends StatelessWidget {
  const D3PosterCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const D3Shimmer(
      child: D3Card(
        mediaFill: true,
        media: D3SkeletonBox(),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            D3SkeletonBox(height: 14, width: 120),
            SizedBox(height: D3Spacing.s4),
            D3SkeletonBox(height: 12, width: 60),
          ],
        ),
      ),
    );
  }
}
