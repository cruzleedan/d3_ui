import 'package:flutter/material.dart';
import 'package:d3_ui/d3_ui.dart';

// ─────────────────────────────────────────────────────────────────────────────
// D3EmptyState
// ─────────────────────────────────────────────────────────────────────────────

/// A centred placeholder shown when a screen, list, or container has no
/// content to display.
///
/// Pass [iconColor] to tint both the icon and its rounded container; it
/// defaults to [D3ColorTokens.onSurfaceVariant] for a neutral appearance.
///
/// **Standard (fills its parent):**
/// ```dart
/// D3EmptyState(
///   icon: Icons.inbox_outlined,
///   title: 'No items yet',
///   message: 'Create your first item to get started.',
///   action: D3Button(label: 'Create item', onPressed: _create),
/// )
/// ```
///
/// **Error state:**
/// ```dart
/// D3EmptyState(
///   icon: Icons.wifi_off_rounded,
///   iconColor: context.d3Colors.error,
///   title: 'Something went wrong',
///   message: 'Check your connection and try again.',
///   action: D3Button(label: 'Try again', onPressed: _retry),
/// )
/// ```
///
/// **Compact — embeds inside an existing container:**
/// ```dart
/// D3EmptyState(
///   icon: Icons.check_circle_outline,
///   iconColor: context.d3Colors.primary,
///   title: 'All caught up',
///   compact: true,
/// )
/// ```
class D3EmptyState extends StatelessWidget {
  const D3EmptyState({
    super.key,
    required this.icon,
    this.iconColor,
    required this.title,
    this.message,
    this.action,
    this.secondaryAction,
    this.compact = false,
  });

  /// Icon displayed inside the tinted rounded container.
  final IconData icon;

  /// Color applied to the icon and auto-derived background container.
  /// Defaults to [D3ColorTokens.onSurfaceVariant].
  final Color? iconColor;

  /// Short, bold heading.
  final String title;

  /// Optional supporting text below the title.
  final String? message;

  /// Primary call-to-action widget (typically a [D3Button]).
  final Widget? action;

  /// Optional secondary action rendered below [action]
  /// (e.g. a ghost or text button).
  final Widget? secondaryAction;

  /// When true, reduces icon size and vertical padding so the component
  /// fits inside cards or other bounded containers without a full-screen
  /// treatment.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    final effectiveIconColor = iconColor ?? colors.onSurfaceVariant;

    final double iconContainerSize = compact ? 48 : 64;
    final double iconContainerRadius = compact ? D3Radius.md : D3Radius.lg + 4;
    final double iconSize = compact ? 22 : 28;
    final double titleSize = compact ? 13 : 15;
    final double messageSize = compact ? 12 : 13;
    final EdgeInsets padding = compact
        ? const EdgeInsets.symmetric(horizontal: 16, vertical: 24)
        : const EdgeInsets.symmetric(horizontal: 24, vertical: 40);

    final hasActions = action != null || secondaryAction != null;

    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Icon ───────────────────────────────────────────────────────────
          Container(
            width: iconContainerSize,
            height: iconContainerSize,
            decoration: BoxDecoration(
              color: effectiveIconColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(iconContainerRadius),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: iconSize, color: effectiveIconColor),
          ),

          SizedBox(height: compact ? D3Spacing.s12 : D3Spacing.s16),

          // ── Title ──────────────────────────────────────────────────────────
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
              letterSpacing: -0.1,
              height: 1.3,
            ),
          ),

          // ── Message ────────────────────────────────────────────────────────
          if (message != null) ...[
            const SizedBox(height: D3Spacing.s6),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: messageSize,
                color: colors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],

          // ── Actions ────────────────────────────────────────────────────────
          if (hasActions) ...[
            SizedBox(height: compact ? D3Spacing.s16 : D3Spacing.s20),
            if (action != null) action!,
            if (secondaryAction != null) ...[
              const SizedBox(height: D3Spacing.s8),
              secondaryAction!,
            ],
          ],
        ],
      ),
    );
  }
}
