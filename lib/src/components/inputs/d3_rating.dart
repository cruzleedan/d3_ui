import 'dart:math' as math;

import 'package:d3_ui/d3_ui.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// A row of stars for showing or choosing a rating.
///
/// With [onChanged] it is an input: tap a star to set it, or drag across the
/// stars to scrub. Each star has a 48dp wide touch area (so five stars are
/// 240dp wide), and the left and right arrow keys step the value. Tapping the
/// current value again keeps it unless [allowClear] is true. Screen readers get
/// one adjustable value such as "3 of 5 stars" with increase and decrease
/// actions.
///
/// With `onChanged: null` it is a read-only display. Values are drawn to the
/// nearest half star. Set [compact] to pack display stars tightly, for example
/// in a list row.
///
/// Filled stars use `context.d3Status.ratingStar`, lifted to 3:1 against the
/// surface. Empty stars are outlined. A changed star pops briefly unless the
/// system asks for reduced motion.
///
/// ```dart
/// D3Rating(
///   value: _stars,
///   label: 'Rate this dish',
///   showValue: true,
///   allowHalf: true,
///   onChanged: (v) => setState(() => _stars = v),
/// )
/// ```
class D3Rating extends StatefulWidget {
  const D3Rating({
    super.key,
    required this.value,
    this.onChanged,
    this.max = 5,
    this.allowHalf = false,
    this.allowClear = false,
    this.size = 28,
    this.label,
    this.showValue = false,
    this.color,
    this.enabled = true,
    this.compact = false,
  }) : assert(max > 0),
       assert(size > 0);

  /// The rating, from 0 to [max].
  final double value;

  /// Called with the new rating. Null makes the widget a read-only display.
  final ValueChanged<double>? onChanged;

  /// How many stars there are.
  final int max;

  /// Lets the user pick half stars. A read-only display always shows halves.
  final bool allowHalf;

  /// Lets a tap on the current value (or a drag to the left edge) set 0.
  final bool allowClear;

  /// Star icon size in dp. The touch area is at least 48dp wide regardless.
  final double size;

  /// Names the rating for screen readers, for example "Rate this dish".
  final String? label;

  /// Shows the number, such as "4.5", after the stars.
  final bool showValue;

  /// Filled star colour. Defaults to `context.d3Status.ratingStar`.
  final Color? color;

  final bool enabled;

  /// For display only: places stars [size] plus a small gap apart instead of
  /// giving each a 48dp touch area. Ignored when [onChanged] is set.
  final bool compact;

  bool get _interactive => enabled && onChanged != null;

  @override
  State<D3Rating> createState() => _D3RatingState();
}

class _D3RatingState extends State<D3Rating>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: D3Motion.base,
  );
  int _popIndex = -1;
  bool _focused = false;
  double _slotWidth = 48;
  bool _rtl = false;

  double get _step => widget.allowHalf ? 0.5 : 1;

  /// The value as drawn: halves for display, steps for input.
  double get _shown {
    final v = widget.value.clamp(0, widget.max).toDouble();
    final step = widget.onChanged == null || widget.allowHalf ? 0.5 : 1.0;
    return (v / step).round() * step;
  }

  @override
  void didUpdateWidget(D3Rating old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value && widget.value > 0) {
      _popIndex = (widget.value.ceil() - 1).clamp(0, widget.max - 1);
      if (!MediaQuery.disableAnimationsOf(context)) {
        _pop.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  void _set(double next) {
    final lowest = widget.allowClear ? 0.0 : _step;
    next = next.clamp(lowest, widget.max.toDouble()).toDouble();
    if (next == _shown) return;
    HapticFeedback.selectionClick();
    widget.onChanged!(next);
  }

  /// Rating for a horizontal offset inside the row.
  double _valueAt(double dx, double rowWidth) {
    final x = _rtl ? rowWidth - dx : dx;
    final raw = x / _slotWidth;
    return (raw / _step).ceil() * _step;
  }

  void _tapAt(double dx, double rowWidth) {
    final next = _valueAt(dx, rowWidth);
    if (widget.allowClear && next == _shown) {
      HapticFeedback.selectionClick();
      widget.onChanged!(0);
      return;
    }
    _set(next);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent || !widget._interactive) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    final forward = _rtl
        ? LogicalKeyboardKey.arrowLeft
        : LogicalKeyboardKey.arrowRight;
    final back = _rtl
        ? LogicalKeyboardKey.arrowRight
        : LogicalKeyboardKey.arrowLeft;
    if (key == forward || key == LogicalKeyboardKey.arrowUp) {
      _set(_shown + _step);
    } else if (key == back || key == LogicalKeyboardKey.arrowDown) {
      _set(_shown - _step);
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  static String _fmt(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    final interactive = widget._interactive;
    final dim = context.d3ButtonTokens.disabledOpacity;
    _rtl = Directionality.of(context) == TextDirection.rtl;

    final filled = d3EnsureContrast(
      widget.color ?? context.d3Status.ratingStar,
      colors.surface,
      minRatio: 3,
    );
    final empty = d3EnsureContrast(colors.outline, colors.surface, minRatio: 3);

    final wide = !widget.compact || widget.onChanged != null;
    _slotWidth = wide
        ? math.max(kMinInteractiveDimension, widget.size)
        : widget.size + D3Spacing.s4;
    final slotHeight = wide
        ? math.max(kMinInteractiveDimension, widget.size)
        : widget.size;
    final shown = _shown;

    Widget star(int i) {
      final IconData icon;
      final Color color;
      if (shown >= i + 1) {
        icon = Icons.star_rounded;
        color = filled;
      } else if (shown >= i + 0.5) {
        icon = Icons.star_half_rounded;
        color = filled;
      } else {
        icon = Icons.star_outline_rounded;
        color = empty;
      }
      Widget glyph = Icon(icon, size: widget.size, color: color);
      if (shown >= i + 0.5 && shown < i + 1) {
        // The half icon only fills the left half; draw the empty outline
        // beneath so the rest of the star is still visible.
        glyph = Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.star_outline_rounded, size: widget.size, color: empty),
            glyph,
          ],
        );
      }
      glyph = AnimatedBuilder(
        animation: _pop,
        builder: (context, child) {
          final t = i == _popIndex ? _pop.value : 0.0;
          return Transform.scale(
            scale: 1 + 0.25 * math.sin(math.pi * t),
            child: child,
          );
        },
        child: glyph,
      );
      Widget slot = SizedBox(
        width: _slotWidth,
        height: slotHeight,
        child: Center(child: glyph),
      );
      if (interactive) {
        slot = InkResponse(
          onTapUp: (d) {
            final rowDx =
                (_rtl ? widget.max - 1 - i : i) * _slotWidth +
                d.localPosition.dx;
            _tapAt(rowDx, widget.max * _slotWidth);
          },
          radius: math.max(kMinInteractiveDimension, widget.size) / 2,
          highlightShape: BoxShape.circle,
          child: slot,
        );
      }
      return slot;
    }

    Widget row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [for (var i = 0; i < widget.max; i++) star(i)],
    );

    if (interactive) {
      row = Material(
        type: MaterialType.transparency,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragUpdate: (d) {
            final w = widget.max * _slotWidth;
            _set(_valueAt(d.localPosition.dx.clamp(0, w).toDouble(), w));
          },
          onHorizontalDragStart: (d) {
            final w = widget.max * _slotWidth;
            _set(_valueAt(d.localPosition.dx.clamp(0, w).toDouble(), w));
          },
          child: row,
        ),
      );
      row = Focus(
        onFocusChange: (f) => setState(() => _focused = f),
        onKeyEvent: _onKey,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: context.d3Shape.circularMd,
            border: Border.all(
              color: _focused ? colors.primary : const Color(0x00000000),
              width: 2,
            ),
          ),
          child: row,
        ),
      );
    }

    final valueText = widget.showValue
        ? Padding(
            padding: const EdgeInsetsDirectional.only(start: D3Spacing.s8),
            child: Text(
              _fmt(shown),
              style: TextStyle(
                fontSize: D3TypeScale.bodyLgSize,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          )
        : null;

    Widget body = Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [row, ?valueText],
    );

    final step = _step;
    body = Semantics(
      container: true,
      label: widget.label,
      value: '${_fmt(shown)} of ${widget.max} stars',
      enabled: widget.enabled,
      slider: interactive,
      increasedValue: interactive && shown < widget.max
          ? '${_fmt(math.min(shown + step, widget.max.toDouble()))} of ${widget.max} stars'
          : null,
      decreasedValue: interactive && shown > (widget.allowClear ? 0 : step)
          ? '${_fmt(shown - step)} of ${widget.max} stars'
          : null,
      onIncrease: interactive && shown < widget.max
          ? () => _set(shown + step)
          : null,
      onDecrease: interactive && shown > (widget.allowClear ? 0 : step)
          ? () => _set(shown - step)
          : null,
      excludeSemantics: true,
      child: body,
    );

    if (!widget.enabled) {
      body = Opacity(
        opacity: dim,
        child: IgnorePointer(child: body),
      );
    }
    return body;
  }
}
