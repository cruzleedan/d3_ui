import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:d3_ui/d3_ui.dart';

// ─────────────────────────────────────────────────────────────────────────────
// D3WatchStatus
// ─────────────────────────────────────────────────────────────────────────────

/// Watchlist status for an anime or manga entry.
enum D3WatchStatus {
  watching,
  completed,
  planToWatch,
  paused,
  dropped,
}

/// Convenience extensions on [D3WatchStatus].
extension D3WatchStatusExtension on D3WatchStatus {
  String get label {
    switch (this) {
      case D3WatchStatus.watching:
        return 'Watching';
      case D3WatchStatus.completed:
        return 'Completed';
      case D3WatchStatus.planToWatch:
        return 'Plan to Watch';
      case D3WatchStatus.paused:
        return 'Paused';
      case D3WatchStatus.dropped:
        return 'Dropped';
    }
  }

  IconData get icon {
    switch (this) {
      case D3WatchStatus.watching:
        return Icons.play_circle_outline_rounded;
      case D3WatchStatus.completed:
        return Icons.check_circle_outline_rounded;
      case D3WatchStatus.planToWatch:
        return Icons.bookmark_border_rounded;
      case D3WatchStatus.paused:
        return Icons.pause_circle_outline_rounded;
      case D3WatchStatus.dropped:
        return Icons.cancel_outlined;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// D3StatusChip
// ─────────────────────────────────────────────────────────────────────────────

/// A pre-configured [D3Chip] that displays a [D3WatchStatus] badge.
class D3StatusChip extends StatelessWidget {
  const D3StatusChip({super.key, required this.status, this.onTap});

  final D3WatchStatus status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: D3Chip(
        label: status.label,
        leadingIcon: status.icon,
        variant: D3ChipVariant.tonal,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// D3ChipVariant
// ─────────────────────────────────────────────────────────────────────────────

enum D3ChipVariant {
  /// Solid primary fill with onPrimary label. Used for selected/active chips.
  filled,

  /// Soft primary-container fill with onPrimaryContainer label.
  tonal,

  /// Transparent with an outline border. Default for unselected filter chips.
  outlined,
}

// ─────────────────────────────────────────────────────────────────────────────
// D3Chip
// ─────────────────────────────────────────────────────────────────────────────

/// A compact, tappable label chip for filters, tags, and status badges.
///
/// When [selected] is true the chip switches to [D3ChipVariant.filled] and
/// prepends a checkmark icon — a color-blind-safe selection cue.
///
/// Pass `enabled: false` to disable. `onTap: null` also makes the chip
/// non-interactive but keeps full opacity (read-only badge use case).
///
/// For [D3ChipVariant.filled] (and `selected`), [backgroundColor] and
/// [foregroundColor] override the default `colors.primary`/`colors.onPrimary`
/// fill — e.g. to render a status-colored badge (success, warning, error).
///
/// ```dart
/// D3Chip(
///   label: 'Approved',
///   variant: D3ChipVariant.filled,
///   backgroundColor: context.d3Colors.success,
///   foregroundColor: context.d3Colors.onSuccess,
/// )
/// ```
///
/// ```dart
/// // Filter chip (toggleable)
/// D3Chip(
///   label: 'Action',
///   selected: _genres.contains('Action'),
///   onTap: () => _toggle('Action'),
/// )
///
/// // Status badge (read-only)
/// D3Chip(
///   label: 'Watching',
///   variant: D3ChipVariant.tonal,
///   leadingIcon: Icons.play_circle_outline_rounded,
/// )
///
/// // Dismissible tag
/// D3Chip(
///   label: 'Fantasy',
///   trailingIcon: Icons.close_rounded,
///   onTap: _remove,
/// )
/// ```
class D3Chip extends StatelessWidget {
  const D3Chip({
    super.key,
    required this.label,
    this.variant = D3ChipVariant.outlined,
    this.selected = false,
    this.enabled = true,
    this.leadingIcon,
    this.trailingIcon,
    this.onTap,
    this.semanticsLabel,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String label;
  final D3ChipVariant variant;

  /// When true the chip renders filled with a leading checkmark.
  final bool selected;

  /// When false the chip is dimmed (opacity 0.35) and non-interactive.
  final bool enabled;

  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final VoidCallback? onTap;
  final String? semanticsLabel;

  /// Overrides the background fill for [D3ChipVariant.filled] (including the
  /// `selected` state). Ignored for `tonal`/`outlined`. Falls back to
  /// `colors.primary` when null.
  final Color? backgroundColor;

  /// Overrides the label/icon color for [D3ChipVariant.filled] (including the
  /// `selected` state). Ignored for `tonal`/`outlined`. Falls back to
  /// `colors.onPrimary` when null.
  final Color? foregroundColor;

  bool get _interactive => onTap != null && enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    final effectiveVariant = selected ? D3ChipVariant.filled : variant;

    final Color bg;
    final Color fg;
    final Border? border;

    switch (effectiveVariant) {
      case D3ChipVariant.filled:
        bg = backgroundColor ?? colors.primary;
        fg = foregroundColor ?? colors.onPrimary;
        border = null;
      case D3ChipVariant.tonal:
        bg = colors.primaryContainer;
        fg = colors.onPrimaryContainer;
        border = null;
      case D3ChipVariant.outlined:
        bg = Colors.transparent;
        fg = colors.onSurfaceVariant;
        border = Border.all(color: colors.outline, width: 0.5);
    }

    final chip = DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: D3Radius.circularFull,
        border: border,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: D3Spacing.s12,
          vertical: D3Spacing.s6,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Checkmark when selected (color-blind-safe); otherwise leadingIcon.
            if (selected) ...[
              Icon(Icons.check_rounded, size: 13, color: fg),
              const SizedBox(width: D3Spacing.s4),
            ] else if (leadingIcon != null) ...[
              Icon(leadingIcon, size: 14, color: fg),
              const SizedBox(width: D3Spacing.s4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: D3TypeScale.labelMdSize,
                fontWeight: FontWeight.w500,
                color: fg,
                height: 1.0,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (trailingIcon != null) ...[
              const SizedBox(width: D3Spacing.s4),
              Icon(trailingIcon, size: 14, color: fg),
            ],
          ],
        ),
      ),
    );

    if (!enabled) {
      return Opacity(opacity: 0.35, child: chip);
    }

    if (!_interactive) return chip;

    return Semantics(
      label: semanticsLabel ?? label,
      button: true,
      selected: selected,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap!();
        },
        borderRadius: D3Radius.circularFull,
        child: chip,
      ),
    );
  }
}
