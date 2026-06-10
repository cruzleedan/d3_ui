import 'package:flutter/material.dart';
import 'package:d3_ui/d3_ui.dart';

// ─────────────────────────────────────────────────────────────────────────────
// D3SnapPoint
// ─────────────────────────────────────────────────────────────────────────────

/// Defines a height fraction (0.0–1.0) that the sheet snaps to.
///
/// Use the named presets or create a custom fraction:
/// ```dart
/// snaps: [D3SnapPoint.half, D3SnapPoint.expanded]
/// snaps: [D3SnapPoint(0.35), D3SnapPoint(0.75)]
/// ```
class D3SnapPoint {
  const D3SnapPoint(this.fraction)
      : assert(
          fraction > 0 && fraction <= 1,
          'fraction must be between 0 (exclusive) and 1 (inclusive)',
        );

  final double fraction;

  /// ~15% of screen height — peek state.
  static const peek = D3SnapPoint(0.15);

  /// ~50% of screen height — default half-sheet.
  static const half = D3SnapPoint(0.50);

  /// ~92% of screen height — near full-screen.
  static const expanded = D3SnapPoint(0.92);

  @override
  bool operator ==(Object other) =>
      other is D3SnapPoint && other.fraction == fraction;

  @override
  int get hashCode => fraction.hashCode;
}

// ─────────────────────────────────────────────────────────────────────────────
// D3BottomSheet
// ─────────────────────────────────────────────────────────────────────────────

/// Modal bottom sheet with snap points, drag-to-snap, a drag handle,
/// an explicit close button, and an optional discard guard.
///
/// ```dart
/// // Simple
/// await D3BottomSheet.show(
///   context,
///   title: 'Sort by',
///   child: SortPicker(),
/// );
///
/// // Picker — returns a value
/// final sort = await D3BottomSheet.show<SortOption>(
///   context,
///   title: 'Sort by',
///   child: SortPicker(onSelect: (v) => Navigator.pop(context, v)),
/// );
///
/// // With discard guard
/// await D3BottomSheet.show(
///   context,
///   title: 'Edit profile',
///   onConfirmDiscard: () async {
///     return await showDialog<bool>(
///       context: context,
///       builder: (_) => DiscardDialog(),
///     ) ?? false;
///   },
///   child: EditProfileForm(),
/// );
/// ```
class D3BottomSheet {
  // Static API only — not instantiatable.
  const D3BottomSheet._();

  /// Shows a modal bottom sheet and returns the value passed to
  /// [Navigator.pop], or null if dismissed.
  ///
  /// [snapPoints] controls which heights the sheet snaps to, sorted ascending.
  /// Defaults to [[D3SnapPoint.half]].
  ///
  /// [initialSnap] sets the snap the sheet opens at. Defaults to the smallest
  /// snap point.
  ///
  /// [onConfirmDiscard] is called before any close attempt (× button, scrim
  /// tap, back gesture). Return `true` to allow closing, `false` to cancel.
  /// When null, the sheet closes immediately.
  ///
  /// [headerAction] is an optional widget in the trailing slot of the header
  /// row, between the title block and the close button (e.g. a "Reset" link).
  /// Closes the enclosing [D3BottomSheet] and returns [result] to the caller
  /// of [show]. Use this instead of [Navigator.pop] when calling from a sheet
  /// child, so the [PopScope] guard is bypassed correctly.
  static void pop<T>(BuildContext context, [T? result]) {
    _D3BottomSheetScope.of(context)?._closeWithResult(result);
  }

  static Future<T?> show<T>(
    BuildContext context, {
    String? title,
    String? subtitle,
    Widget? headerAction,
    required Widget child,
    List<D3SnapPoint> snapPoints = const [D3SnapPoint.half],
    D3SnapPoint? initialSnap,
    Future<bool> Function()? onConfirmDiscard,
    bool useRootNavigator = true,
  }) {
    assert(snapPoints.isNotEmpty, 'snapPoints must not be empty');

    final sorted = [...snapPoints]
      ..sort((a, b) => a.fraction.compareTo(b.fraction));
    final resolvedInitial = initialSnap ?? sorted.first;

    // Capture status-bar height before showModalBottomSheet consumes it —
    // the modal route zeroes out MediaQuery padding for its subtree.
    final statusBarHeight = MediaQuery.viewPaddingOf(context).top;

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      // When no guard: scrim tap dismisses directly.
      // When guard is active: scrim tap is blocked — user must use × or back.
      isDismissible: onConfirmDiscard == null,
      // DraggableScrollableSheet handles all drag — we don't want the modal
      // route to compete with it.
      enableDrag: false,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      useRootNavigator: useRootNavigator,
      builder: (ctx) => _D3BottomSheetContent<T>(
        title: title,
        subtitle: subtitle,
        headerAction: headerAction,
        snapPoints: sorted,
        initialSnap: resolvedInitial,
        onConfirmDiscard: onConfirmDiscard,
        statusBarHeight: statusBarHeight,
        child: child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Inherited scope — lets child widgets call D3BottomSheet.pop(context, result)
// ─────────────────────────────────────────────────────────────────────────────

class _D3BottomSheetScope extends InheritedWidget {
  const _D3BottomSheetScope({
    required this.state,
    required super.child,
  });

  final _D3BottomSheetContentState state;

  static _D3BottomSheetContentState? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_D3BottomSheetScope>()?.state;

  @override
  bool updateShouldNotify(_D3BottomSheetScope old) => state != old.state;
}

// ─────────────────────────────────────────────────────────────────────────────
// Sheet content widget
// ─────────────────────────────────────────────────────────────────────────────

class _D3BottomSheetContent<T> extends StatefulWidget {
  const _D3BottomSheetContent({
    this.title,
    this.subtitle,
    this.headerAction,
    required this.snapPoints,
    required this.initialSnap,
    this.onConfirmDiscard,
    required this.statusBarHeight,
    required this.child,
  });

  final String? title;
  final String? subtitle;
  final Widget? headerAction;
  final List<D3SnapPoint> snapPoints;
  final D3SnapPoint initialSnap;
  final Future<bool> Function()? onConfirmDiscard;
  final double statusBarHeight;
  final Widget child;

  @override
  State<_D3BottomSheetContent<T>> createState() =>
      _D3BottomSheetContentState<T>();
}

class _D3BottomSheetContentState<T> extends State<_D3BottomSheetContent<T>> {
  late DraggableScrollableController _dsController;

  // Prevents concurrent close attempts (e.g. double-tap ×, rapid back taps).
  bool _isClosing = false;

  // Flipped to true just before we call navigator.pop() so PopScope sees
  // canPop: true and doesn't re-intercept our own programmatic pop.
  bool _allowPop = false;

  late double _minSnapFraction;
  late double _maxSnapFraction;

  double _lastKeyboardInset = 0;

  @override
  void initState() {
    super.initState();
    _minSnapFraction = widget.snapPoints.first.fraction;
    _maxSnapFraction = widget.snapPoints.last.fraction;
    _dsController = DraggableScrollableController();
    _dsController.addListener(_onSheetSizeChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final keyboardOpened = keyboardInset > 0 && _lastKeyboardInset == 0;
    final keyboardClosed = keyboardInset == 0 && _lastKeyboardInset > 0;
    if (keyboardOpened || keyboardClosed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_dsController.isAttached) return;
        _dsController.animateTo(
          keyboardOpened ? 1.0 : _maxSnapFraction,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      });
    }
    _lastKeyboardInset = keyboardInset;
  }

  @override
  void dispose() {
    _dsController.removeListener(_onSheetSizeChange);
    _dsController.dispose();
    super.dispose();
  }

  void _onSheetSizeChange() {
    if (!_dsController.isAttached) return;
    final size = _dsController.size;

    if (widget.onConfirmDiscard != null) {
      // Guarded: when the user drags below 60 % of the minimum snap fraction,
      // bounce the sheet back up and surface the discard confirmation.
      if (size < _minSnapFraction * 0.6) {
        _tryClose();
      }
    } else {
      if (size < 0.01) {
        _tryClose();
      }
    }
  }

  Future<void> _tryClose() async {
    if (_isClosing || _allowPop) return;
    _isClosing = true;
    try {
      if (widget.onConfirmDiscard != null) {
        // If the sheet was dragged down, animate it back to the minimum snap
        // concurrently with the confirmation dialog appearing.
        if (_dsController.isAttached && _dsController.size < _minSnapFraction) {
          _dsController.animateTo(
            _minSnapFraction,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
        if (!mounted) return;
        final confirmed = await widget.onConfirmDiscard!();
        if (!confirmed) return;
      }
      if (!mounted) return;
      // Capture NavigatorState before the async gap so it stays valid.
      // setState lifts the PopScope guard; addPostFrameCallback waits for
      // that rebuild to flush before calling pop().
      final navigator = Navigator.of(context);
      setState(() => _allowPop = true);
      WidgetsBinding.instance.addPostFrameCallback((_) => navigator.pop());
    } finally {
      _isClosing = false;
    }
  }

  void _closeWithResult<R>(R? result) {
    if (_isClosing || _allowPop) return;
    if (!mounted) return;
    final navigator = Navigator.of(context);
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) => navigator.pop(result));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    final fractions = widget.snapPoints.map((s) => s.fraction).toList();
    final maxFraction = fractions.last;
    // Always allow dragging to 0.0 — guarded sheets bounce back via the
    // listener instead of being locked at their minimum snap.
    const minFraction = 0.0;
    // All declared fractions are snap points. maxFraction is both the ceiling
    // for manual dragging and a snap target when keyboard closes.
    final snapSizes = fractions
        .where((f) => f > minFraction && f < 1.0)
        .toList();
    final initialFraction = widget.initialSnap.fraction.clamp(
      fractions.first,
      maxFraction,
    );

    return _D3BottomSheetScope(
      state: this,
      child: PopScope(
        // Allow programmatic Navigator.pop() to pass through when no guard is
        // configured — only block it when the user needs to confirm discard.
        canPop: _allowPop || widget.onConfirmDiscard == null,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _tryClose();
        },
        child: DraggableScrollableSheet(
          controller: _dsController,
          initialChildSize: initialFraction,
          minChildSize: minFraction,
          maxChildSize: maxFraction,
          snap: true,
          snapSizes: snapSizes,
          expand: false,
          // Disable Flutter's built-in auto-pop when the sheet reaches
          // minChildSize (0.0). Without this, DraggableScrollableSheet
          // dispatches a DraggableScrollableNotification that causes
          // showModalBottomSheet to call Navigator.pop() automatically,
          // while _onSheetSizeChange also queues a pop — the double-pop
          // would dismiss an underlying screen instead of just the sheet.
          shouldCloseOnMinExtent: false,
          builder: (ctx, scrollController) => AnimatedBuilder(
            animation: _dsController,
            builder: (_, __) {
              final atTop = _dsController.isAttached &&
                  _dsController.size >= 0.99;
              return _SheetSurface(
                colors: colors,
                title: widget.title,
                subtitle: widget.subtitle,
                headerAction: widget.headerAction,
                scrollController: scrollController,
                onClose: _tryClose,
                statusBarHeight: atTop ? widget.statusBarHeight : 0,
                child: widget.child,
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sheet surface (visual shell)
// ─────────────────────────────────────────────────────────────────────────────

class _SheetSurface extends StatelessWidget {
  const _SheetSurface({
    required this.colors,
    this.title,
    this.subtitle,
    this.headerAction,
    required this.scrollController,
    required this.onClose,
    required this.statusBarHeight,
    required this.child,
  });

  final D3ColorTokens colors;
  final String? title;
  final String? subtitle;
  final Widget? headerAction;
  final ScrollController scrollController;
  final VoidCallback onClose;
  final double statusBarHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // The entire surface must be a single CustomScrollView using the
    // scrollController provided by DraggableScrollableSheet. This is what
    // enables drag detection across the whole sheet — including the handle
    // and header — not just inside the scrollable content area.
    //
    // The drag handle + header are pinned via SliverPersistentHeader so they
    // remain visible at the top while the body content scrolls beneath them.
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Material(
        color: colors.surface,
        child: CustomScrollView(
          controller: scrollController,
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickySheetHeaderDelegate(
                colors: colors,
                topPadding: statusBarHeight,
                title: title,
                subtitle: subtitle,
                headerAction: headerAction,
                onClose: onClose,
              ),
            ),
            SliverFillRemaining(
              child: child,
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: MediaQuery.viewPaddingOf(context).bottom),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sticky header delegate
// ─────────────────────────────────────────────────────────────────────────────

// _DragHandle height:  padding-top(10) + bar(4) + padding-bottom(6) = 20
// _SheetHeader height: 48
const double _kStickyHeaderHeight = 68.0;

class _StickySheetHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _StickySheetHeaderDelegate({
    required this.colors,
    required this.topPadding,
    this.title,
    this.subtitle,
    this.headerAction,
    required this.onClose,
  });

  final D3ColorTokens colors;
  final double topPadding;
  final String? title;
  final String? subtitle;
  final Widget? headerAction;
  final VoidCallback onClose;

  @override
  double get minExtent => _kStickyHeaderHeight + topPadding;

  @override
  double get maxExtent => _kStickyHeaderHeight + topPadding;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: colors.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: topPadding),
          _DragHandle(colors: colors),
          _SheetHeader(
            title: title,
            subtitle: subtitle,
            headerAction: headerAction,
            colors: colors,
            onClose: onClose,
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_StickySheetHeaderDelegate old) =>
      old.title != title ||
      old.subtitle != subtitle ||
      old.topPadding != topPadding ||
      old.headerAction != headerAction;
}

// ─────────────────────────────────────────────────────────────────────────────
// Drag handle
// ─────────────────────────────────────────────────────────────────────────────

class _DragHandle extends StatelessWidget {
  const _DragHandle({required this.colors});
  final D3ColorTokens colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 6),
      child: Center(
        child: Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: colors.outline.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sheet header
// ─────────────────────────────────────────────────────────────────────────────

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({
    this.title,
    this.subtitle,
    this.headerAction,
    required this.colors,
    required this.onClose,
  });

  final String? title;
  final String? subtitle;
  final Widget? headerAction;
  final D3ColorTokens colors;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colors.outline.withValues(alpha: 0.15),
            width: 0.5,
          ),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Center: title + subtitle ──────────────────────────────────
          if (title != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 80),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: D3TypeScale.titleLgSize,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface,
                      height: D3TypeFace.tight,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: D3TypeScale.labelMdSize,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),

          // ── Left: optional headerAction ───────────────────────────────
          if (headerAction != null)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: headerAction!,
              ),
            ),

          // ── Right: Cancel ─────────────────────────────────────────────
          Align(
            alignment: Alignment.centerRight,
            child: Semantics(
              button: true,
              label: 'Cancel',
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onClose,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: D3TypeScale.titleMdSize,
                      fontWeight: FontWeight.w400,
                      color: colors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
