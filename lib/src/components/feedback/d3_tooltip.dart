import 'dart:async';

import 'package:d3_ui/d3_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

const double _maxBubbleWidth = 280;
const double _edgeMargin = 8;
const double _anchorGap = 6;

/// Places a bubble next to [target], below or above, centred and kept fully
/// inside the screen.
class _BubbleLayout extends SingleChildLayoutDelegate {
  _BubbleLayout({required this.target, required this.preferBelow});

  final Rect target;
  final bool preferBelow;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints(
      maxWidth: (constraints.maxWidth - 2 * _edgeMargin).clamp(
        0.0,
        _maxBubbleWidth,
      ),
      maxHeight: (constraints.maxHeight - 2 * _edgeMargin).clamp(
        0.0,
        double.infinity,
      ),
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final x = (target.center.dx - childSize.width / 2).clamp(
      _edgeMargin,
      (size.width - _edgeMargin - childSize.width).clamp(
        _edgeMargin,
        double.infinity,
      ),
    );
    final below = target.bottom + _anchorGap;
    final above = target.top - _anchorGap - childSize.height;
    final fitsBelow = below + childSize.height <= size.height - _edgeMargin;
    final fitsAbove = above >= _edgeMargin;
    final useBelow = preferBelow ? (fitsBelow || !fitsAbove) : !fitsAbove;
    var y = useBelow ? below : above;
    y = y.clamp(
      _edgeMargin,
      (size.height - _edgeMargin - childSize.height).clamp(
        _edgeMargin,
        double.infinity,
      ),
    );
    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_BubbleLayout old) =>
      old.target != target || old.preferBelow != preferBelow;
}

Rect? _globalRect(BuildContext context) {
  final box = context.findRenderObject() as RenderBox?;
  if (box == null || !box.hasSize || !box.attached) return null;
  return box.localToGlobal(Offset.zero) & box.size;
}

/// A short text label that explains a control or a piece of text.
///
/// It appears on mouse hover and keyboard focus (desktop and web) after
/// [showDelay], and on long-press (touch). It goes away when the pointer
/// leaves, on Escape, on scroll, on a tap elsewhere, or after [autoHide].
/// The bubble uses the inverse of the surface colours, never takes pointer
/// events (so the child's own taps and long-presses keep working), wraps at
/// 280 dp and stays fully on screen. The message is also exposed to screen
/// readers as the child's tooltip.
///
/// ```dart
/// D3Tooltip(
///   message: 'Add to favourites',
///   child: IconButton(
///     icon: const Icon(Icons.favorite_border),
///     onPressed: _favourite,
///   ),
/// )
/// ```
///
/// For a visible touch-friendly hint use [D3InfoTip].
class D3Tooltip extends StatefulWidget {
  const D3Tooltip({
    super.key,
    required this.message,
    required this.child,
    this.showDelay = const Duration(milliseconds: 500),
    this.autoHide,
    this.preferBelow = true,
  });

  /// The text shown in the bubble.
  final String message;

  /// The widget the tooltip describes.
  final Widget child;

  /// How long a hover or focus must last before the bubble appears.
  final Duration showDelay;

  /// Hides the bubble after this long. When null, a bubble opened by
  /// long-press hides after 3 seconds and hover or focus bubbles stay until
  /// the pointer or focus leaves.
  final Duration? autoHide;

  /// Whether to place the bubble below the child when there is room.
  final bool preferBelow;

  @override
  State<D3Tooltip> createState() => _D3TooltipState();
}

class _D3TooltipState extends State<D3Tooltip>
    with SingleTickerProviderStateMixin {
  static const _touchAutoHide = Duration(seconds: 3);

  final _portal = OverlayPortalController();
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: D3Motion.fast,
  );
  Timer? _showTimer;
  Timer? _hideTimer;
  Rect? _target;
  bool _visible = false;
  ScrollPosition? _scroll;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scroll?.removeListener(_onScroll);
    _scroll = Scrollable.maybeOf(context)?.position;
    _scroll?.addListener(_onScroll);
  }

  @override
  void dispose() {
    _showTimer?.cancel();
    _hideTimer?.cancel();
    _scroll?.removeListener(_onScroll);
    if (_visible) {
      GestureBinding.instance.pointerRouter.removeGlobalRoute(_onPointer);
    }
    _ctrl.dispose();
    super.dispose();
  }

  void _onScroll() => _hide();

  void _onPointer(PointerEvent event) {
    if (event is PointerDownEvent) _hide();
  }

  void _scheduleShow() {
    if (_visible) return;
    _showTimer?.cancel();
    _showTimer = Timer(widget.showDelay, _show);
  }

  void _show({bool touch = false}) {
    _showTimer?.cancel();
    if (!mounted || _visible) return;
    final rect = _globalRect(context);
    if (rect == null) return;
    _target = rect;
    _visible = true;
    final reduced = MediaQuery.disableAnimationsOf(context);
    _ctrl.duration = reduced ? Duration.zero : D3Motion.fast;
    setState(() {});
    _portal.show();
    _ctrl.forward();
    GestureBinding.instance.pointerRouter.addGlobalRoute(_onPointer);
    final hideAfter = widget.autoHide ?? (touch ? _touchAutoHide : null);
    _hideTimer?.cancel();
    if (hideAfter != null) _hideTimer = Timer(hideAfter, _hide);
  }

  void _hide() {
    _showTimer?.cancel();
    _hideTimer?.cancel();
    if (!_visible) return;
    _visible = false;
    GestureBinding.instance.pointerRouter.removeGlobalRoute(_onPointer);
    _ctrl.reverse().whenComplete(() {
      if (mounted && !_visible) _portal.hide();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      tooltip: widget.message,
      child: MouseRegion(
        onEnter: (e) {
          if (e.kind != PointerDeviceKind.touch) _scheduleShow();
        },
        onExit: (_) => _hide(),
        child: Focus(
          canRequestFocus: false,
          skipTraversal: true,
          onFocusChange: (focused) {
            if (!focused) {
              _hide();
            } else if (FocusManager.instance.highlightMode ==
                FocusHighlightMode.traditional) {
              _scheduleShow();
            }
          },
          onKeyEvent: (node, event) {
            if (_visible &&
                event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.escape) {
              _hide();
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onLongPress: () {
              HapticFeedback.selectionClick();
              _show(touch: true);
            },
            child: OverlayPortal(
              controller: _portal,
              overlayChildBuilder: _buildBubble,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBubble(BuildContext overlayContext) {
    final colors = overlayContext.d3Colors;
    final shape = overlayContext.d3Shape;
    final fill = colors.onSurface;
    final ink = d3EnsureContrast(colors.surface, fill);
    final style = Theme.of(overlayContext).textTheme.bodySmall
        ?.copyWith(color: ink);
    final target = _target;
    if (target == null) return const SizedBox.shrink();

    return IgnorePointer(
      child: CustomSingleChildLayout(
        delegate: _BubbleLayout(
          target: target,
          preferBelow: widget.preferBelow,
        ),
        child: ExcludeSemantics(
          child: FadeTransition(
            opacity: _ctrl,
            child: Material(
              color: fill,
              borderRadius: shape.circularSm,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: D3Spacing.s12,
                  vertical: D3Spacing.s8,
                ),
                child: Text(widget.message, style: style),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A 48 dp info icon that toggles a short explanatory popover on tap.
///
/// Unlike [D3Tooltip] it needs no hover, so it works on touch. Tap to open,
/// tap anywhere else (or press Escape) to close. Place it beside a field label
/// or a heading.
///
/// ```dart
/// Row(
///   children: [
///     const Text('Display name'),
///     const D3InfoTip(
///       title: 'Display name',
///       message: 'Shown to other people. You can change it any time.',
///     ),
///   ],
/// )
/// ```
class D3InfoTip extends StatefulWidget {
  const D3InfoTip({
    super.key,
    required this.message,
    this.title,
    this.icon = Icons.info_outline_rounded,
  });

  /// The explanation shown in the popover.
  final String message;

  /// Optional bold heading above the message.
  final String? title;

  /// The trigger icon.
  final IconData icon;

  @override
  State<D3InfoTip> createState() => _D3InfoTipState();
}

class _D3InfoTipState extends State<D3InfoTip>
    with SingleTickerProviderStateMixin {
  final _portal = OverlayPortalController();
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: D3Motion.fast,
  );
  Rect? _target;
  bool _open = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() => _open ? _close() : _openTip();

  void _openTip() {
    final rect = _globalRect(context);
    if (rect == null) return;
    _target = rect;
    _open = true;
    final reduced = MediaQuery.disableAnimationsOf(context);
    _ctrl.duration = reduced ? Duration.zero : D3Motion.fast;
    setState(() {});
    _portal.show();
    _ctrl.forward();
  }

  void _close() {
    if (!_open) return;
    _open = false;
    setState(() {});
    _ctrl.reverse().whenComplete(() {
      if (mounted && !_open) _portal.hide();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    return PopScope(
      canPop: !_open,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        onKeyEvent: (node, event) {
          if (_open &&
              event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.escape) {
            _close();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: OverlayPortal(
          controller: _portal,
          overlayChildBuilder: _buildPopover,
          child: Semantics(
            button: true,
            expanded: _open,
            label: 'More information',
            excludeSemantics: true,
            onTap: _toggle,
            child: InkResponse(
              onTap: _toggle,
              radius: 24,
              child: SizedBox(
                width: 48,
                height: 48,
                child: Icon(
                  widget.icon,
                  size: 20,
                  color: d3EnsureContrast(
                    colors.onSurfaceVariant,
                    colors.surface,
                    minRatio: 3,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPopover(BuildContext overlayContext) {
    final colors = overlayContext.d3Colors;
    final shape = overlayContext.d3Shape;
    final text = Theme.of(overlayContext).textTheme;
    final fill = colors.surfaceContainerHigh;
    final target = _target;
    if (target == null) return const SizedBox.shrink();

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _close,
            child: const SizedBox.expand(),
          ),
        ),
        Positioned.fill(
          child: CustomSingleChildLayout(
            delegate: _BubbleLayout(target: target, preferBelow: true),
            child: FadeTransition(
              opacity: _ctrl,
              child: Semantics(
                liveRegion: true,
                container: true,
                child: Material(
                  color: fill,
                  elevation: 3,
                  shadowColor: colors.scrim,
                  shape: RoundedRectangleBorder(
                    borderRadius: shape.circularMd,
                    side: BorderSide(color: colors.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(D3Spacing.s12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.title != null)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: D3Spacing.s4,
                            ),
                            child: Text(
                              widget.title!,
                              style: text.titleSmall?.copyWith(
                                color: colors.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        Text(
                          widget.message,
                          style: text.bodyMedium?.copyWith(
                            color: d3EnsureContrast(
                              colors.onSurfaceVariant,
                              fill,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
