import 'package:material_ui/material_ui.dart';
import 'package:d3_ui/d3_ui.dart';

/// A labeled section-header row — a bold "Label (N)" title on the left,
/// with a single trailing icon button on the right for the section's one
/// primary action (add, expand/collapse, etc). Used above a list to give
/// it a visible, bounded, labeled group instead of a flat card list with
/// nothing tying the items together.
///
/// Wrap in [D3StickyHeader] when the section's action should stay
/// reachable while scrolling a long list (e.g. "Add" on a growing list);
/// use plain/unwrapped when there's nothing that needs to stay pinned
/// (e.g. a one-off expand/collapse toggle for a section already fully
/// visible on open).
///
/// Renders with no inset of its own — like [D3List], padding is the
/// caller's responsibility via [padding], since whether this sits
/// directly in an unpadded scrollable or inside a already-padded one
/// varies per call site and only the caller knows which.
///
/// ```dart
/// // Sits directly in an unpadded CustomScrollView — supplies its own inset.
/// D3StickyHeader(
///   child: D3SectionHeader(
///     label: 'Visits',
///     count: visits.length,
///     padding: const EdgeInsets.symmetric(horizontal: D3Spacing.s16),
///     trailingIcon: Icons.add_circle,
///     onTrailingTap: _addVisit,
///   ),
/// )
///
/// // Sits inside a ListView that already applies its own padding.
/// D3SectionHeader(
///   label: 'Checklist',
///   count: items.length,
///   trailingIcon: allExpanded ? Icons.unfold_less : Icons.unfold_more,
///   trailingSemanticsLabel: 'Expand or collapse all',
///   onTrailingTap: _toggleAll,
/// )
/// ```
class D3SectionHeader extends StatelessWidget {
  const D3SectionHeader({
    super.key,
    required this.label,
    required this.count,
    this.trailingIcon,
    this.trailingIconColor,
    this.trailingSemanticsLabel,
    this.onTrailingTap,
    this.padding = const EdgeInsets.symmetric(vertical: D3Spacing.s8),
  });

  /// Section name, e.g. "Visits" — rendered as "Visits ($count)".
  final String label;
  final int count;

  /// Icon for the single trailing action. Omit (with [onTrailingTap]
  /// also null) for a label-only header with no action.
  final IconData? trailingIcon;

  /// Overrides the trailing icon's color. Defaults to
  /// [D3ColorTokens.primary].
  final Color? trailingIconColor;

  /// Accessibility label for the trailing icon button — defaults to
  /// [label] if null, which reads correctly for an "Add" action but
  /// should be overridden for anything else (e.g. "Expand or collapse
  /// all").
  final String? trailingSemanticsLabel;

  final VoidCallback? onTrailingTap;

  /// Padding around the row. No horizontal inset by default — see class
  /// doc. Defaults to a small vertical inset so the whole-row tap target
  /// (and any list separator above/below) doesn't feel cramped.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;

    return Semantics(
      label: trailingSemanticsLabel ?? label,
      child: Padding(
        padding: padding,
        child: Row(
          children: [
            Expanded(
              child: Text(
                '$label ($count)',
                style: Theme.of(context).textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            if (trailingIcon != null && onTrailingTap != null)
              IconButton(
                icon: Icon(
                  trailingIcon,
                  color: trailingIconColor ?? colors.primary,
                ),
                onPressed: onTrailingTap,
              )
            else if (trailingIcon != null)
              Icon(trailingIcon, color: trailingIconColor ?? colors.primary),
          ],
        ),
      ),
    );
  }
}
