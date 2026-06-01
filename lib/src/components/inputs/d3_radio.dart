import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:d3_ui/d3_ui.dart';

// ─────────────────────────────────────────────────────────────────────────────
// D3Radio
// ─────────────────────────────────────────────────────────────────────────────

/// A single radio button aligned with the d3 design system.
///
/// Radio buttons are always used in groups. The caller owns the group state —
/// [D3Radio] never mutates [groupValue] itself.
///
/// Selected when `value == groupValue`. Pass `onChanged: null` to disable.
///
/// ```dart
/// // In a group
/// Column(
///   children: [
///     D3Radio<String>(
///       value: 'light',
///       groupValue: _theme,
///       label: 'Light',
///       onChanged: (v) => setState(() => _theme = v),
///     ),
///     D3Radio<String>(
///       value: 'dark',
///       groupValue: _theme,
///       label: 'Dark',
///       onChanged: (v) => setState(() => _theme = v),
///     ),
///   ],
/// )
/// ```
class D3Radio<T> extends StatefulWidget {
  const D3Radio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.label,
    this.semanticsLabel,
  });

  /// The value this radio button represents.
  final T value;

  /// The currently selected value in the group.
  final T? groupValue;

  /// Called with [value] when this radio is tapped. Null disables it.
  final ValueChanged<T>? onChanged;

  /// Optional label rendered to the right of the button.
  final String? label;

  /// Overrides the semantic label for screen readers.
  final String? semanticsLabel;

  bool get _isSelected => value == groupValue;
  bool get _isDisabled => onChanged == null;

  @override
  State<D3Radio<T>> createState() => _D3RadioState<T>();
}

class _D3RadioState<T> extends State<D3Radio<T>>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      value: widget._isSelected ? 1.0 : 0.0,
    );
    _anim = CurvedAnimation(parent: _controller, curve: D3Motion.standard);
  }

  @override
  void didUpdateWidget(D3Radio<T> old) {
    super.didUpdateWidget(old);
    if (old._isSelected == widget._isSelected) return;
    widget._isSelected ? _controller.forward() : _controller.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget._isDisabled || widget._isSelected) return;
    HapticFeedback.lightImpact();
    widget.onChanged!(widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;

    final button = Semantics(
      label: widget.semanticsLabel ?? widget.label ?? 'Radio button',
      checked: widget._isSelected,
      enabled: !widget._isDisabled,
      inMutuallyExclusiveGroup: true,
      child: GestureDetector(
        onTap: _handleTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: AnimatedOpacity(
              opacity: widget._isDisabled ? 0.35 : 1.0,
              duration: D3Motion.base,
              child: AnimatedBuilder(
                animation: _anim,
                builder: (context, _) => CustomPaint(
                  size: const Size(22, 22),
                  painter: _RadioPainter(
                    progress: _anim.value,
                    primaryColor: colors.primary,
                    // Use onSurfaceVariant at full opacity — visible on both
                    // light (neutral400 #64748B) and dark (neutral300 #94A3B8)
                    // surfaces. The outer opacity wrapper handles disabled dimming,
                    // so we don't pre-multiply alpha here.
                    borderColor: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (widget.label == null) return button;

    return GestureDetector(
      onTap: _handleTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          button,
          const SizedBox(width: 2),
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: D3TypeScale.bodyMdSize,
              color: widget._isDisabled
                  ? colors.onSurface.withValues(alpha: 0.35)
                  : colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Painter
// ─────────────────────────────────────────────────────────────────────────────

class _RadioPainter extends CustomPainter {
  const _RadioPainter({
    required this.progress,
    required this.primaryColor,
    required this.borderColor,
  });

  final double progress;
  final Color primaryColor;
  final Color borderColor;

  static const double _border = 1.5;
  static const double _dotMaxRadius = 5.0; // inner dot at full selection

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final outerRadius = size.width / 2;

    // ── Outer ring ────────────────────────────────────────────────────────
    // Border color transitions from outline → primary as progress increases.
    final ringColor = Color.lerp(borderColor, primaryColor, progress)!;
    canvas.drawCircle(
      center,
      outerRadius - _border / 2,
      Paint()
        ..color = ringColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = _border,
    );

    // ── Inner dot ─────────────────────────────────────────────────────────
    // Scales from 0 to _dotMaxRadius with an overshoot curve for snappiness.
    if (progress <= 0) return;
    final dotRadius = _dotMaxRadius * progress;
    canvas.drawCircle(
      center,
      dotRadius,
      Paint()..color = primaryColor.withValues(alpha: progress),
    );
  }

  @override
  bool shouldRepaint(_RadioPainter old) =>
      old.progress != progress ||
      old.primaryColor != primaryColor ||
      old.borderColor != borderColor;
}
