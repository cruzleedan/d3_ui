import 'dart:math' as math;

import 'package:d3_ui/d3_ui.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// A single-value slider built for thumbs.
///
/// The thumb is 24dp wide but the whole 48dp-tall row is the drag area, and
/// tapping the track jumps there. Give it [divisions] for discrete steps (with
/// small tick marks and a haptic tick on each one). A bubble shows the value
/// while dragging, unless animations are disabled. Arrow keys, Home/End and
/// the screen-reader increase/decrease actions all work.
///
/// Pass `onChanged: null` or `enabled: false` to disable it.
///
/// ```dart
/// D3Slider(
///   value: _volume,
///   onChanged: (v) => setState(() => _volume = v),
///   label: 'Volume',
///   showValue: true,
/// )
///
/// // Steps
/// D3Slider(
///   value: _size,
///   min: 1,
///   max: 5,
///   divisions: 4,
///   label: 'Text size',
///   showValue: true,
///   onChanged: (v) => setState(() => _size = v),
/// )
/// ```
class D3Slider extends StatefulWidget {
  const D3Slider({
    super.key,
    required this.value,
    required this.onChanged,
    this.onChangeEnd,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.label,
    this.showValue = false,
    this.valueLabel,
    this.valueFormatter,
    this.enabled = true,
    this.semanticsLabel,
  }) : assert(max > min),
       assert(divisions == null || divisions > 0);

  /// Current value, between [min] and [max].
  final double value;

  /// Called as the value changes while dragging, tapping or using the keys.
  /// Null disables the slider.
  final ValueChanged<double>? onChanged;

  /// Called once when a drag or tap finishes, with the final value.
  final ValueChanged<double>? onChangeEnd;

  final double min;
  final double max;

  /// Number of equal steps between [min] and [max]. Null for a continuous
  /// slider.
  final int? divisions;

  /// Text above the track, on the left.
  final String? label;

  /// Shows the formatted value above the track, on the right.
  final bool showValue;

  /// Fixed text for the value, instead of formatting [value]. Implies
  /// showing it.
  final String? valueLabel;

  /// Formats [value] for the label, the bubble and screen readers.
  final String Function(double value)? valueFormatter;

  final bool enabled;

  /// Overrides the label read by screen readers.
  final String? semanticsLabel;

  bool get _enabled => enabled && onChanged != null;

  @override
  State<D3Slider> createState() => _D3SliderState();
}

class _D3SliderState extends State<D3Slider> {
  static const double _thumb = 24;
  static const double _area = 48;
  static const double _inset = _area / 2;
  static const double _trackHeight = 6;

  final FocusNode _focus = FocusNode(debugLabel: 'D3Slider');
  bool _dragging = false;
  bool _focused = false;
  late double _latest = widget.value;

  @override
  void didUpdateWidget(D3Slider old) {
    super.didUpdateWidget(old);
    _latest = widget.value;
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  double get _range => widget.max - widget.min;
  double _fraction(double v) => ((v - widget.min) / _range).clamp(0.0, 1.0);

  double _snap(double fraction) {
    final f = fraction.clamp(0.0, 1.0);
    final d = widget.divisions;
    final snapped = d == null ? f : (f * d).round() / d;
    return widget.min + snapped * _range;
  }

  String _format(double v) {
    final custom = widget.valueFormatter;
    if (custom != null) return custom(v);
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(_range <= 1 ? 2 : 1);
  }

  String get _shownValue => widget.valueLabel ?? _format(widget.value);

  /// Moves to [next]; ticks when it lands on a new division.
  void _emit(double next) {
    if (!widget._enabled) return;
    final clamped = next.clamp(widget.min, widget.max);
    if ((clamped - _latest).abs() < 1e-9) return;
    _latest = clamped;
    if (widget.divisions != null) HapticFeedback.selectionClick();
    widget.onChanged?.call(clamped);
  }

  double _step() => _range / (widget.divisions ?? 20);

  void _nudge(double delta) {
    _emit(_snapToStep(widget.value + delta));
    widget.onChangeEnd?.call(_latest);
  }

  double _snapToStep(double v) =>
      widget.divisions == null ? v : _snap(_fraction(v));

  void _fromDx(double dx, double width) {
    final track = math.max(1.0, width - _area);
    _emit(_snap((dx - _inset) / track));
  }

  void _dragStart(DragStartDetails d, double width) {
    if (!widget._enabled) return;
    _focus.requestFocus();
    setState(() => _dragging = true);
    _fromDx(d.localPosition.dx, width);
  }

  void _dragUpdate(DragUpdateDetails d, double width) {
    if (!_dragging) return;
    _fromDx(d.localPosition.dx, width);
  }

  void _dragEnd() {
    if (!_dragging) return;
    setState(() => _dragging = false);
    widget.onChangeEnd?.call(_latest);
  }

  void _tapUp(TapUpDetails d, double width) {
    if (!widget._enabled) return;
    _focus.requestFocus();
    _fromDx(d.localPosition.dx, width);
    widget.onChangeEnd?.call(_latest);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (!widget._enabled || event is KeyUpEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowRight ||
        key == LogicalKeyboardKey.arrowUp) {
      _nudge(_step());
    } else if (key == LogicalKeyboardKey.arrowLeft ||
        key == LogicalKeyboardKey.arrowDown) {
      _nudge(-_step());
    } else if (key == LogicalKeyboardKey.pageUp) {
      _nudge(_range / 10);
    } else if (key == LogicalKeyboardKey.pageDown) {
      _nudge(-_range / 10);
    } else if (key == LogicalKeyboardKey.home) {
      _nudge(widget.min - widget.value);
    } else if (key == LogicalKeyboardKey.end) {
      _nudge(widget.max - widget.value);
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    final reduced = MediaQuery.disableAnimationsOf(context);
    final enabled = widget._enabled;
    final fill = d3EnsureContrast(colors.primary, colors.surface, minRatio: 3);
    final inactive = d3EnsureContrast(
      colors.outline,
      colors.surface,
      minRatio: 3,
    );
    final textColor = d3EnsureContrast(colors.onSurfaceVariant, colors.surface);
    final showHeader =
        widget.label != null || widget.showValue || widget.valueLabel != null;
    final fraction = _fraction(widget.value);

    final upValue = widget.value < widget.max
        ? _format(
            (widget.value + _step()).clamp(widget.min, widget.max).toDouble(),
          )
        : null;
    final downValue = widget.value > widget.min
        ? _format(
            (widget.value - _step()).clamp(widget.min, widget.max).toDouble(),
          )
        : null;

    final header = !showHeader
        ? null
        : Padding(
            padding: const EdgeInsets.only(bottom: D3Spacing.s4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: widget.label == null
                      ? const SizedBox.shrink()
                      : Text(
                          widget.label!,
                          style: TextStyle(
                            fontSize: D3TypeScale.bodyMdSize,
                            color: colors.onSurface,
                          ),
                        ),
                ),
                if (widget.showValue || widget.valueLabel != null)
                  Text(
                    _shownValue,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: D3TypeScale.bodyMdSize,
                      color: textColor,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
              ],
            ),
          );

    final track = LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (d) => _tapUp(d, width),
          onHorizontalDragStart: (d) => _dragStart(d, width),
          onHorizontalDragUpdate: (d) => _dragUpdate(d, width),
          onHorizontalDragEnd: (_) => _dragEnd(),
          onHorizontalDragCancel: _dragEnd,
          child: SizedBox(
            height: _area,
            width: double.infinity,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(end: fraction),
              duration: (_dragging || reduced) ? Duration.zero : D3Motion.fast,
              curve: D3Motion.standard,
              builder: (context, f, _) {
                final x = _inset + f * math.max(0, width - _area);
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: D3SliderPainter(
                          fraction: f,
                          divisions: widget.divisions,
                          fill: fill,
                          inactive: inactive,
                          surface: colors.surface,
                          tick: colors.onSurfaceVariant,
                          halo: (_dragging || _focused) ? fill : null,
                          thumbDiameter: _thumb,
                          trackHeight: _trackHeight,
                          inset: _inset,
                        ),
                      ),
                    ),
                    if (!reduced)
                      Positioned(
                        left: x - 40,
                        width: 80,
                        bottom: _area - 4,
                        child: IgnorePointer(
                          child: AnimatedOpacity(
                            opacity: _dragging ? 1 : 0,
                            duration: D3Motion.fast,
                            child: Center(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: colors.onSurface,
                                  borderRadius: context.d3Shape.circularSm,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: D3Spacing.s10,
                                    vertical: D3Spacing.s4,
                                  ),
                                  child: Text(
                                    _format(widget.value),
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: D3TypeScale.labelLgSize,
                                      fontWeight: FontWeight.w600,
                                      color: colors.surface,
                                      fontFeatures: const [
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );

    Widget body = Focus(
      focusNode: _focus,
      canRequestFocus: enabled,
      onFocusChange: (f) => setState(() => _focused = f),
      onKeyEvent: _onKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [?header, track],
      ),
    );

    body = Semantics(
      container: true,
      slider: true,
      enabled: enabled,
      focusable: enabled,
      focused: _focused,
      label: widget.semanticsLabel ?? widget.label,
      value: _shownValue,
      increasedValue: upValue,
      decreasedValue: downValue,
      onIncrease: enabled && upValue != null ? () => _nudge(_step()) : null,
      onDecrease: enabled && downValue != null ? () => _nudge(-_step()) : null,
      child: ExcludeSemantics(child: body),
    );

    if (!enabled) {
      body = Opacity(
        opacity: context.d3ButtonTokens.disabledOpacity,
        child: IgnorePointer(child: body),
      );
    }
    return body;
  }
}

/// Paints the track, ticks, thumb and focus halo of a [D3Slider].
///
/// Public only so tests can read the resolved colours.
class D3SliderPainter extends CustomPainter {
  D3SliderPainter({
    required this.fraction,
    required this.divisions,
    required this.fill,
    required this.inactive,
    required this.surface,
    required this.tick,
    required this.halo,
    required this.thumbDiameter,
    required this.trackHeight,
    required this.inset,
  });

  final double fraction;
  final int? divisions;
  final Color fill;
  final Color inactive;
  final Color surface;
  final Color tick;
  final Color? halo;
  final double thumbDiameter;
  final double trackHeight;
  final double inset;

  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height / 2;
    final left = inset;
    final span = math.max(0.0, size.width - inset * 2);
    final x = left + fraction * span;
    final radius = Radius.circular(trackHeight / 2);

    // The track runs to the thumb centres so the ends line up with the thumb.
    final full = RRect.fromLTRBR(
      left - trackHeight / 2,
      cy - trackHeight / 2,
      left + span + trackHeight / 2,
      cy + trackHeight / 2,
      radius,
    );
    canvas.drawRRect(full, Paint()..color = inactive);
    canvas.drawRRect(
      RRect.fromLTRBR(
        left - trackHeight / 2,
        cy - trackHeight / 2,
        math.max(left, x),
        cy + trackHeight / 2,
        radius,
      ),
      Paint()..color = fill,
    );

    final d = divisions;
    if (d != null && span / d >= 6) {
      for (var i = 0; i <= d; i++) {
        final tx = left + span * i / d;
        final active = tx <= x + 0.5;
        canvas.drawCircle(
          Offset(tx, cy),
          1.5,
          Paint()
            ..color = active
                ? surface.withValues(alpha: 0.8)
                : tick.withValues(alpha: 0.7),
        );
      }
    }

    if (halo != null) {
      canvas.drawCircle(
        Offset(x, cy),
        thumbDiameter / 2 + 8,
        Paint()..color = halo!.withValues(alpha: 0.2),
      );
    }
    canvas.drawCircle(
      Offset(x, cy),
      thumbDiameter / 2 + 2,
      Paint()..color = surface,
    );
    canvas.drawCircle(Offset(x, cy), thumbDiameter / 2, Paint()..color = fill);
  }

  @override
  bool shouldRepaint(D3SliderPainter old) =>
      old.fraction != fraction ||
      old.divisions != divisions ||
      old.fill != fill ||
      old.inactive != inactive ||
      old.surface != surface ||
      old.tick != tick ||
      old.halo != halo;
}
