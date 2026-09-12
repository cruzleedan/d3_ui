import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:d3_ui/d3_ui.dart';

// ─────────────────────────────────────────────────────────────────────────────
// D3FabAction
// ─────────────────────────────────────────────────────────────────────────────

/// One action item revealed when a [D3ExpandingFab] is opened.
class D3FabAction {
  const D3FabAction({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
}

// ─────────────────────────────────────────────────────────────────────────────
// D3ExpandingFab
// ─────────────────────────────────────────────────────────────────────────────

/// A floating action button that expands into a radial menu of [actions] on
/// tap, dimming the screen behind it with a full-screen scrim rendered via
/// [Overlay] (the same mechanism [D3TextField]'s tooltip popover uses).
/// Flat, shadow-free — matches d3_ui's visual language rather than
/// Material's default elevation.
///
/// While open, the toggle button itself is re-drawn inside the overlay
/// (stacked above the scrim) so it stays visible and tappable to close the
/// menu — the base widget reserves layout space but renders nothing then.
///
/// ```dart
/// D3ExpandingFab(
///   icon: Icons.add,
///   actions: [
///     D3FabAction(icon: Icons.photo_camera_outlined, label: 'Photo', onPressed: _addPhoto),
///     D3FabAction(icon: Icons.note_add_outlined, label: 'Note', onPressed: _addNote),
///   ],
/// )
/// ```
class D3ExpandingFab extends StatefulWidget {
  const D3ExpandingFab({
    super.key,
    required this.actions,
    this.icon = Icons.add_rounded,
    this.openIcon = Icons.close_rounded,
    this.semanticsLabel = 'Open actions menu',
  });

  final List<D3FabAction> actions;
  final IconData icon;
  final IconData openIcon;
  final String semanticsLabel;

  static const double _size = 56;

  @override
  State<D3ExpandingFab> createState() => _D3ExpandingFabState();
}

class _D3ExpandingFabState extends State<D3ExpandingFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: D3Motion.moderate,
  );

  final GlobalKey _fabKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  @override
  void dispose() {
    _removeOverlay();
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    HapticFeedback.mediumImpact();
    if (_isOpen) {
      _close();
    } else {
      _open();
    }
  }

  void _open() {
    final renderBox = _fabKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final fabTopLeft = renderBox.localToGlobal(Offset.zero);

    setState(() => _isOpen = true);
    _overlayEntry = OverlayEntry(
      builder: (context) => _ExpandingFabOverlay(
        fabTopLeft: fabTopLeft,
        actions: widget.actions,
        progress: _controller,
        icon: widget.icon,
        openIcon: widget.openIcon,
        semanticsLabel: widget.semanticsLabel,
        onActionSelected: (action) {
          _close();
          action.onPressed();
        },
        onToggleClose: _close,
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
    _controller.forward();
  }

  void _close() {
    if (!_isOpen) return;
    setState(() => _isOpen = false);
    _controller.reverse().whenCompleteOrCancel(_removeOverlay);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    // While open, the real button is drawn inside the overlay instead —
    // this reserves the layout slot but stays invisible so it doesn't
    // double-render or intercept taps meant for the overlay's copy.
    return SizedBox(
      key: _fabKey,
      width: D3ExpandingFab._size,
      height: D3ExpandingFab._size,
      child: _isOpen
          ? null
          : _D3FabButton(
              isOpen: false,
              icon: widget.icon,
              openIcon: widget.openIcon,
              semanticsLabel: widget.semanticsLabel,
              onTap: _toggle,
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _D3FabButton — the visible circular toggle, shared by the base widget and
// its overlay copy.
// ─────────────────────────────────────────────────────────────────────────────

class _D3FabButton extends StatelessWidget {
  const _D3FabButton({
    required this.isOpen,
    required this.icon,
    required this.openIcon,
    required this.semanticsLabel,
    required this.onTap,
  });

  final bool isOpen;
  final IconData icon;
  final IconData openIcon;
  final String semanticsLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;

    return Semantics(
      button: true,
      label: semanticsLabel,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: D3ExpandingFab._size,
          height: D3ExpandingFab._size,
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: D3Radius.circularFull,
          ),
          alignment: Alignment.center,
          child: Icon(
            isOpen ? openIcon : icon,
            color: colors.onPrimary,
            size: 24,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ExpandingFabOverlay — rendered via Overlay, positioned relative to the FAB
// ─────────────────────────────────────────────────────────────────────────────

class _ExpandingFabOverlay extends StatelessWidget {
  const _ExpandingFabOverlay({
    required this.fabTopLeft,
    required this.actions,
    required this.progress,
    required this.icon,
    required this.openIcon,
    required this.semanticsLabel,
    required this.onActionSelected,
    required this.onToggleClose,
  });

  final Offset fabTopLeft;
  final List<D3FabAction> actions;
  final Animation<double> progress;
  final IconData icon;
  final IconData openIcon;
  final String semanticsLabel;
  final ValueChanged<D3FabAction> onActionSelected;
  final VoidCallback onToggleClose;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    final fabCenter = fabTopLeft + const Offset(
      D3ExpandingFab._size / 2,
      D3ExpandingFab._size / 2,
    );

    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) {
        return Stack(
          children: [
            // Full-screen scrim, dismisses on tap.
            Positioned.fill(
              child: GestureDetector(
                onTap: onToggleClose,
                child: Container(
                  color: colors.scrim.withValues(alpha: 0.34 * progress.value),
                ),
              ),
            ),
            for (int i = 0; i < actions.length; i++)
              _PositionedFabAction(
                fabCenter: fabCenter,
                index: i,
                total: actions.length,
                progress: progress,
                action: actions[i],
                onPressed: () => onActionSelected(actions[i]),
              ),
            // The toggle button's overlay copy — stays on top of the scrim
            // and remains tappable to close the menu.
            Positioned(
              left: fabTopLeft.dx,
              top: fabTopLeft.dy,
              child: _D3FabButton(
                isOpen: true,
                icon: icon,
                openIcon: openIcon,
                semanticsLabel: semanticsLabel,
                onTap: onToggleClose,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PositionedFabAction extends StatelessWidget {
  const _PositionedFabAction({
    required this.fabCenter,
    required this.index,
    required this.total,
    required this.progress,
    required this.action,
    required this.onPressed,
  });

  final Offset fabCenter;
  final int index;
  final int total;
  final Animation<double> progress;
  final D3FabAction action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    final screenWidth = MediaQuery.sizeOf(context).width;

    // Stack straight up from the FAB, one item per 64dp step — simplest
    // layout that guarantees no overlap regardless of action count, and
    // reads clearly against the FAB's fixed position near the screen edge.
    final radius = 72.0 + 64.0 * index;
    final t = Curves.easeOut.transform(progress.value);
    const dx = 0.0;
    final dy = -radius * t;

    // Action circle's center lands on the arc point; the label sits to its
    // left, growing leftward so it never crosses off the arc position.
    const circleSize = 44.0;
    const screenPad = 16.0;
    final center = fabCenter + Offset(dx, dy);

    // Clamp so the circle itself never crosses the screen edge — the label
    // to its left has room to shrink/wrap before that becomes a problem.
    final clampedCenterX = center.dx.clamp(
      screenPad + circleSize / 2,
      screenWidth - screenPad - circleSize / 2,
    );

    return Positioned(
      top: center.dy - circleSize / 2,
      right: screenWidth - clampedCenterX - circleSize / 2,
      child: IgnorePointer(
        ignoring: progress.value == 0,
        child: Opacity(
          opacity: t,
          // The label and the icon circle are one tap target, not two. The
          // label reads as part of the action — pointing at it and having
          // nothing happen is the obvious way to get this wrong, so the
          // whole row (and the gap between them) is tappable. See root
          // context/work/0045.
          child: Semantics(
            button: true,
            label: action.label,
            child: GestureDetector(
              onTap: onPressed,
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: D3Spacing.s10,
                      vertical: D3Spacing.s6,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainer,
                      borderRadius: D3Radius.circularSm,
                    ),
                    child: Text(
                      action.label,
                      style: TextStyle(fontSize: 12, color: colors.onSurface),
                    ),
                  ),
                  const SizedBox(width: D3Spacing.s8),
                  Container(
                    width: circleSize,
                    height: circleSize,
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: D3Radius.circularFull,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      action.icon,
                      color: colors.onPrimaryContainer,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
