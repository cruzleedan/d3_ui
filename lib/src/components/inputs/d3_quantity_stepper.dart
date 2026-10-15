import 'dart:async';
import 'dart:math' as math;

import 'package:d3_ui/d3_ui.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// A minus, value, plus control for choosing a whole quantity.
///
/// Each button has a 48dp touch area even though it looks smaller. Press and
/// hold a button to repeat; the repeat speeds up and stops at [min] or [max].
/// A button that cannot move any further is dimmed but still announced.
/// Screen readers get one adjustable value with increase and decrease actions.
///
/// Pass `onChanged: null` or `enabled: false` to disable it.
///
/// ```dart
/// D3QuantityStepper(
///   value: _qty,
///   min: 1,
///   max: 10,
///   label: 'Quantity',
///   onChanged: (v) => setState(() => _qty = v),
/// )
/// ```
class D3QuantityStepper extends StatefulWidget {
  const D3QuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max,
    this.step = 1,
    this.label,
    this.showLabel = false,
    this.enabled = true,
    this.compact = false,
  }) : assert(step > 0),
       assert(max == null || max >= min);

  final int value;

  /// Called with the new value. Null disables the stepper.
  final ValueChanged<int>? onChanged;

  final int min;

  /// Upper limit. Null for no limit.
  final int? max;

  /// How much one tap adds or removes.
  final int step;

  /// Names the control for screen readers, for example "Quantity".
  final String? label;

  /// Also shows [label] to the left of the control.
  final bool showLabel;

  final bool enabled;

  /// A smaller control for dense lists. The touch areas stay 48dp.
  final bool compact;

  bool get _enabled => enabled && onChanged != null;

  @override
  State<D3QuantityStepper> createState() => _D3QuantityStepperState();
}

class _D3QuantityStepperState extends State<D3QuantityStepper> {
  int _direction = 1;

  bool get _canDecrease => widget._enabled && widget.value > widget.min;
  bool get _canIncrease =>
      widget._enabled && (widget.max == null || widget.value < widget.max!);

  /// Applies one step. Returns whether another step in the same direction is
  /// still possible.
  bool _stepBy(int sign) {
    if (sign > 0 ? !_canIncrease : !_canDecrease) return false;
    final next = _clampedAfter(sign);
    if (next == widget.value) return false;
    _direction = sign;
    HapticFeedback.selectionClick();
    widget.onChanged!(next);
    final more = sign > 0
        ? (widget.max == null || next < widget.max!)
        : next > widget.min;
    return more;
  }

  int _clampedAfter(int sign) {
    var v = widget.value + sign * widget.step;
    if (widget.max != null) v = math.min(v, widget.max!);
    return math.max(v, widget.min);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent || !widget._enabled) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowUp ||
        key == LogicalKeyboardKey.arrowRight) {
      _stepBy(1);
    } else if (key == LogicalKeyboardKey.arrowDown ||
        key == LogicalKeyboardKey.arrowLeft) {
      _stepBy(-1);
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    final reduced = MediaQuery.disableAnimationsOf(context);
    final compact = widget.compact;
    final enabled = widget._enabled;
    final border = d3EnsureContrast(
      colors.outline,
      colors.surface,
      minRatio: 3,
    );
    final iconColor = d3EnsureContrast(colors.onSurface, colors.surface);
    final dim = context.d3ButtonTokens.disabledOpacity;
    final fontSize = compact ? D3TypeScale.bodyMdSize : D3TypeScale.bodyLgSize;
    final vMargin = compact ? 10.0 : 6.0;
    const tabular = [FontFeature.tabularFigures()];

    Widget valueText = ClipRect(
      child: AnimatedSwitcher(
        duration: reduced ? Duration.zero : D3Motion.base,
        switchInCurve: D3Motion.decelerate,
        switchOutCurve: D3Motion.accelerate,
        transitionBuilder: (child, animation) {
          final incoming = child.key == ValueKey<int>(widget.value);
          final dy = (incoming ? 0.6 : -0.6) * _direction;
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset(0, dy),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        // The control is a fixed 48 dp pill, so the number stops growing at 1.5x.
        child: KeyedSubtree(
          key: ValueKey<int>(widget.value),
          child: MediaQuery.withClampedTextScaling(
            maxScaleFactor: 1.5,
            child: Text(
              '${widget.value}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
                fontFeatures: tabular,
              ),
            ),
          ),
        ),
      ),
    );
    valueText = ConstrainedBox(
      constraints: BoxConstraints(minWidth: compact ? 28 : 36),
      child: ExcludeSemantics(child: valueText),
    );

    final control = Stack(
      children: [
        Positioned.fill(
          top: vMargin,
          bottom: vMargin,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: context.d3Shape.circularMd,
              border: Border.all(color: border),
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StepButton(
              icon: Icons.remove_rounded,
              semanticsLabel: 'Decrease',
              enabled: _canDecrease,
              dimmedOpacity: dim,
              color: iconColor,
              iconSize: compact ? 18 : 20,
              rippleRadius: compact ? 14 : 18,
              onStep: () => _stepBy(-1),
            ),
            valueText,
            _StepButton(
              icon: Icons.add_rounded,
              semanticsLabel: 'Increase',
              enabled: _canIncrease,
              dimmedOpacity: dim,
              color: iconColor,
              iconSize: compact ? 18 : 20,
              rippleRadius: compact ? 14 : 18,
              onStep: () => _stepBy(1),
            ),
          ],
        ),
      ],
    );

    Widget body = control;
    if (widget.showLabel && widget.label != null) {
      body = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              widget.label!,
              style: TextStyle(
                fontSize: D3TypeScale.bodyMdSize,
                color: colors.onSurface,
              ),
            ),
          ),
          const SizedBox(width: D3Spacing.s12),
          control,
        ],
      );
    }

    body = Focus(
      canRequestFocus: false,
      onKeyEvent: _onKey,
      child: Semantics(
        container: true,
        label: widget.label,
        value: '${widget.value}',
        enabled: enabled,
        increasedValue: _canIncrease ? '${_clampedAfter(1)}' : null,
        decreasedValue: _canDecrease ? '${_clampedAfter(-1)}' : null,
        onIncrease: _canIncrease ? () => _stepBy(1) : null,
        onDecrease: _canDecrease ? () => _stepBy(-1) : null,
        child: body,
      ),
    );

    if (!enabled) {
      body = Opacity(
        opacity: dim,
        child: IgnorePointer(child: body),
      );
    }
    return body;
  }
}

/// One 48x48 button with ink, press-and-hold repeat and its own semantics.
class _StepButton extends StatefulWidget {
  const _StepButton({
    required this.icon,
    required this.semanticsLabel,
    required this.enabled,
    required this.dimmedOpacity,
    required this.color,
    required this.iconSize,
    required this.rippleRadius,
    required this.onStep,
  });

  final IconData icon;
  final String semanticsLabel;
  final bool enabled;
  final double dimmedOpacity;
  final Color color;
  final double iconSize;

  /// Half the visible pill height, so the ripple stays inside the pill.
  final double rippleRadius;

  /// Performs one step; returns whether more steps are possible.
  final bool Function() onStep;

  @override
  State<_StepButton> createState() => _StepButtonState();
}

class _StepButtonState extends State<_StepButton> {
  static const _holdDelay = Duration(milliseconds: 400);
  static const _firstInterval = 220;
  static const _minInterval = 45;

  Timer? _timer;
  bool _repeated = false;
  int _interval = _firstInterval;

  void _down(PointerDownEvent _) {
    _repeated = false;
    _interval = _firstInterval;
    _cancel();
    if (!widget.enabled) return;
    _timer = Timer(_holdDelay, _tick);
  }

  void _tick() {
    _repeated = true;
    if (!mounted || !widget.onStep()) {
      _cancel();
      return;
    }
    _interval = math.max(_minInterval, (_interval * 0.85).round());
    _timer = Timer(Duration(milliseconds: _interval), _tick);
  }

  void _cancel() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final icon = Icon(widget.icon, size: widget.iconSize, color: widget.color);
    return Semantics(
      button: true,
      enabled: widget.enabled,
      label: widget.semanticsLabel,
      excludeSemantics: true,
      onTap: widget.enabled ? () => widget.onStep() : null,
      child: Listener(
        onPointerDown: _down,
        onPointerUp: (_) => _cancel(),
        onPointerCancel: (_) => _cancel(),
        child: Material(
          type: MaterialType.transparency,
          child: InkResponse(
            onTap: widget.enabled
                ? () {
                    if (!_repeated) widget.onStep();
                  }
                : null,
            radius: widget.rippleRadius,
            highlightShape: BoxShape.circle,
            child: SizedBox(
              width: kMinInteractiveDimension,
              height: kMinInteractiveDimension,
              child: Center(
                child: widget.enabled
                    ? icon
                    : Opacity(opacity: widget.dimmedOpacity, child: icon),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
