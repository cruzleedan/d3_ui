import 'package:d3_ui/d3_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────────────────
// D3Checkbox
// ─────────────────────────────────────────────────────────────────────────────

/// A three-state checkbox aligned with the d3 design system.
///
/// [value] controls the visual state:
/// - `true`  → checked (filled box + animated checkmark)
/// - `false` → unchecked (empty box with border)
/// - `null`  → indeterminate (filled box + dash)
///
/// Pass `onChanged: null` to disable. The widget never mutates state itself —
/// call [onChanged] from the parent.
///
/// ```dart
/// // Two-state
/// D3Checkbox(
///   value: _checked,
///   onChanged: (v) => setState(() => _checked = v!),
/// )
///
/// // Three-state (select-all pattern)
/// D3Checkbox(
///   value: _allSelected ? true : _someSelected ? null : false,
///   onChanged: (_) => setState(() => _toggleAll()),
/// )
///
/// // Disabled
/// D3Checkbox(value: true, onChanged: null)
/// ```
class D3Checkbox extends StatefulWidget {
  const D3Checkbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.semanticsLabel,
  });

  /// `true` = checked, `false` = unchecked, `null` = indeterminate.
  final bool? value;

  /// Called with `true` or `false` when tapped. `null` disables the widget.
  /// Indeterminate → tapped → always calls `onChanged(true)`.
  final ValueChanged<bool>? onChanged;

  /// Optional label rendered to the right of the box.
  final String? label;

  /// Overrides the semantic label for screen readers.
  final String? semanticsLabel;

  bool get _isDisabled => onChanged == null;

  @override
  State<D3Checkbox> createState() => _D3CheckboxState();
}

class _D3CheckboxState extends State<D3Checkbox>
    with SingleTickerProviderStateMixin {
  // Single controller drives both the fill and the icon draw.
  // 0.0 = unchecked, 1.0 = checked or indeterminate.
  late final AnimationController _controller;

  // Curved animations derived from the same controller.
  late final Animation<double> _fillAnim; // box background + border
  late final Animation<double>
      _iconAnim; // icon draw progress (leads fill slightly)

  // Tracks the previous value to decide animation direction.
  bool? _previousValue;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      value: widget.value != false ? 1.0 : 0.0,
    );

    _fillAnim = CurvedAnimation(
      parent: _controller,
      curve: D3Motion.standard,
    );

    // Icon draws in on a slightly delayed interval so the fill leads.
    _iconAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.15, 1.0, curve: Curves.easeOut),
    );

    _previousValue = widget.value;
  }

  @override
  void didUpdateWidget(D3Checkbox old) {
    super.didUpdateWidget(old);
    if (old.value == widget.value) return;

    final wasActive = old.value != false;
    final isActive = widget.value != false;

    if (isActive && !wasActive) {
      _controller.forward();
    } else if (!isActive && wasActive) {
      _controller.reverse();
    }
    // indeterminate ↔ checked: both have value != false, controller stays at 1.0.

    _previousValue = widget.value;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget._isDisabled) return;
    HapticFeedback.lightImpact();
    // indeterminate and unchecked both resolve to true on tap.
    widget.onChanged!(widget.value == true ? false : true);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;

    final box = Semantics(
      label: widget.semanticsLabel ?? widget.label ?? 'Checkbox',
      checked: widget.value == true,
      enabled: !widget._isDisabled,
      child: GestureDetector(
        onTap: widget._isDisabled ? null : _handleTap,
        // 44×44dp minimum tap area per HIG / Material.
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: AnimatedOpacity(
              opacity: widget._isDisabled ? 0.35 : 1.0,
              duration: D3Motion.base,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => CustomPaint(
                  size: const Size(22, 22),
                  painter: _CheckboxPainter(
                    fillProgress: _fillAnim.value,
                    iconProgress: _iconAnim.value,
                    isIndeterminate: widget.value == null,
                    primaryColor: colors.primary,
                    borderColor: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (widget.label == null) return box;

    return GestureDetector(
      onTap: widget._isDisabled ? null : _handleTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          box,
          // The box already has 44dp tap area; close the gap visually.
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

class _CheckboxPainter extends CustomPainter {
  const _CheckboxPainter({
    required this.fillProgress,
    required this.iconProgress,
    required this.isIndeterminate,
    required this.primaryColor,
    required this.borderColor,
  });

  final double fillProgress;
  final double iconProgress;
  final bool isIndeterminate;
  final Color primaryColor;
  final Color borderColor;

  static const double _radius = 6.0;
  static const double _border = 1.5;
  static const double _iconStroke = 1.8;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(_radius));

    // ── Box fill ───────────────────────────────────────────────────────────
    final fillColor =
        Color.lerp(Colors.transparent, primaryColor, fillProgress)!;
    canvas.drawRRect(rrect, Paint()..color = fillColor);

    // ── Border ────────────────────────────────────────────────────────────
    // Fades from visible (unchecked) to transparent (checked) as fill grows.
    final borderOpacity = (1.0 - fillProgress).clamp(0.0, 1.0);
    if (borderOpacity > 0) {
      canvas.drawRRect(
        rrect.deflate(_border / 2),
        Paint()
          ..color = borderColor.withValues(alpha: borderColor.a * borderOpacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = _border,
      );
    }

    // ── Icon ──────────────────────────────────────────────────────────────
    if (iconProgress <= 0) return;

    final iconPaint = Paint()
      ..color = Colors.white.withValues(alpha: iconProgress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = _iconStroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (isIndeterminate) {
      _drawDash(canvas, size, iconPaint, iconProgress);
    } else {
      _drawCheck(canvas, size, iconPaint, iconProgress);
    }
  }

  // Dash: horizontal line centered in the box.
  void _drawDash(Canvas canvas, Size size, Paint paint, double progress) {
    const dashW = 12.0;
    const dashH = 2.0;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final half = (dashW / 2) * progress;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy), width: half * 2, height: dashH),
        const Radius.circular(1),
      ),
      paint..style = PaintingStyle.fill,
    );
  }

  // Checkmark: two-segment polyline drawn progressively.
  // Segment 1: top-left corner to the elbow (~40% of total path).
  // Segment 2: elbow to top-right corner (~60% of total path).
  void _drawCheck(Canvas canvas, Size size, Paint paint, double progress) {
    // Control points (relative to 22×22 box).
    // p0 starts at ~18% from left — safely outside the 6dp corner radius (≈27%).
    // seg1Frac derived from actual Euclidean lengths: s1≈6.9dp, s2≈13.7dp → 0.33.
    final p0 = Offset(size.width * 0.18, size.height * 0.50); // start
    final p1 = Offset(size.width * 0.40, size.height * 0.72); // elbow
    final p2 = Offset(size.width * 0.82, size.height * 0.26); // end

    const seg1Frac = 0.33; // fraction of total path length for segment 1

    if (progress <= seg1Frac) {
      // Drawing segment 1 only.
      final t = progress / seg1Frac;
      final mid = Offset.lerp(p0, p1, t)!;
      canvas.drawLine(p0, mid, paint);
    } else {
      // Segment 1 complete, drawing segment 2.
      final t = (progress - seg1Frac) / (1.0 - seg1Frac);
      final mid = Offset.lerp(p1, p2, t)!;
      canvas.drawLine(p0, p1, paint);
      canvas.drawLine(p1, mid, paint);
    }
  }

  @override
  bool shouldRepaint(_CheckboxPainter old) =>
      old.fillProgress != fillProgress ||
      old.iconProgress != iconProgress ||
      old.isIndeterminate != isIndeterminate ||
      old.primaryColor != primaryColor ||
      old.borderColor != borderColor;
}
