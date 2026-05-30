import 'package:flutter/material.dart';
import 'package:d3_ui/d3_ui.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Enums
// ─────────────────────────────────────────────────────────────────────────────

enum D3CardVariant {
  /// White/surface fill with a subtle border. Default.
  elevated,

  /// Soft primary-container fill, no border. For featured content.
  tonal,
}

// ─────────────────────────────────────────────────────────────────────────────
// D3Card
// ─────────────────────────────────────────────────────────────────────────────

/// A surface container with optional media, header, body, and footer slots.
///
/// All slots are optional — combine only what you need:
///
/// ```dart
/// // Simple content card
/// D3Card(
///   title: 'Hello',
///   content: Text('Body copy'),
///   onTap: () {},
/// )
///
/// // Media card with footer
/// D3Card(
///   media: Image.network(url, fit: BoxFit.cover),
///   eyebrow: 'Design',
///   title: 'Getting started with tokens',
///   subtitle: '5 min read',
///   content: Text('Learn how color, spacing, and radius tokens...'),
///   footerAction: TextButton(onPressed: () {}, child: Text('Read more')),
///   footerTrailing: Text('Mar 2025'),
///   onTap: () {},
/// )
///
/// // Tonal variant
/// D3Card(
///   variant: D3CardVariant.tonal,
///   title: 'Featured',
///   content: Text('Highlighted content'),
/// )
/// ```
///
/// ## Poster card (fixed-size grid cell)
/// When [mediaFill] is `true` the media slot becomes [Expanded] and fills
/// whatever height the parent provides. [mediaHeight] is ignored. Use this
/// whenever the card is placed inside a grid cell or any other
/// fixed-dimension container to prevent overflow:
/// ```dart
/// D3Card(
///   mediaFill: true,
///   media: D3Image(url: url),
///   title: 'Attack on Titan',
///   titleMaxLines: 2,
///   subtitle: '★ 9.0',
///   onTap: () {},
/// )
/// ```
class D3Card extends StatelessWidget {
  const D3Card({
    super.key,
    this.variant = D3CardVariant.elevated,
    this.border,
    // Media slot
    this.media,
    this.mediaHeight = 180,
    this.mediaFill = false,
    // Header slots
    this.eyebrow,
    this.title,
    this.titleMaxLines = 1,
    this.subtitle,
    // Body slot
    this.content,
    // Footer slots
    this.footerAction,
    this.footerTrailing,
    // Interaction
    this.onTap,
    this.onLongPress,
    this.semanticsLabel,
  });

  final D3CardVariant variant;

  /// Border drawn around the card.
  ///
  /// Defaults to a 0.5px subtle outline on [D3CardVariant.elevated] and
  /// no border on [D3CardVariant.tonal].
  ///
  /// Pass [BorderSide.none] to hide the border entirely, or a custom
  /// [BorderSide] to change color or width:
  /// ```dart
  /// border: BorderSide(color: colors.primary, width: 1.5)
  /// border: BorderSide.none
  /// ```
  final BorderSide? border;

  /// Full-bleed widget at the top of the card (typically an [Image]).
  final Widget? media;

  /// Height of the [media] slot. Defaults to 180.
  /// Ignored when [mediaFill] is `true`.
  final double mediaHeight;

  /// When `true` the media slot expands to fill available height instead of
  /// using [mediaHeight]. The card must be placed inside a fixed-size
  /// container (e.g. a grid cell). Defaults to `false`.
  final bool mediaFill;

  /// Small all-caps label above [title] (e.g. a category name).
  final String? eyebrow;

  /// Primary title text.
  final String? title;

  /// Maximum number of lines for [title] before ellipsis. Defaults to 1.
  final int titleMaxLines;

  /// Secondary subtitle text below [title].
  final String? subtitle;

  /// Arbitrary widget rendered in the body slot below the header.
  final Widget? content;

  /// Leading widget in the footer row (e.g. a [TextButton] or [D3Button]).
  final Widget? footerAction;

  /// Trailing widget in the footer row (e.g. a metadata label).
  final Widget? footerTrailing;

  /// Makes the whole card tappable with an ink ripple. When null the card
  /// is static.
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Semantics label for the whole card. Falls back to [title] when null.
  final String? semanticsLabel;

  bool get _hasHeader => eyebrow != null || title != null || subtitle != null;
  bool get _hasFooter => footerAction != null || footerTrailing != null;
  bool get _hasBody => _hasHeader || content != null;
  bool get _isInteractive => onTap != null || onLongPress != null;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;

    final bgColor = switch (variant) {
      D3CardVariant.elevated => colors.surface,
      D3CardVariant.tonal => colors.primaryContainer,
    };

    final defaultBorder = BorderSide(
      color: colors.outline.withValues(alpha: 0.4),
      width: 1.0,
    );
    final borderSide = border ?? defaultBorder;

    final radius = BorderRadius.circular(D3Radius.lg);

    // Build the visual content stack.
    // mediaFill mode uses mainAxisSize.max + Expanded so the card fills its
    // parent container; default mode shrink-wraps with mainAxisSize.min.
    Widget cardContent = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: mediaFill ? MainAxisSize.max : MainAxisSize.min,
      children: [
        // ── Media ───────────────────────────────────────────────────────────
        if (media != null)
          mediaFill
              ? Expanded(child: media!)
              : SizedBox(height: mediaHeight, child: media!),

        // ── Header + Body ────────────────────────────────────────────────────
        if (_hasBody)
          Padding(
            padding: EdgeInsets.fromLTRB(
              D3Spacing.s16,
              media != null ? D3Spacing.s12 : D3Spacing.s16,
              D3Spacing.s16,
              _hasFooter ? D3Spacing.s12 : D3Spacing.s16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_hasHeader) ...[
                  _CardHeader(
                    eyebrow: eyebrow,
                    title: title,
                    titleMaxLines: titleMaxLines,
                    subtitle: subtitle,
                    colors: colors,
                    variant: variant,
                  ),
                  if (content != null) const SizedBox(height: 8),
                ],
                if (content != null) content!,
              ],
            ),
          ),

        // ── Footer ──────────────────────────────────────────────────────────
        if (_hasFooter) ...[
          Divider(
            height: 0.5,
            thickness: 0.5,
            color: colors.outline.withValues(alpha: 0.15),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: D3Spacing.s16,
              vertical: D3Spacing.s10,
            ),
            child: Row(
              children: [
                if (footerAction != null) footerAction!,
                const Spacer(),
                if (footerTrailing != null) footerTrailing!,
              ],
            ),
          ),
        ],
      ],
    );

    // Wrap in Material + InkWell when interactive so ripple paints correctly
    // on the colored surface.
    Widget card = Material(
      color: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: borderSide,
      ),
      clipBehavior: Clip.antiAlias,
      child: _isInteractive
          ? InkWell(
              onTap: onTap,
              onLongPress: onLongPress,
              splashColor: colors.primary.withValues(alpha: 0.08),
              highlightColor: colors.primary.withValues(alpha: 0.04),
              child: cardContent,
            )
          : cardContent,
    );

    if (semanticsLabel != null || title != null) {
      card = Semantics(
        label: semanticsLabel ?? title,
        button: _isInteractive,
        child: card,
      );
    }

    return card;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card header
// ─────────────────────────────────────────────────────────────────────────────

class _CardHeader extends StatelessWidget {
  const _CardHeader({
    this.eyebrow,
    this.title,
    this.titleMaxLines = 1,
    this.subtitle,
    required this.colors,
    required this.variant,
  });

  final String? eyebrow;
  final String? title;
  final int titleMaxLines;
  final String? subtitle;
  final D3ColorTokens colors;
  final D3CardVariant variant;

  @override
  Widget build(BuildContext context) {
    final titleColor = variant == D3CardVariant.tonal
        ? colors.onPrimaryContainer
        : colors.onSurface;
    final subtitleColor = variant == D3CardVariant.tonal
        ? colors.onPrimaryContainer.withValues(alpha: 0.7)
        : colors.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (eyebrow != null) ...[
          Text(
            eyebrow!.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 4),
        ],
        if (title != null)
          Text(
            title!,
            maxLines: titleMaxLines,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: titleColor,
              letterSpacing: -0.2,
              height: 1.3,
            ),
          ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: TextStyle(
              fontSize: 12,
              color: subtitleColor,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }
}
