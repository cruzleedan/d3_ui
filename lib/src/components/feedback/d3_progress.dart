import 'dart:math' as math;

import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Variant
// ─────────────────────────────────────────────────────────────────────────────

/// The colour role of a [D3ProgressBar] or [D3ProgressRing].
enum D3ProgressVariant { primary, success, warning, error }

/// Resolves the fill colour for [variant]: the token colour, nudged just
/// enough to keep 3:1 contrast against both the surface and the track.
Color _fillColor(D3ColorTokens colors, D3ProgressVariant variant, Color track) {
  final base = switch (variant) {
    D3ProgressVariant.primary => colors.primary,
    D3ProgressVariant.success => colors.success,
    D3ProgressVariant.warning => colors.warning,
    D3ProgressVariant.error => colors.error,
  };
  final onSurface = d3EnsureContrast(base, colors.surface, minRatio: 3);
  return d3EnsureContrast(onSurface, track, minRatio: 3);
}

String _percent(double v) => '${(v.clamp(0.0, 1.0) * 100).round()}%';

const _tabular = [FontFeature.tabularFigures()];

/// Shared driver for the looping indeterminate animation. Stopped when the
/// value is determinate or when the platform asks for reduced motion.
mixin _IndeterminateLoop<T extends StatefulWidget> on State<T>
    implements TickerProvider {
  late final AnimationController loop;

  double? get progressValue;
  Duration get loopDuration;

  @override
  void initState() {
    super.initState();
    loop = AnimationController(vsync: this, duration: loopDuration);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(T oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    final animate =
        progressValue == null && !MediaQuery.disableAnimationsOf(context);
    if (animate && !loop.isAnimating) {
      loop.repeat();
    } else if (!animate && loop.isAnimating) {
      loop.stop();
    }
  }

  @override
  void dispose() {
    loop.dispose();
    super.dispose();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// D3ProgressBar
// ─────────────────────────────────────────────────────────────────────────────

/// A linear progress indicator with rounded ends.
///
/// [value] runs from 0 to 1; pass `null` for an indeterminate bar, which
/// shows a moving segment. Determinate changes animate; under reduced motion
/// (`MediaQuery.disableAnimationsOf`) nothing animates and an indeterminate
/// bar shows a still segment.
///
/// ```dart
/// D3ProgressBar(value: 0.4, label: 'Uploading', showValue: true)
///
/// // Indeterminate
/// const D3ProgressBar(value: null, label: 'Loading')
///
/// // Variant
/// D3ProgressBar(value: 0.9, variant: D3ProgressVariant.warning)
/// ```
class D3ProgressBar extends StatefulWidget {
  const D3ProgressBar({
    super.key,
    required this.value,
    this.label,
    this.showValue = false,
    this.thickness = 8,
    this.variant = D3ProgressVariant.primary,
    this.semanticsLabel,
  });

  /// Progress from 0 to 1, or `null` when the amount is unknown.
  final double? value;

  /// Text shown above the bar.
  final String? label;

  /// Shows the percentage above the bar, right-aligned.
  final bool showValue;

  /// Height of the bar in dp.
  final double thickness;

  final D3ProgressVariant variant;

  /// Overrides the label read by screen readers.
  final String? semanticsLabel;

  @override
  State<D3ProgressBar> createState() => _D3ProgressBarState();
}

class _D3ProgressBarState extends State<D3ProgressBar>
    with TickerProviderStateMixin, _IndeterminateLoop<D3ProgressBar> {
  @override
  double? get progressValue => widget.value;

  @override
  Duration get loopDuration => const Duration(milliseconds: 1500);

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    final reduced = MediaQuery.disableAnimationsOf(context);
    final track = colors.surfaceContainerHighest;
    final fill = _fillColor(colors, widget.variant, track);
    final value = widget.value?.clamp(0.0, 1.0);

    final bar = SizedBox(
      height: widget.thickness,
      width: double.infinity,
      child: value == null
          ? AnimatedBuilder(
              animation: loop,
              builder: (context, _) => CustomPaint(
                painter: D3ProgressBarPainter(
                  track: track,
                  fill: fill,
                  fraction: null,
                  phase: reduced ? 0.3 : Curves.easeInOut.transform(loop.value),
                ),
              ),
            )
          : TweenAnimationBuilder<double>(
              tween: Tween<double>(end: value),
              duration: reduced ? Duration.zero : D3Motion.moderate,
              curve: D3Motion.standard,
              builder: (context, v, _) => CustomPaint(
                painter: D3ProgressBarPainter(
                  track: track,
                  fill: fill,
                  fraction: v,
                  phase: 0,
                ),
              ),
            ),
    );

    final hasHeader =
        widget.label != null || (widget.showValue && value != null);
    final textColor = d3EnsureContrast(colors.onSurfaceVariant, colors.surface);

    return Semantics(
      container: true,
      label: widget.semanticsLabel ?? widget.label ?? 'Progress',
      value: value == null ? null : _percent(value),
      child: ExcludeSemantics(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (hasHeader) ...[
              Row(
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
                  if (widget.showValue && value != null)
                    Text(
                      _percent(value),
                      style: TextStyle(
                        fontSize: D3TypeScale.bodyMdSize,
                        color: textColor,
                        fontFeatures: _tabular,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: D3Spacing.s8),
            ],
            bar,
          ],
        ),
      ),
    );
  }
}

/// Paints the track and fill of a [D3ProgressBar].
///
/// Public only so tests can read the resolved colours.
class D3ProgressBarPainter extends CustomPainter {
  D3ProgressBarPainter({
    required this.track,
    required this.fill,
    required this.fraction,
    required this.phase,
  });

  final Color track;
  final Color fill;

  /// 0..1, or null for the indeterminate segment.
  final double? fraction;

  /// Indeterminate position, 0..1.
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = Radius.circular(size.height / 2);
    final trackRect = RRect.fromRectAndRadius(Offset.zero & size, radius);
    canvas.drawRRect(trackRect, Paint()..color = track);

    final paint = Paint()..color = fill;
    if (fraction == null) {
      final segment = size.width * 0.4;
      final left = (phase * 1.4 - 0.4) * size.width;
      canvas.save();
      canvas.clipRRect(trackRect);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, 0, segment, size.height),
          radius,
        ),
        paint,
      );
      canvas.restore();
    } else if (fraction! > 0) {
      final w = math.max(size.height, size.width * fraction!);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, size.height), radius),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(D3ProgressBarPainter old) =>
      old.track != track ||
      old.fill != fill ||
      old.fraction != fraction ||
      old.phase != phase;
}

// ─────────────────────────────────────────────────────────────────────────────
// D3ProgressRing
// ─────────────────────────────────────────────────────────────────────────────

/// A circular progress indicator with rounded ends.
///
/// [value] runs from 0 to 1; pass `null` for an indeterminate ring, which
/// shows a rotating arc. Put your own widget in the centre with [child], or
/// set [showValue] to print the percentage there. Reduced motion
/// (`MediaQuery.disableAnimationsOf`) turns every animation off.
///
/// ```dart
/// D3ProgressRing(value: 0.65, showValue: true, size: 72)
///
/// // Indeterminate
/// const D3ProgressRing(value: null)
///
/// // Custom centre
/// D3ProgressRing(value: 0.3, child: Icon(Icons.download))
/// ```
class D3ProgressRing extends StatefulWidget {
  const D3ProgressRing({
    super.key,
    required this.value,
    this.size = 48,
    this.thickness = 6,
    this.child,
    this.showValue = false,
    this.label,
    this.variant = D3ProgressVariant.primary,
    this.semanticsLabel,
  });

  /// Progress from 0 to 1, or `null` when the amount is unknown.
  final double? value;

  /// Outer diameter in dp.
  final double size;

  /// Stroke width in dp.
  final double thickness;

  /// Widget in the centre. Takes the place of the [showValue] text.
  final Widget? child;

  /// Prints the percentage in the centre when [child] is null.
  final bool showValue;

  /// Text shown below the ring and read by screen readers.
  final String? label;

  final D3ProgressVariant variant;

  /// Overrides the label read by screen readers.
  final String? semanticsLabel;

  @override
  State<D3ProgressRing> createState() => _D3ProgressRingState();
}

class _D3ProgressRingState extends State<D3ProgressRing>
    with TickerProviderStateMixin, _IndeterminateLoop<D3ProgressRing> {
  @override
  double? get progressValue => widget.value;

  @override
  Duration get loopDuration => const Duration(milliseconds: 1200);

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    final reduced = MediaQuery.disableAnimationsOf(context);
    final track = colors.surfaceContainerHighest;
    final fill = _fillColor(colors, widget.variant, track);
    final value = widget.value?.clamp(0.0, 1.0);

    Widget ring;
    if (value == null) {
      ring = AnimatedBuilder(
        animation: loop,
        builder: (context, _) => CustomPaint(
          painter: D3ProgressRingPainter(
            track: track,
            fill: fill,
            thickness: widget.thickness,
            fraction: null,
            rotation: reduced ? 0 : loop.value,
          ),
        ),
      );
    } else {
      ring = TweenAnimationBuilder<double>(
        tween: Tween<double>(end: value),
        duration: reduced ? Duration.zero : D3Motion.moderate,
        curve: D3Motion.standard,
        builder: (context, v, _) => CustomPaint(
          painter: D3ProgressRingPainter(
            track: track,
            fill: fill,
            thickness: widget.thickness,
            fraction: v,
            rotation: 0,
          ),
        ),
      );
    }

    Widget? centre = widget.child;
    if (centre == null && widget.showValue && value != null) {
      centre = Text(
        _percent(value),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: math.max(11, widget.size * 0.24),
          fontWeight: FontWeight.w600,
          color: colors.onSurface,
          fontFeatures: _tabular,
        ),
      );
    }

    final box = SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(child: ring),
          if (centre != null)
            Padding(
              padding: EdgeInsets.all(widget.thickness + D3Spacing.s2),
              child: FittedBox(fit: BoxFit.scaleDown, child: centre),
            ),
        ],
      ),
    );

    return Semantics(
      container: true,
      label: widget.semanticsLabel ?? widget.label ?? 'Progress',
      value: value == null ? null : _percent(value),
      child: ExcludeSemantics(
        child: widget.label == null
            ? box
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  box,
                  const SizedBox(height: D3Spacing.s8),
                  Text(
                    widget.label!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: D3TypeScale.bodySmSize,
                      color: d3EnsureContrast(
                        colors.onSurfaceVariant,
                        colors.surface,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Paints the track and arc of a [D3ProgressRing].
///
/// Public only so tests can read the resolved colours.
class D3ProgressRingPainter extends CustomPainter {
  D3ProgressRingPainter({
    required this.track,
    required this.fill,
    required this.thickness,
    required this.fraction,
    required this.rotation,
  });

  final Color track;
  final Color fill;
  final double thickness;

  /// 0..1, or null for the indeterminate arc.
  final double? fraction;

  /// Indeterminate rotation, in turns.
  final double rotation;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      thickness / 2,
      thickness / 2,
      size.width - thickness,
      size.height - thickness,
    );
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, 0, math.pi * 2, false, stroke..color = track);
    stroke.color = fill;
    if (fraction == null) {
      final pulse = 0.5 - 0.5 * math.cos(rotation * math.pi * 2);
      final sweep = math.pi * 2 * (0.15 + 0.25 * pulse);
      canvas.drawArc(
        rect,
        -math.pi / 2 + rotation * math.pi * 2,
        sweep,
        false,
        stroke,
      );
    } else if (fraction! > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        math.pi * 2 * fraction!,
        false,
        stroke,
      );
    }
  }

  @override
  bool shouldRepaint(D3ProgressRingPainter old) =>
      old.track != track ||
      old.fill != fill ||
      old.thickness != thickness ||
      old.fraction != fraction ||
      old.rotation != rotation;
}
