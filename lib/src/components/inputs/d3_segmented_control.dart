import 'package:material_ui/material_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:d3_ui/d3_ui.dart';

// ─────────────────────────────────────────────────────────────────────────────
// D3Segment
// ─────────────────────────────────────────────────────────────────────────────

/// A single option in a [D3SegmentedControl].
///
/// At least one of [label] or [icon] must be provided.
class D3Segment<T extends Object> {
  const D3Segment({
    required this.value,
    this.label,
    this.icon,
    this.semanticsLabel,
  }) : assert(
         label != null || icon != null,
         'A D3Segment must have at least a label or an icon.',
       );

  /// The value emitted by [D3SegmentedControl.onChanged] when this segment
  /// is selected.
  final T value;

  /// Text displayed inside the segment.
  final String? label;

  /// Icon displayed inside the segment. Shown to the left of [label] when
  /// both are provided.
  final IconData? icon;

  /// Override for screen-reader label. Falls back to [label] when null.
  final String? semanticsLabel;
}

// ─────────────────────────────────────────────────────────────────────────────
// D3SegmentedControl
// ─────────────────────────────────────────────────────────────────────────────

/// A horizontal row of 2–4 mutually exclusive options.
///
/// The active segment slides under the selection using Flutter's
/// [CupertinoSlidingSegmentedControl] interaction and motion. D3 semantic
/// colors, typography, and spacing define its appearance.
/// Supports text-only, icon-only, and icon+text segments.
///
/// ```dart
/// // Text only
/// D3SegmentedControl(
///   segments: const [
///     D3Segment(label: 'All'),
///     D3Segment(label: 'Active'),
///     D3Segment(label: 'Archived'),
///   ],
///   selectedIndex: _tab,
///   onChanged: (i) => setState(() => _tab = i),
/// )
///
/// // Icon + text, full width
/// D3SegmentedControl(
///   segments: const [
///     D3Segment(label: 'List', icon: Icons.list_rounded),
///     D3Segment(label: 'Grid', icon: Icons.grid_view_rounded),
///     D3Segment(label: 'Map',  icon: Icons.map_outlined),
///   ],
///   selectedIndex: _view,
///   onChanged: (i) => setState(() => _view = i),
///   expand: true,
/// )
///
/// // Icon only
/// D3SegmentedControl(
///   segments: const [
///     D3Segment(icon: Icons.list_rounded,         semanticsLabel: 'List'),
///     D3Segment(icon: Icons.grid_view_rounded,    semanticsLabel: 'Grid'),
///   ],
///   selectedIndex: _view,
///   onChanged: (i) => setState(() => _view = i),
/// )
/// ```
class D3SegmentedControl<T extends Object> extends StatefulWidget {
  const D3SegmentedControl({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
    this.expand = false,
  }) : assert(
         segments.length >= 2 && segments.length <= 4,
         'D3SegmentedControl requires between 2 and 4 segments.',
       );

  final List<D3Segment<T>> segments;

  /// The value of the currently selected segment, or `null` to show no
  /// segment as selected (e.g. a question that hasn't been answered yet).
  /// The pill indicator hides entirely when null; tapping any segment still
  /// calls [onChanged] as usual.
  final T? selected;

  /// Called with the value of the tapped segment.
  final ValueChanged<T> onChanged;

  /// When true the control stretches to fill its parent's width, with each
  /// segment taking equal space. Otherwise, segments use their content width
  /// and the control is centered.
  final bool expand;

  @override
  State<D3SegmentedControl<T>> createState() => _D3SegmentedControlState<T>();
}

class _D3SegmentedControlState<T extends Object>
    extends State<D3SegmentedControl<T>> {
  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    final selected =
        widget.segments.any((segment) => segment.value == widget.selected)
        ? widget.selected
        : null;
    return LayoutBuilder(
      builder: (context, constraints) {
        final segmentWidth = widget.expand && constraints.hasBoundedWidth
            ? (constraints.maxWidth -
                      D3Spacing.s8 -
                      D3Spacing.s2 * (widget.segments.length - 1)) /
                  widget.segments.length
            : null;
        final children = <T, Widget>{
          for (final segment in widget.segments)
            segment.value: _D3SegmentContent(
              segment: segment,
              isSelected: segment.value == selected,
              colors: colors,
              maxLabelWidth: segmentWidth == null
                  ? null
                  : (segmentWidth -
                            D3Spacing.s8 -
                            (segment.icon == null ? 0 : 18 + D3Spacing.s6))
                        .clamp(0.0, double.infinity)
                        .toDouble(),
            ),
        };
        if (segmentWidth != null) {
          for (final segment in widget.segments) {
            children[segment.value] = SizedBox(
              width: segmentWidth,
              child: children[segment.value],
            );
          }
        }

        void onValueChanged(T? value) {
          if (value == null || value == widget.selected) return;
          HapticFeedback.selectionClick();
          widget.onChanged(value);
        }

        final reducedMotion = MediaQuery.disableAnimationsOf(context);
        final control = reducedMotion
            ? CupertinoSegmentedControl<T>(
                groupValue: selected,
                onValueChanged: onValueChanged,
                selectedColor: colors.primaryContainer,
                unselectedColor: colors.surfaceContainerHigh,
                borderColor: colors.outlineVariant,
                pressedColor: colors.surfaceContainer,
                padding: const EdgeInsets.symmetric(
                  horizontal: D3Spacing.s4,
                  vertical: D3Spacing.s2,
                ),
                children: children,
              )
            : CupertinoSlidingSegmentedControl<T>(
                groupValue: selected,
                onValueChanged: onValueChanged,
                backgroundColor: colors.surfaceContainerHigh,
                thumbColor: colors.primaryContainer,
                padding: const EdgeInsets.symmetric(
                  horizontal: D3Spacing.s4,
                  vertical: D3Spacing.s2,
                ),
                proportionalWidth: !widget.expand,
                children: children,
              );

        return widget.expand
            ? SizedBox(width: double.infinity, child: control)
            : Center(child: control);
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual segment
// ─────────────────────────────────────────────────────────────────────────────

class _D3SegmentContent<T extends Object> extends StatelessWidget {
  const _D3SegmentContent({
    required this.segment,
    required this.isSelected,
    required this.colors,
    required this.maxLabelWidth,
  });

  final D3Segment<T> segment;
  final bool isSelected;
  final D3ColorTokens colors;
  final double? maxLabelWidth;

  @override
  Widget build(BuildContext context) {
    final labelColor = isSelected
        ? colors.onPrimaryContainer
        : colors.onSurfaceVariant;
    final content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (segment.icon != null)
          TweenAnimationBuilder<Color?>(
            tween: ColorTween(begin: labelColor, end: labelColor),
            duration: D3Motion.base,
            curve: D3Motion.decelerate,
            builder: (context, color, _) =>
                Icon(segment.icon, size: 18, color: color),
          ),
        if (segment.icon != null && segment.label != null)
          const SizedBox(width: D3Spacing.s6),
        if (segment.label != null)
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxLabelWidth ?? double.infinity,
            ),
            child: Text(
              segment.label!,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );

    return Semantics(
      label: segment.semanticsLabel,
      child: ExcludeSemantics(
        excluding: segment.semanticsLabel != null,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: kMinInteractiveDimension,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: D3Spacing.s4,
              vertical: D3Spacing.s8,
            ),
            child: Center(
              child: AnimatedDefaultTextStyle(
                style:
                    (Theme.of(context).textTheme.labelMedium ??
                            const TextStyle())
                        .copyWith(color: labelColor),
                duration: D3Motion.base,
                curve: D3Motion.decelerate,
                child: content,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
