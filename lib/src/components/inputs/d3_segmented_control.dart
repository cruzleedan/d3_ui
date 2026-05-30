import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:d3_ui/d3_ui.dart';

// ─────────────────────────────────────────────────────────────────────────────
// D3Segment
// ─────────────────────────────────────────────────────────────────────────────

/// A single option in a [D3SegmentedControl].
///
/// At least one of [label] or [icon] must be provided.
class D3Segment<T> {
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
/// The active segment slides a white pill indicator under the selection.
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
class D3SegmentedControl<T> extends StatefulWidget {
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

  /// The value of the currently selected segment.
  final T selected;

  /// Called with the value of the tapped segment.
  final ValueChanged<T> onChanged;

  /// When true the control stretches to fill its parent's width, with each
  /// segment taking equal space.
  final bool expand;

  @override
  State<D3SegmentedControl<T>> createState() => _D3SegmentedControlState<T>();
}

class _D3SegmentedControlState<T> extends State<D3SegmentedControl<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _position;

  int _previousIndex = 0;

  int get _selectedIndex =>
      widget.segments.indexWhere((s) => s.value == widget.selected);

  @override
  void initState() {
    super.initState();
    _previousIndex = _selectedIndex;
    _controller = AnimationController(
      vsync: this,
      duration: D3Motion.fast,
    );
    _position = Tween<double>(
      begin: _selectedIndex.toDouble(),
      end: _selectedIndex.toDouble(),
    ).animate(CurvedAnimation(parent: _controller, curve: D3Motion.standard));
  }

  @override
  void didUpdateWidget(D3SegmentedControl<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newIndex = _selectedIndex;
    final oldIndex =
        oldWidget.segments.indexWhere((s) => s.value == oldWidget.selected);
    if (oldIndex != newIndex) {
      _position = Tween<double>(
        begin: _previousIndex.toDouble(),
        end: newIndex.toDouble(),
      ).animate(
        CurvedAnimation(parent: _controller, curve: D3Motion.standard),
      );
      _previousIndex = newIndex;
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap(int index) {
    if (index == _selectedIndex) return;
    HapticFeedback.selectionClick();
    widget.onChanged(widget.segments[index].value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;

    Widget track = AnimatedBuilder(
      animation: _position,
      builder: (context, _) {
        return _SegmentTrack(
          segments: widget.segments,
          selectedIndex: _selectedIndex,
          animatedPosition: _position.value,
          colors: colors,
          onTap: _onTap,
        );
      },
    );

    if (widget.expand) {
      track = SizedBox(width: double.infinity, child: track);
    }

    return track;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Track layout via CustomMultiChildLayout
// ─────────────────────────────────────────────────────────────────────────────

class _SegmentTrack extends StatelessWidget {
  const _SegmentTrack({
    required this.segments,
    required this.selectedIndex,
    required this.animatedPosition,
    required this.colors,
    required this.onTap,
  });

  final List<D3Segment<Object?>> segments;
  final int selectedIndex;
  final double animatedPosition;
  final D3ColorTokens colors;
  final ValueChanged<int> onTap;

  static const double _trackPadding = 3.0;
  static const double _pillRadius = 8.0;

  @override
  Widget build(BuildContext context) {
    final count = segments.length;

    return Container(
      padding: const EdgeInsets.all(_trackPadding),
      decoration: BoxDecoration(
        color: colors.onSurface.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(D3Radius.sm + _trackPadding),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          // Each segment gets equal space minus the shared padding.
          final segWidth = (totalWidth - _trackPadding * 2) / count -
              _trackPadding * (count - 1) / count;
          // Pill x offset interpolated from animated position.
          final pillLeft = animatedPosition * (segWidth + _trackPadding);

          return SizedBox(
            height: 34,
            child: Stack(
              children: [
                // ── Animated pill ─────────────────────────────────────────────
                Positioned(
                  left: pillLeft,
                  top: 0,
                  bottom: 0,
                  width: segWidth,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(_pillRadius),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.10),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Segment tap targets ────────────────────────────────────────
                Row(
                  children: [
                    for (int i = 0; i < count; i++) ...[
                      if (i > 0) SizedBox(width: _trackPadding),
                      Expanded(
                        child: _SegmentItem(
                          segment: segments[i],
                          isSelected: i == selectedIndex,
                          colors: colors,
                          onTap: () => onTap(i),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual segment
// ─────────────────────────────────────────────────────────────────────────────

class _SegmentItem extends StatelessWidget {
  const _SegmentItem({
    required this.segment,
    required this.isSelected,
    required this.colors,
    required this.onTap,
  });

  final D3Segment<Object?> segment;
  final bool isSelected;
  final D3ColorTokens colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final labelColor = isSelected ? colors.onSurface : colors.onSurfaceVariant;

    Widget inner = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (segment.icon != null)
          Icon(
            segment.icon,
            size: 15,
            color: labelColor,
          ),
        if (segment.icon != null && segment.label != null)
          const SizedBox(width: 5),
        if (segment.label != null)
          Text(
            segment.label!,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: labelColor,
              height: 1,
            ),
          ),
      ],
    );

    return Semantics(
      label: segment.semanticsLabel ?? segment.label,
      button: true,
      selected: isSelected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          height: double.infinity,
          child: Center(child: inner),
        ),
      ),
    );
  }
}
