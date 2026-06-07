import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:d3_ui/d3_ui.dart';

// ─────────────────────────────────────────────────────────────────────────────
// D3SplitButtonItem
// ─────────────────────────────────────────────────────────────────────────────

class D3SplitButtonItem {
  const D3SplitButtonItem({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isDestructive = false,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isDestructive;
}

// ─────────────────────────────────────────────────────────────────────────────
// D3SplitButtonVariant
// ─────────────────────────────────────────────────────────────────────────────

enum D3SplitButtonVariant {
  filled,
  tonal,
  outlined,
}

// ─────────────────────────────────────────────────────────────────────────────
// D3SplitButton
// ─────────────────────────────────────────────────────────────────────────────

class D3SplitButton extends StatefulWidget {
  const D3SplitButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.items,
    this.icon,
    this.variant = D3SplitButtonVariant.filled,
    this.size = D3ButtonSize.md,
    this.enabled = true,
  }) : assert(items.length > 0, 'D3SplitButton requires at least one item.');

  final String label;
  final VoidCallback? onPressed;
  final List<D3SplitButtonItem> items;
  final IconData? icon;
  final D3SplitButtonVariant variant;
  final D3ButtonSize size;
  final bool enabled;

  @override
  State<D3SplitButton> createState() => _D3SplitButtonState();
}

class _D3SplitButtonState extends State<D3SplitButton>
    with SingleTickerProviderStateMixin {
  // Drives trailing shape (0 = closed stadium, 1 = full circle) and
  // chevron rotation (0 = down, 1 = up).
  late final AnimationController _shapeCtrl;
  late final Animation<double> _shapeCurved;

  // ── Spec constants ────────────────────────────────────────────────────────
  static const _heights = {
    D3ButtonSize.sm: 32.0,
    D3ButtonSize.md: 40.0,
    D3ButtonSize.lg: 56.0,
  };
  static const _leadingPadL = {
    D3ButtonSize.sm: 12.0,
    D3ButtonSize.md: 16.0,
    D3ButtonSize.lg: 24.0,
  };
  static const _leadingPadR = {
    D3ButtonSize.sm: 10.0,
    D3ButtonSize.md: 12.0,
    D3ButtonSize.lg: 24.0,
  };
  static const _iconSizes = {
    D3ButtonSize.sm: 20.0,
    D3ButtonSize.md: 20.0,
    D3ButtonSize.lg: 24.0,
  };
  static const _trailingPadL = {
    D3ButtonSize.sm: 12.0,
    D3ButtonSize.md: 12.0,
    D3ButtonSize.lg: 13.0,
  };
  static const _trailingPadR = {
    D3ButtonSize.sm: 14.0,
    D3ButtonSize.md: 14.0,
    D3ButtonSize.lg: 17.0,
  };
  static const _textSizes = {
    D3ButtonSize.sm: 13.0,
    D3ButtonSize.md: 14.0,
    D3ButtonSize.lg: 15.0,
  };
  static const double _gap = 2;
  static const double _iconLabelGap = 8;
  static const double _disabledOpacity = 0.38;

  @override
  void initState() {
    super.initState();
    _shapeCtrl = AnimationController(
      vsync: this,
      duration: D3Motion.base,
    );
    _shapeCurved = CurvedAnimation(
      parent: _shapeCtrl,
      curve: D3Motion.standard,
    );
  }

  @override
  void dispose() {
    _shapeCtrl.dispose();
    super.dispose();
  }

  void _openMenu() => _shapeCtrl.forward();

  void _closeMenu() => _shapeCtrl.reverse();

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    final isEnabled = widget.enabled && widget.onPressed != null;
    final (bg, fg, borderColor) = _resolveColors(colors);

    final height = _heights[widget.size]!;
    final pL = _leadingPadL[widget.size]!;
    final pR = _leadingPadR[widget.size]!;
    final tL = _trailingPadL[widget.size]!;
    final tR = _trailingPadR[widget.size]!;
    final iconSz = _iconSizes[widget.size]!;
    final textSz = _textSizes[widget.size]!;
    final stateColor = fg.withValues(alpha: 0.12);

    const leadingRadius = BorderRadius.only(
      topLeft: Radius.circular(999),
      bottomLeft: Radius.circular(999),
    );
    // Closed: mirror of leading.  Open: full circle.
    // Interpolated by _shapeCurved so the corners animate smoothly.
    final trailingRadiusClosed = BorderRadius.only(
      topRight: Radius.circular(height / 2),
      bottomRight: Radius.circular(height / 2),
    );
    final trailingRadiusOpen = BorderRadius.circular(height / 2);

    // ── Leading ──────────────────────────────────────────────────────────────
    Widget leading = Material(
      color: bg,
      borderRadius: leadingRadius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isEnabled
            ? () {
                HapticFeedback.lightImpact();
                widget.onPressed!();
              }
            : null,
        overlayColor: WidgetStatePropertyAll(stateColor),
        child: SizedBox(
          height: height,
          child: Padding(
            padding: EdgeInsets.only(left: pL, right: pR),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, size: iconSz, color: fg),
                  const SizedBox(width: _iconLabelGap),
                ],
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: textSz,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.1,
                    color: fg,
                    height: 1,
                  ),
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // ── Trailing ─────────────────────────────────────────────────────────────
    // AnimatedBuilder interpolates the BorderRadius on every frame so the
    // Material clip, the InkWell ripple clip, and the background all move
    // together — no overflow.
    Widget trailing = AnimatedBuilder(
      animation: _shapeCurved,
      builder: (context, child) {
        final radius = BorderRadius.lerp(
          trailingRadiusClosed,
          trailingRadiusOpen,
          _shapeCurved.value,
        )!;

        return _TrailingButton(
          height: height,
          padL: tL,
          padR: tR,
          iconSz: iconSz,
          bg: bg,
          fg: fg,
          stateColor: stateColor,
          radius: radius,
          // Rotate chevron 0→0.5 turns (0°→180°) as menu opens.
          chevronTurns: _shapeCurved.value * 0.5,
          isEnabled: isEnabled,
          items: widget.items,
          colors: colors,
          onOpened: _openMenu,
          onClosed: _closeMenu,
        );
      },
    );

    if (borderColor != null) {
      leading = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: leadingRadius,
          border: Border.all(color: borderColor),
        ),
        child: leading,
      );
      // Border on trailing uses animated radius — rebuilt each frame.
      trailing = AnimatedBuilder(
        animation: _shapeCurved,
        builder: (context, child) {
          final radius = BorderRadius.lerp(
            trailingRadiusClosed,
            trailingRadiusOpen,
            _shapeCurved.value,
          )!;
          return DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: borderColor),
            ),
            child: child,
          );
        },
        child: trailing,
      );
    }

    return UnconstrainedBox(
      child: Opacity(
        opacity: isEnabled ? 1.0 : _disabledOpacity,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            leading,
            const SizedBox(width: _gap),
            trailing,
          ],
        ),
      ),
    );
  }

  (Color, Color, Color?) _resolveColors(D3ColorTokens c) =>
      switch (widget.variant) {
        D3SplitButtonVariant.filled => (
            c.primaryContainer,
            c.onPrimaryContainer,
            null,
          ),
        D3SplitButtonVariant.tonal => (c.secondary, c.onSecondary, null),
        D3SplitButtonVariant.outlined => (c.surface, c.primary, c.outline),
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// _TrailingButton
// Extracted widget so AnimatedBuilder can rebuild only the trailing segment.
// Uses a custom overlay for the menu so it animates bottom-up (scale from
// the bottom edge, revealing top items last) instead of the default top-down.
// ─────────────────────────────────────────────────────────────────────────────

class _TrailingButton extends StatefulWidget {
  const _TrailingButton({
    required this.height,
    required this.padL,
    required this.padR,
    required this.iconSz,
    required this.bg,
    required this.fg,
    required this.stateColor,
    required this.radius,
    required this.chevronTurns,
    required this.isEnabled,
    required this.items,
    required this.colors,
    required this.onOpened,
    required this.onClosed,
  });

  final double height;
  final double padL;
  final double padR;
  final double iconSz;
  final Color bg;
  final Color fg;
  final Color stateColor;
  final BorderRadius radius;
  final double chevronTurns;
  final bool isEnabled;
  final List<D3SplitButtonItem> items;
  final D3ColorTokens colors;
  final VoidCallback onOpened;
  final VoidCallback onClosed;

  @override
  State<_TrailingButton> createState() => _TrailingButtonState();
}

class _TrailingButtonState extends State<_TrailingButton>
    with SingleTickerProviderStateMixin {
  final _key = GlobalKey();
  OverlayEntry? _overlay;

  late final AnimationController _menuCtrl;
  late final Animation<double> _menuScale;
  late final Animation<double> _menuFade;

  @override
  void initState() {
    super.initState();
    _menuCtrl = AnimationController(
      vsync: this,
      duration: D3Motion.base,
    );
    // Scale from 0→1 along the Y axis, anchored to the bottom.
    _menuScale = CurvedAnimation(parent: _menuCtrl, curve: D3Motion.decelerate);
    _menuFade = CurvedAnimation(parent: _menuCtrl, curve: D3Motion.decelerate);
  }

  @override
  void dispose() {
    _removeOverlay();
    _menuCtrl.dispose();
    super.dispose();
  }

  void _showMenu() {
    final renderBox =
        _key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final buttonPos = renderBox.localToGlobal(Offset.zero);
    final buttonSize = renderBox.size;
    final colors = widget.colors;

    _overlay = OverlayEntry(
      builder: (_) => _MenuOverlay(
        buttonPos: buttonPos,
        buttonSize: buttonSize,
        items: widget.items,
        colors: colors,
        scaleAnimation: _menuScale,
        fadeAnimation: _menuFade,
        onItemSelected: (item) {
          _closeMenu();
          HapticFeedback.selectionClick();
          item.onPressed();
        },
        onDismiss: _closeMenu,
      ),
    );

    Overlay.of(context).insert(_overlay!);
    _menuCtrl.forward();
    widget.onOpened();
  }

  void _closeMenu() {
    _menuCtrl.reverse().then((_) {
      _removeOverlay();
      widget.onClosed();
    });
  }

  void _removeOverlay() {
    _overlay?.remove();
    _overlay = null;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: widget.bg,
      borderRadius: widget.radius,
      clipBehavior: Clip.antiAlias, // ← clips InkWell ripple to animated shape
      child: InkWell(
        key: _key,
        onTap: widget.isEnabled ? _showMenu : null,
        overlayColor: WidgetStatePropertyAll(widget.stateColor),
        child: SizedBox(
          height: widget.height,
          child: Padding(
            padding: EdgeInsets.only(left: widget.padL, right: widget.padR),
            child: Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: widget.chevronTurns, end: widget.chevronTurns),
                duration: Duration.zero,
                builder: (_, turns, __) => RotationTransition(
                  turns: AlwaysStoppedAnimation(turns),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: widget.iconSz,
                    color: widget.fg,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _MenuOverlay — custom menu that animates bottom-up
// ─────────────────────────────────────────────────────────────────────────────

class _MenuOverlay extends StatelessWidget {
  const _MenuOverlay({
    required this.buttonPos,
    required this.buttonSize,
    required this.items,
    required this.colors,
    required this.scaleAnimation,
    required this.fadeAnimation,
    required this.onItemSelected,
    required this.onDismiss,
  });

  final Offset buttonPos;
  final Size buttonSize;
  final List<D3SplitButtonItem> items;
  final D3ColorTokens colors;
  final Animation<double> scaleAnimation;
  final Animation<double> fadeAnimation;
  final void Function(D3SplitButtonItem) onItemSelected;
  final VoidCallback onDismiss;

  static const double _itemHeight = 48;
  static const double _menuPadV = 8;
  static const double _minMenuWidth = 160;

  @override
  Widget build(BuildContext context) {
    final menuHeight = items.length * _itemHeight + _menuPadV * 2;
    // Position menu so its bottom edge sits just above the button.
    final menuTop = buttonPos.dy - menuHeight - D3Spacing.s4;
    final menuLeft = buttonPos.dx + buttonSize.width - _minMenuWidth;

    return Stack(
      children: [
        // Full-screen dismiss barrier.
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onDismiss,
          ),
        ),

        // Menu panel, anchored to the bottom (scale origin = bottom).
        Positioned(
          left: menuLeft.clamp(8.0, double.infinity),
          top: menuTop,
          width: _minMenuWidth,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: AnimatedBuilder(
              animation: scaleAnimation,
              builder: (_, child) => Transform.scale(
                scaleY: scaleAnimation.value,
                alignment: Alignment.bottomCenter,
                child: child,
              ),
              child: Material(
                color: colors.surfaceVariant,
                borderRadius: BorderRadius.circular(D3Radius.md),
                elevation: 3,
                clipBehavior: Clip.antiAlias,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: _menuPadV),
                    ...items.map(
                      (item) => _MenuItem(
                        item: item,
                        colors: colors,
                        onSelected: () => onItemSelected(item),
                      ),
                    ),
                    const SizedBox(height: _menuPadV),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.item,
    required this.colors,
    required this.onSelected,
  });

  final D3SplitButtonItem item;
  final D3ColorTokens colors;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final labelColor =
        item.isDestructive ? colors.error : colors.onSurface;

    return InkWell(
      onTap: onSelected,
      overlayColor:
          WidgetStatePropertyAll(labelColor.withValues(alpha: 0.08)),
      child: SizedBox(
        height: 48,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: D3Spacing.s16),
          child: Row(
            children: [
              if (item.icon != null) ...[
                Icon(item.icon, size: 18, color: labelColor),
                const SizedBox(width: D3Spacing.s12),
              ],
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: labelColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
