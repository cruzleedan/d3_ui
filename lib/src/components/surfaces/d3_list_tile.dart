import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:d3_ui/d3_ui.dart';

// ─────────────────────────────────────────────────────────────────────────────
// D3ListTileGroup
// ─────────────────────────────────────────────────────────────────────────────

/// Wraps a list of [D3ListTile]s in a rounded card surface with automatic
/// dividers between rows.
///
/// ```dart
/// D3ListTileGroup(
///   children: [
///     D3ListTile(
///       leading: D3ListTileIcon(icon: Icons.notifications_outlined),
///       title: 'Notifications',
///       trailing: const Icon(Icons.chevron_right_rounded),
///       onTap: () {},
///     ),
///     D3ListTile(
///       leading: D3ListTileIcon(icon: Icons.shield_outlined, color: Colors.green),
///       title: 'Privacy',
///       subtitle: 'Manage your data',
///       trailing: const Icon(Icons.chevron_right_rounded),
///       onTap: () {},
///     ),
///   ],
/// )
/// ```
class D3ListTileGroup extends StatelessWidget {
  const D3ListTileGroup({
    super.key,
    required this.children,
    this.border,
  }) : assert(children.length > 0,
            'D3ListTileGroup requires at least one child.');

  final List<D3ListTile> children;

  /// Override the group border. Defaults to a 1px subtle outline.
  final BorderSide? border;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    final effectiveBorder =
        border ?? BorderSide(color: colors.outline, width: 0.5);

    return ClipRRect(
      borderRadius: BorderRadius.circular(D3Radius.lg),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.fromBorderSide(effectiveBorder),
          borderRadius: BorderRadius.circular(D3Radius.lg),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < children.length; i++) ...[
              if (i > 0)
                Divider(
                  height: 0,
                  thickness: 0.5,
                  indent: _dividerIndent(children[i - 1]),
                  color: colors.outline,
                ),
              children[i],
            ],
          ],
        ),
      ),
    );
  }

  /// Aligns the divider with the title text by indenting past the leading
  /// widget. Falls back to 0 when no leading is present.
  double _dividerIndent(D3ListTile tile) {
    if (tile.leading == null) return 0;
    // leading (36) + tile padding left (14) + gap (12)
    return 14 + 36 + 12;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// D3ListTile
// ─────────────────────────────────────────────────────────────────────────────

/// A single row in a list. Composes a leading widget, title + subtitle text
/// block, and a trailing widget.
///
/// Wrap multiple tiles in [D3ListTileGroup] for automatic dividers and a
/// rounded card surface.
class D3ListTile extends StatelessWidget {
  const D3ListTile({
    super.key,
    this.leading,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.subtitleWidget,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.isDestructive = false,
    this.enabled = true,
    this.contentPadding,
    this.minHeight = 52,
    this.semanticsLabel,
  }) : assert(
          title != null || titleWidget != null,
          'D3ListTile requires either title or titleWidget.',
        );

  /// Optional widget in the leading slot. Use [D3ListTileIcon] for the
  /// standard colored icon container.
  final Widget? leading;

  /// Plain text title. Mutually exclusive with [titleWidget] — provide one.
  final String? title;

  /// Widget override for the title slot. Use when you need rich text (e.g.
  /// [D3SearchAnchor.highlight]). Takes precedence over [title].
  final Widget? titleWidget;

  /// Plain text subtitle.
  final String? subtitle;

  /// Widget override for the subtitle slot. Takes precedence over [subtitle].
  final Widget? subtitleWidget;

  /// Optional widget in the trailing slot (e.g. [Icon], [Switch], badge).
  final Widget? trailing;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Renders the title in [D3ColorTokens.error] and applies reduced opacity.
  /// Use for destructive actions like "Sign out" or "Delete account".
  final bool isDestructive;

  final bool enabled;

  /// Override internal padding. Defaults to `EdgeInsets.symmetric(horizontal: 14, vertical: 10)`.
  final EdgeInsetsGeometry? contentPadding;

  /// Minimum tile height. Defaults to 52.
  final double minHeight;

  final String? semanticsLabel;

  bool get _isInteractive => enabled && (onTap != null || onLongPress != null);

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;

    final titleColor = isDestructive
        ? colors.error
        : enabled
            ? colors.onSurface
            : colors.onSurface.withValues(alpha: 0.38);

    final subtitleColor = enabled
        ? colors.onSurfaceVariant
        : colors.onSurfaceVariant.withValues(alpha: 0.38);

    Widget content = ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: Padding(
        padding: contentPadding ??
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Leading
            if (leading != null) ...[
              leading!,
              const SizedBox(width: 12),
            ],

            // Title + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  titleWidget ??
                      Text(
                        title!,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: titleColor,
                          height: 1.3,
                        ),
                      ),
                  if (subtitleWidget != null || subtitle != null) ...[
                    const SizedBox(height: 2),
                    subtitleWidget ??
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
              ),
            ),

            // Trailing
            if (trailing != null) ...[
              const SizedBox(width: 8),
              DefaultTextStyle(
                style: TextStyle(
                  fontSize: 13,
                  color: colors.onSurfaceVariant,
                ),
                child: IconTheme(
                  data: IconThemeData(
                    color: colors.onSurfaceVariant,
                    size: 18,
                  ),
                  child: trailing!,
                ),
              ),
            ],
          ],
        ),
      ),
    );

    // Ripple when interactive.
    Widget tile = Material(
      color: colors.surface,
      child: _isInteractive
          ? InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                onTap!();
              },
              onLongPress: onLongPress,
              splashColor: colors.primary.withValues(alpha: 0.06),
              highlightColor: colors.primary.withValues(alpha: 0.03),
              child: content,
            )
          : content,
    );

    if (!enabled) {
      tile = Opacity(opacity: 0.5, child: tile);
    }

    return Semantics(
      label: semanticsLabel ?? title ?? '',
      button: _isInteractive,
      enabled: enabled,
      child: tile,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// D3ListTileIcon
// ─────────────────────────────────────────────────────────────────────────────

/// Convenience leading widget: a rounded square with a tinted fill and an
/// icon centred inside. Matches the style shown in settings-style list rows.
///
/// ```dart
/// D3ListTile(
///   leading: D3ListTileIcon(
///     icon: Icons.notifications_outlined,
///     color: context.d3Colors.primary,        // icon + fill tint
///   ),
///   ...
/// )
/// ```
class D3ListTileIcon extends StatelessWidget {
  const D3ListTileIcon({
    super.key,
    required this.icon,
    this.color,
    this.backgroundColor,
    this.size = 36,
    this.iconSize = 18,
  });

  final IconData icon;

  /// Icon color. Also derives [backgroundColor] when that is null.
  /// Defaults to [D3ColorTokens.primary].
  final Color? color;

  /// Fill color of the rounded container. Auto-derived as a low-opacity tint
  /// of [color] when null.
  final Color? backgroundColor;

  /// Size of the rounded container. Defaults to 36.
  final double size;

  /// Size of the icon inside. Defaults to 18.
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? context.d3Colors.primary;
    final effectiveBg =
        backgroundColor ?? effectiveColor.withValues(alpha: 0.12);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(D3Radius.sm),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: iconSize, color: effectiveColor),
    );
  }
}
