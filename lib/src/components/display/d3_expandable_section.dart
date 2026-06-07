import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:d3_ui/d3_ui.dart';

// ─────────────────────────────────────────────────────────────────────────────
// D3ExpandableSection
// ─────────────────────────────────────────────────────────────────────────────

/// A section that can be expanded or collapsed by tapping its header.
///
/// The header row always shows [title] and an animated chevron. The [child]
/// slides in/out with a size transition when toggled.
///
/// ```dart
/// // Uncontrolled — manages its own open/closed state.
/// D3ExpandableSection(
///   title: 'Details',
///   child: Text('Some extra information here.'),
/// )
///
/// // Controlled — driven by external state.
/// D3ExpandableSection(
///   title: 'Details',
///   isExpanded: _open,
///   onToggle: (open) => setState(() => _open = open),
///   child: Text('Controlled content.'),
/// )
/// ```
class D3ExpandableSection extends StatefulWidget {
  const D3ExpandableSection({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.leading,
    this.initiallyExpanded = false,
    this.isExpanded,
    this.onToggle,
    this.padding,
  });

  /// Header title text.
  final String title;

  /// Optional subtitle shown below the title in the header.
  final String? subtitle;

  /// Optional widget shown before the title (e.g. an icon).
  final Widget? leading;

  /// The content revealed when expanded.
  final Widget child;

  /// Whether the section starts expanded. Ignored when [isExpanded] is set.
  final bool initiallyExpanded;

  /// Controlled open state. When non-null the widget is fully controlled:
  /// it does not maintain its own state and calls [onToggle] on each tap.
  final bool? isExpanded;

  /// Called when the user taps the header. The argument is the requested new
  /// state (`true` = open). Only fires when [isExpanded] is set.
  final ValueChanged<bool>? onToggle;

  /// Padding applied around the [child] when expanded.
  /// Defaults to `EdgeInsets.fromLTRB(16, 0, 16, 16)`.
  final EdgeInsetsGeometry? padding;

  @override
  State<D3ExpandableSection> createState() => _D3ExpandableSectionState();
}

class _D3ExpandableSectionState extends State<D3ExpandableSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sizeFactor;
  late bool _internalOpen;

  bool get _open => widget.isExpanded ?? _internalOpen;

  @override
  void initState() {
    super.initState();
    _internalOpen = widget.initiallyExpanded;
    _controller = AnimationController(
      vsync: this,
      duration: D3Motion.base,
      value: _open ? 1.0 : 0.0,
    );
    _sizeFactor = CurvedAnimation(
      parent: _controller,
      curve: D3Motion.standard,
      reverseCurve: D3Motion.standard,
    );
  }

  @override
  void didUpdateWidget(D3ExpandableSection old) {
    super.didUpdateWidget(old);
    if (widget.isExpanded != null && widget.isExpanded != old.isExpanded) {
      widget.isExpanded! ? _controller.forward() : _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.selectionClick();
    final next = !_open;
    if (widget.isExpanded != null) {
      widget.onToggle?.call(next);
    } else {
      setState(() => _internalOpen = next);
      next ? _controller.forward() : _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Header row ────────────────────────────────────────────────────────
        InkWell(
          onTap: _handleTap,
          splashColor: colors.primary.withValues(alpha: 0.06),
          highlightColor: colors.primary.withValues(alpha: 0.03),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: D3Spacing.s16,
              vertical: D3Spacing.s12,
            ),
            child: Row(
              children: [
                if (widget.leading != null) ...[
                  widget.leading!,
                  const SizedBox(width: D3Spacing.s12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: colors.onSurface,
                          height: 1.3,
                        ),
                      ),
                      if (widget.subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle!,
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: _open ? 0.5 : 0.0,
                  duration: D3Motion.base,
                  curve: D3Motion.standard,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Expandable content ────────────────────────────────────────────────
        SizeTransition(
          sizeFactor: _sizeFactor,
          alignment: Alignment.topCenter,
          child: Padding(
            padding: widget.padding ??
                const EdgeInsets.fromLTRB(
                  D3Spacing.s16,
                  0,
                  D3Spacing.s16,
                  D3Spacing.s16,
                ),
            child: widget.child,
          ),
        ),
      ],
    );
  }
}
