import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:d3_ui/d3_ui.dart';

// ─────────────────────────────────────────────────────────────────────────────
// D3Toggle
// ─────────────────────────────────────────────────────────────────────────────

/// A custom toggle switch aligned with the d3 design system.
///
/// Pass `onChanged: null` to disable the toggle. Opacity drops to 35% and
/// interaction is blocked — no separate disabled color needed.
///
/// ```dart
/// // Standalone
/// D3Toggle(
///   value: _enabled,
///   onChanged: (v) => setState(() => _enabled = v),
/// )
///
/// // With inline label
/// D3Toggle(
///   value: _sync,
///   label: 'Sync contacts',
///   onChanged: (v) => setState(() => _sync = v),
/// )
///
/// // Disabled
/// D3Toggle(
///   value: true,
///   onChanged: null,
/// )
/// ```
class D3Toggle extends StatefulWidget {
  const D3Toggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.semanticsLabel,
  });

  /// Current on/off state.
  final bool value;

  /// Called with the new value when the user taps. Null disables the toggle.
  final ValueChanged<bool>? onChanged;

  /// Optional label rendered to the right of the track.
  final String? label;

  /// Overrides the semantic label read by screen readers.
  /// Defaults to [label] if provided, otherwise "Toggle".
  final String? semanticsLabel;

  bool get _isDisabled => onChanged == null;

  @override
  State<D3Toggle> createState() => _D3ToggleState();
}

class _D3ToggleState extends State<D3Toggle> with TickerProviderStateMixin {
  // ── Animation controllers ──────────────────────────────────────────────────

  // Drives thumb travel (0.0 = off position, 1.0 = on position).
  late final AnimationController _travelController;
  late final Animation<double> _travelAnim;

  // Drives thumb width squish (0.0 = normal, 1.0 = fully squished).
  late final AnimationController _squishController;

  // ── Geometry constants ─────────────────────────────────────────────────────

  static const double _trackW = 48;
  static const double _trackH = 28;
  static const double _thumbNormal = 22;
  static const double _thumbSquished = 26;
  static const double _thumbInset = 3;
  static const double _trackRadius = _trackH / 2;

  // Off position: left edge + inset.
  // On position: right edge - inset - thumb width.
  static const double _thumbOffLeft = _thumbInset;
  static const double _thumbOnLeft = _trackW - _thumbInset - _thumbNormal;

  @override
  void initState() {
    super.initState();

    _travelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      value: widget.value ? 1.0 : 0.0,
    );
    _travelAnim = CurvedAnimation(
      parent: _travelController,
      curve: D3Motion.standard,
    );

    _squishController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 120),
    );
  }

  @override
  void didUpdateWidget(D3Toggle old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      widget.value ? _travelController.forward() : _travelController.reverse();
    }
  }

  @override
  void dispose() {
    _travelController.dispose();
    _squishController.dispose();
    super.dispose();
  }

  // ── Interaction ────────────────────────────────────────────────────────────

  void _onTapDown(TapDownDetails _) {
    if (widget._isDisabled) return;
    _squishController.forward();
  }

  void _onTapUp(TapUpDetails _) {
    if (widget._isDisabled) return;
    _release();
    _commit();
  }

  void _onTapCancel() {
    if (widget._isDisabled) return;
    _release();
  }

  void _release() {
    _squishController.reverse();
  }

  void _commit() {
    HapticFeedback.lightImpact();
    widget.onChanged?.call(!widget.value);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;

    final toggle = Semantics(
      label: widget.semanticsLabel ?? widget.label ?? 'Toggle',
      enabled: !widget._isDisabled,
      toggled: widget.value,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: AnimatedOpacity(
          opacity: widget._isDisabled ? 0.35 : 1.0,
          duration: D3Motion.base,
          child: AnimatedBuilder(
            animation: Listenable.merge([_travelAnim, _squishController]),
            builder: (context, _) {
              final travel = _travelAnim.value;
              final squish = _squishController.value;

              // Track color interpolates between off and on.
              final trackColor = Color.lerp(
                colors.onSurface.withValues(alpha: 0.15),
                colors.primary,
                travel,
              )!;

              // Thumb width grows on press.
              final thumbW =
                  _thumbNormal + (_thumbSquished - _thumbNormal) * squish;

              // Thumb left position: when squished on the on→off press, anchor
              // the squish to the right so the thumb appears to stretch leftward.
              final baseLeft =
                  _thumbOffLeft + (_thumbOnLeft - _thumbOffLeft) * travel;
              // When pressing while ON, shift left by the extra width so the
              // right edge of the thumb stays pinned.
              final thumbLeft =
                  widget.value ? baseLeft - (thumbW - _thumbNormal) : baseLeft;

              return SizedBox(
                width: _trackW,
                height: _trackH,
                child: Stack(
                  children: [
                    // Track
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: trackColor,
                          borderRadius: BorderRadius.circular(_trackRadius),
                        ),
                      ),
                    ),

                    // Thumb
                    Positioned(
                      top: _thumbInset,
                      left: thumbLeft,
                      child: SizedBox(
                        width: thumbW,
                        height: _thumbNormal,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(_thumbNormal / 2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );

    // ── Optional label ─────────────────────────────────────────────────────
    if (widget.label == null) return toggle;

    return GestureDetector(
      onTap: widget._isDisabled ? null : _commit,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          toggle,
          const SizedBox(width: 10),
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: D3TypeScale.bodyMdSize,
              color: widget._isDisabled
                  ? colors.onSurfaceVariant.withValues(alpha: 0.35)
                  : colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
