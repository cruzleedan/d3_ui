import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:d3_ui/d3_ui.dart';

import '../inputs/helpers/d3_tap_target.dart';

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

enum D3SplitButtonVariant { filled, tonal, outlined }

/// Direction in which a [D3SplitButton]'s menu expands from its trailing button.
enum D3SplitButtonDirection { up, down }

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
    this.direction = D3SplitButtonDirection.up,
    this.isCompact,
    this.enabled = true,
  }) : assert(items.length > 0, 'D3SplitButton requires at least one item.');

  final String label;
  final VoidCallback? onPressed;
  final List<D3SplitButtonItem> items;
  final IconData? icon;
  final D3SplitButtonVariant variant;
  final D3ButtonSize size;

  /// Controls where the menu opens and the chevron's closed direction.
  final D3SplitButtonDirection direction;

  /// Overrides the theme's compact-density default for this button.
  final bool? isCompact;
  final bool enabled;

  @override
  State<D3SplitButton> createState() => _D3SplitButtonState();
}

class _D3SplitButtonState extends State<D3SplitButton>
    with SingleTickerProviderStateMixin {
  // Drives the trailing shape morph and chevron rotation.
  late final AnimationController _shapeCtrl;
  late final Animation<double> _shapeCurved;
  late final Animation<double> _shapeMorph;

  // ── Spec constants ────────────────────────────────────────────────────────
  static const _heights = {
    // xs and xl share the nearest supported size's metrics.
    D3ButtonSize.xs: 32.0,
    D3ButtonSize.sm: 32.0,
    D3ButtonSize.md: 40.0,
    D3ButtonSize.lg: 56.0,
    D3ButtonSize.xl: 56.0,
  };
  static const _leadingPadL = {
    // xs and xl share the nearest supported size's metrics.
    D3ButtonSize.xs: 12.0,
    D3ButtonSize.sm: 12.0,
    D3ButtonSize.md: 16.0,
    D3ButtonSize.lg: 24.0,
    D3ButtonSize.xl: 24.0,
  };
  static const _leadingPadR = {
    // xs and xl share the nearest supported size's metrics.
    D3ButtonSize.xs: 10.0,
    D3ButtonSize.sm: 10.0,
    D3ButtonSize.md: 12.0,
    D3ButtonSize.lg: 24.0,
    D3ButtonSize.xl: 24.0,
  };
  static const _iconSizes = {
    // xs and xl share the nearest supported size's metrics.
    D3ButtonSize.xs: 20.0,
    D3ButtonSize.sm: 20.0,
    D3ButtonSize.md: 20.0,
    D3ButtonSize.lg: 24.0,
    D3ButtonSize.xl: 24.0,
  };
  static const _trailingPadL = {
    // xs and xl share the nearest supported size's metrics.
    D3ButtonSize.xs: 12.0,
    D3ButtonSize.sm: 12.0,
    D3ButtonSize.md: 12.0,
    D3ButtonSize.lg: 13.0,
    D3ButtonSize.xl: 13.0,
  };
  static const _trailingPadR = {
    // xs and xl share the nearest supported size's metrics.
    D3ButtonSize.xs: 14.0,
    D3ButtonSize.sm: 14.0,
    D3ButtonSize.md: 14.0,
    D3ButtonSize.lg: 17.0,
    D3ButtonSize.xl: 17.0,
  };
  static const _textSizes = {
    // xs and xl share the nearest supported size's metrics.
    D3ButtonSize.xs: 13.0,
    D3ButtonSize.sm: 13.0,
    D3ButtonSize.md: 14.0,
    D3ButtonSize.lg: 15.0,
    D3ButtonSize.xl: 15.0,
  };
  static const double _gap = 2;
  static const double _iconLabelGap = 8;
  static const double _disabledOpacity = 0.38;

  @override
  void initState() {
    super.initState();
    _shapeCtrl = AnimationController(vsync: this, duration: D3Motion.base);
    _shapeCurved = CurvedAnimation(
      parent: _shapeCtrl,
      curve: D3Motion.standard,
    );
    // Finish the circle morph before the chevron completes its 180° turn,
    // then hold the circular shape through the end of the rotation.
    _shapeMorph = CurvedAnimation(
      parent: _shapeCtrl,
      curve: const Interval(0, 0.35, curve: D3Motion.standard),
      reverseCurve: const Interval(0.65, 1, curve: D3Motion.standard),
    );
  }

  @override
  void dispose() {
    _shapeCtrl.dispose();
    super.dispose();
  }

  void _openMenu() {
    _shapeCtrl.duration = MediaQuery.disableAnimationsOf(context)
        ? D3Motion.instant
        : D3Motion.base;
    _shapeCtrl.forward();
  }

  void _closeMenu() {
    _shapeCtrl.duration = MediaQuery.disableAnimationsOf(context)
        ? D3Motion.instant
        : D3Motion.base;
    _shapeCtrl.reverse();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    final compact = widget.isCompact ?? context.d3InputTokens.compactByDefault;
    final isEnabled = widget.enabled && widget.onPressed != null;
    final (bg, fg, borderColor) = _resolveColors(colors);

    final regularHeight = _heights[widget.size]!;
    final height = !compact
        ? regularHeight
        : switch (widget.size) {
            D3ButtonSize.xs || D3ButtonSize.sm => regularHeight,
            D3ButtonSize.md => regularHeight,
            D3ButtonSize.lg => regularHeight - 8,
            D3ButtonSize.xl => regularHeight - 6,
          };
    final pL = _leadingPadL[widget.size]!;
    final pR = _leadingPadR[widget.size]!;
    final tL = _trailingPadL[widget.size]!;
    final tR = _trailingPadR[widget.size]!;
    final iconSz = _iconSizes[widget.size]!;
    final textSz = _textSizes[widget.size]!;
    final stateColor = fg.withValues(alpha: 0.12);
    final closedWidth = tL + iconSz + tR;
    final circleSize = math.max(24.0, height - 4);
    final trailingSlotWidth = math.max(closedWidth, height);

    const leadingRadius = BorderRadius.only(
      topLeft: Radius.circular(999),
      bottomLeft: Radius.circular(999),
    );
    // Closed: mirror of leading. Open: a slightly smaller circle that fits in
    // the trailing segment's fixed layout slot.
    final trailingRadiusClosed = BorderRadius.only(
      topRight: Radius.circular(height / 2),
      bottomRight: Radius.circular(height / 2),
    );
    final trailingRadiusOpen = BorderRadius.circular(circleSize / 2);

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
                Flexible(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: textSz,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.1,
                      color: fg,
                      height: 1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
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
        final progress = _shapeMorph.value;
        final radius = BorderRadius.lerp(
          trailingRadiusClosed,
          trailingRadiusOpen,
          progress,
        )!;

        return _TrailingButton(
          height: height,
          closedWidth: closedWidth,
          circleSize: circleSize,
          slotWidth: trailingSlotWidth,
          shapeProgress: progress,
          iconSz: iconSz,
          bg: bg,
          fg: fg,
          stateColor: stateColor,
          radius: radius,
          borderColor: borderColor,
          chevronProgress: _shapeCurved.value,
          isEnabled: isEnabled,
          items: widget.items,
          direction: widget.direction,
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
    }

    return Align(
      alignment: Alignment.centerLeft,
      widthFactor: 1,
      heightFactor: 1,
      child: Opacity(
        opacity: isEnabled ? 1.0 : _disabledOpacity,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Each segment keeps its visual height; its tap region is 48 x 48.
            Flexible(
              child: MergeSemantics(child: D3PaddedTapTarget(child: leading)),
            ),
            const SizedBox(width: _gap),
            MergeSemantics(child: D3PaddedTapTarget(child: trailing)),
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
// Uses a custom overlay so the menu expands away from the button.
// ─────────────────────────────────────────────────────────────────────────────

class _TrailingButton extends StatefulWidget {
  const _TrailingButton({
    required this.height,
    required this.closedWidth,
    required this.circleSize,
    required this.slotWidth,
    required this.shapeProgress,
    required this.iconSz,
    required this.bg,
    required this.fg,
    required this.stateColor,
    required this.radius,
    required this.borderColor,
    required this.chevronProgress,
    required this.isEnabled,
    required this.items,
    required this.direction,
    required this.colors,
    required this.onOpened,
    required this.onClosed,
  });

  final double height;
  final double closedWidth;
  final double circleSize;
  final double slotWidth;
  final double shapeProgress;
  final double iconSz;
  final Color bg;
  final Color fg;
  final Color stateColor;
  final BorderRadius radius;
  final Color? borderColor;
  final double chevronProgress;
  final bool isEnabled;
  final List<D3SplitButtonItem> items;
  final D3SplitButtonDirection direction;
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
  bool _isClosing = false;

  late final AnimationController _menuCtrl;

  @override
  void initState() {
    super.initState();
    _menuCtrl = AnimationController(vsync: this, duration: D3Motion.base);
  }

  @override
  void dispose() {
    _removeOverlay();
    _menuCtrl.dispose();
    super.dispose();
  }

  void _showMenu() {
    _isClosing = false;
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    _menuCtrl.duration = reducedMotion ? D3Motion.instant : D3Motion.base;
    final renderBox = _key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final overlay = Overlay.of(context);
    final overlayBox = overlay.context.findRenderObject() as RenderBox?;
    if (overlayBox == null || !overlayBox.hasSize) return;

    // Positioned coordinates are local to this Overlay. Converting with the
    // overlay as ancestor avoids placing the menu below the button when the
    // widget lives inside a nested Scaffold/FAB layout.
    final buttonPos = renderBox.localToGlobal(
      Offset.zero,
      ancestor: overlayBox,
    );
    final buttonSize = renderBox.size;
    final colors = widget.colors;

    _overlay = OverlayEntry(
      builder: (_) => _MenuOverlay(
        buttonPos: buttonPos,
        buttonSize: buttonSize,
        overlaySize: overlayBox.size,
        direction: widget.direction,
        items: widget.items,
        colors: colors,
        buttonBackground: widget.bg,
        buttonForeground: widget.fg,
        menuAnimation: _menuCtrl,
        onItemSelected: (item) {
          _closeMenu();
          // A selected item may navigate to another route while this overlay
          // remains attached to its parent navigator. Remove it immediately
          // so it cannot cover the destination while the close animation runs.
          _removeOverlay();
          HapticFeedback.selectionClick();
          item.onPressed();
        },
        onDismiss: _closeMenu,
      ),
    );

    overlay.insert(_overlay!);
    _menuCtrl.forward();
    widget.onOpened();
  }

  void _closeMenu() {
    if (_overlay == null || _isClosing) return;
    _isClosing = true;

    // Reverse the button shape/chevron with the menu items.
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    _menuCtrl.duration = reducedMotion ? D3Motion.instant : D3Motion.base;
    widget.onClosed();
    _menuCtrl.reverse().then((_) {
      _removeOverlay();
    });
  }

  void _removeOverlay() {
    _overlay?.remove();
    _overlay = null;
  }

  @override
  Widget build(BuildContext context) {
    final visualWidth =
        widget.closedWidth +
        (widget.circleSize - widget.closedWidth) * widget.shapeProgress;
    final visualHeight =
        widget.height +
        (widget.circleSize - widget.height) * widget.shapeProgress;

    Widget visualButton = Material(
      color: widget.bg,
      borderRadius: widget.radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: _key,
        onTap: widget.isEnabled ? _showMenu : null,
        overlayColor: WidgetStatePropertyAll(widget.stateColor),
        child: SizedBox(
          width: visualWidth,
          height: visualHeight,
          child: Center(
            child: Transform.rotate(
              // The shape reaches its circle before the chevron completes
              // its 180° turn.
              angle: widget.chevronProgress * math.pi,
              child: Icon(
                widget.direction == D3SplitButtonDirection.up
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                // The closed chevron points toward the menu; when open it
                // rotates 180° to indicate the direction that will close it.
                size: widget.iconSz,
                color: widget.fg,
              ),
            ),
          ),
        ),
      ),
    );

    if (widget.borderColor case final borderColor?) {
      visualButton = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: widget.radius,
          border: Border.all(color: borderColor),
        ),
        child: visualButton,
      );
    }

    // Keep the split button's total width fixed while the visible trailing
    // shape shrinks into its circle. This prevents the leading action shifting.
    return SizedBox(
      width: widget.slotWidth,
      height: widget.height,
      child: Center(
        child: SizedBox(
          width: visualWidth,
          height: visualHeight,
          child: visualButton,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _MenuOverlay — custom menu that animates away from its anchor
// ─────────────────────────────────────────────────────────────────────────────

class _MenuOverlay extends StatelessWidget {
  const _MenuOverlay({
    required this.buttonPos,
    required this.buttonSize,
    required this.overlaySize,
    required this.direction,
    required this.items,
    required this.colors,
    required this.buttonBackground,
    required this.buttonForeground,
    required this.menuAnimation,
    required this.onItemSelected,
    required this.onDismiss,
  });

  final Offset buttonPos;
  final Size buttonSize;
  final Size overlaySize;
  final D3SplitButtonDirection direction;
  final List<D3SplitButtonItem> items;
  final D3ColorTokens colors;
  final Color buttonBackground;
  final Color buttonForeground;
  final Animation<double> menuAnimation;
  final void Function(D3SplitButtonItem) onItemSelected;
  final VoidCallback onDismiss;

  static const double _itemGap = 4;
  static const double _menuPadV = 8;
  static const double _minMenuWidth = 224;

  @override
  Widget build(BuildContext context) {
    final itemHeight = buttonSize.height;
    final menuHeight =
        items.length * itemHeight +
        (items.length - 1) * _itemGap +
        _menuPadV * 2;
    final requestedTop = switch (direction) {
      D3SplitButtonDirection.up => buttonPos.dy - menuHeight - D3Spacing.s4,
      D3SplitButtonDirection.down =>
        buttonPos.dy + buttonSize.height + D3Spacing.s4,
    };
    final maxTop = (overlaySize.height - menuHeight - 8)
        .clamp(8.0, double.infinity)
        .toDouble();
    final menuTop = requestedTop.clamp(8.0, maxTop).toDouble();
    final menuWidth = _minMenuWidth
        .clamp(0.0, overlaySize.width - 16)
        .toDouble();
    final requestedLeft = buttonPos.dx + buttonSize.width - menuWidth;
    final menuLeft = requestedLeft
        .clamp(8.0, overlaySize.width - menuWidth - 8)
        .toDouble();
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    final itemSpan = items.length == 1 ? 1.0 : 0.55;
    final stagger = items.length == 1
        ? 0.0
        : (1.0 - itemSpan) / (items.length - 1);

    return Stack(
      children: [
        // Full-screen dismiss barrier.
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onDismiss,
          ),
        ),

        Positioned(
          left: menuLeft,
          top: menuTop,
          width: menuWidth,
          child: Material(
            color: Colors.transparent,
            elevation: 0,
            clipBehavior: Clip.none,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(height: _menuPadV),
                ...List.generate(items.length, (index) {
                  final sequenceIndex = direction == D3SplitButtonDirection.up
                      ? items.length - 1 - index
                      : index;
                  final begin = sequenceIndex * stagger;
                  final end = (begin + itemSpan).clamp(0.0, 1.0).toDouble();
                  final slideDistance =
                      itemHeight *
                      0.16 *
                      (direction == D3SplitButtonDirection.up ? 1 : -1);

                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == items.length - 1 ? 0 : _itemGap,
                    ),
                    child: AnimatedBuilder(
                      animation: menuAnimation,
                      builder: (context, child) {
                        final progress = reducedMotion
                            ? 1.0
                            : _itemProgress(
                                menuAnimation.value,
                                menuAnimation.status,
                                begin,
                                end,
                              );

                        return ClipRect(
                          child: Opacity(
                            opacity: progress,
                            child: Transform.translate(
                              offset: Offset(0, slideDistance * (1 - progress)),
                              child: child,
                            ),
                          ),
                        );
                      },
                      child: _MenuItem(
                        item: items[index],
                        height: itemHeight,
                        maxLabelWidth: math.max(
                          0.0,
                          menuWidth -
                              (items[index].icon == null
                                  ? 0
                                  : math.max(24.0, itemHeight - 4) +
                                        D3Spacing.s8),
                        ),
                        colors: colors,
                        buttonBackground: buttonBackground,
                        buttonForeground: buttonForeground,
                        onSelected: () => onItemSelected(items[index]),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: _menuPadV),
              ],
            ),
          ),
        ),
      ],
    );
  }

  double _itemProgress(
    double value,
    AnimationStatus status,
    double begin,
    double end,
  ) {
    if (value <= begin) return 0;
    if (value >= end) return 1;
    final normalized = (value - begin) / (end - begin);
    final curve = status == AnimationStatus.reverse
        ? D3Motion.exit
        : D3Motion.enter;
    return curve.transform(normalized);
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.item,
    required this.height,
    required this.maxLabelWidth,
    required this.colors,
    required this.buttonBackground,
    required this.buttonForeground,
    required this.onSelected,
  });

  final D3SplitButtonItem item;
  final double height;
  final double maxLabelWidth;
  final D3ColorTokens colors;
  final Color buttonBackground;
  final Color buttonForeground;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final labelColor = item.isDestructive ? colors.error : colors.onSurface;
    final borderRadius = BorderRadius.circular(height / 2);
    final iconSize = math.max(24.0, height - 4);

    return InkWell(
      onTap: onSelected,
      borderRadius: borderRadius,
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: SizedBox(
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surfaceContainer,
            borderRadius: borderRadius,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxLabelWidth),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: D3Spacing.s20,
                    right: D3Spacing.s10,
                  ),
                  child: Text(
                    item.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: labelColor,
                    ),
                  ),
                ),
              ),
              if (item.icon != null) ...[
                const SizedBox(width: D3Spacing.s8),
                Container(
                  width: iconSize,
                  height: iconSize,
                  decoration: BoxDecoration(
                    color: buttonBackground,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    item.icon,
                    size: 20,
                    color: item.isDestructive ? colors.error : buttonForeground,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
