import 'dart:math' as math;

import 'package:flutter/gestures.dart' show Drag;
import 'package:material_ui/material_ui.dart';

/// What a [D3ScrollOverSheetScaffold.topBar] builder needs to know about the
/// scroll position.
class D3ScrollOverSheetState {
  const D3ScrollOverSheetState({
    required this.progress,
    required this.anchorHidden,
    required this.barHeight,
    required this.scrollOffset,
  });

  /// 0 at rest, 1 once the sheet's top edge has reached the top bar. Use it
  /// to fade the bar's background in.
  final double progress;

  /// True once the scaffold's `anchorKey` widget is completely behind the top
  /// bar — the moment the bar can take over that widget's job (e.g. show its
  /// own search field).
  final bool anchorHidden;

  /// Status bar inset plus the bar's content height.
  final double barHeight;

  final double scrollOffset;
}

/// A page with a sheet that slides up over it, as in a food-delivery
/// restaurant screen: one vertical scroll, the [page] travelling at
/// [pageScrollRatio] of the finger's pace while the [sheet] travels 1:1, so
/// the sheet covers the page and finally the whole screen.
///
/// * [topBar] floats above everything and stays reachable at every scroll
///   position.
/// * [sticky] (optional) is drawn above the scroll view and pins just under
///   the top bar once the sheet reaches it — pinned slivers pin at y = 0,
///   behind the bar, so this is done with an overlay. Mark where it sits in
///   the sheet with an empty placeholder carrying [stickyPlaceholderKey]
///   (same height as [stickyHeight]).
/// * [anchorKey] marks a widget in the sheet (typically a search field). The
///   sheet is made tall enough that, scrolled fully up, that widget ends up
///   completely behind the top bar; [D3ScrollOverSheetState.anchorHidden]
///   then reports it.
///
/// The sheet is at least one viewport tall so it can always cover the page.
class D3ScrollOverSheetScaffold extends StatefulWidget {
  const D3ScrollOverSheetScaffold({
    super.key,
    required this.page,
    required this.sheet,
    required this.topBar,
    this.controller,
    this.pageScrollRatio = 0.5,
    this.topBarContentHeight = 72,
    this.anchorKey,
    this.anchorHideMargin = 4,
    this.sticky,
    this.stickyPlaceholderKey,
    this.stickyHeight = 0,
  });

  final Widget page;
  final Widget sheet;
  final Widget Function(BuildContext context, D3ScrollOverSheetState state)
  topBar;

  /// Supply one to share the scroll position (e.g. with a
  /// `D3SectionTabsController`); otherwise the scaffold owns its own.
  final ScrollController? controller;

  /// Page travel per pixel of scroll; the sheet always travels 1.0.
  final double pageScrollRatio;

  /// Height of the top bar below the status bar.
  final double topBarContentHeight;

  final GlobalKey? anchorKey;

  /// Extra room so the anchor ends up clearly, not exactly, behind the bar.
  final double anchorHideMargin;

  final Widget? sticky;
  final GlobalKey? stickyPlaceholderKey;
  final double stickyHeight;

  @override
  State<D3ScrollOverSheetScaffold> createState() =>
      _D3ScrollOverSheetScaffoldState();
}

class _D3ScrollOverSheetScaffoldState extends State<D3ScrollOverSheetScaffold> {
  ScrollController? _ownController;
  ScrollController get _controller =>
      widget.controller ?? (_ownController ??= ScrollController());

  final _pageKey = GlobalKey();
  final _sheetKey = GlobalKey();

  double _pageHeight = 0;
  double _anchorBottom = 0; // relative to the sheet's top
  double _stickyRestingOffset = 0; // relative to the sheet's top

  @override
  void dispose() {
    _ownController?.dispose();
    super.dispose();
  }

  double _offsetIn(GlobalKey key, RenderBox sheet) {
    final box = key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return 0;
    return box.localToGlobal(Offset.zero, ancestor: sheet).dy;
  }

  void _measure() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final page = _pageKey.currentContext?.size?.height ?? 0;
      var anchor = 0.0;
      var sticky = 0.0;
      final sheet = _sheetKey.currentContext?.findRenderObject() as RenderBox?;
      if (sheet != null && sheet.attached) {
        final anchorKey = widget.anchorKey;
        if (anchorKey != null) {
          final box =
              anchorKey.currentContext?.findRenderObject() as RenderBox?;
          if (box != null && box.attached) {
            anchor = _offsetIn(anchorKey, sheet) + box.size.height;
          }
        }
        final stickyKey = widget.stickyPlaceholderKey;
        if (stickyKey != null) sticky = _offsetIn(stickyKey, sheet);
      }
      if (page != _pageHeight ||
          anchor != _anchorBottom ||
          sticky != _stickyRestingOffset) {
        setState(() {
          _pageHeight = page;
          _anchorBottom = anchor;
          _stickyRestingOffset = sticky;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final barHeight =
        MediaQuery.paddingOf(context).top + widget.topBarContentHeight;
    _measure();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            CustomScrollView(
              controller: _controller,
              slivers: [
                SliverToBoxAdapter(
                  // Slivers paint first-on-top, so the page would otherwise
                  // draw over the sheet; clipping to its own box makes the
                  // sheet's top edge the page's bottom edge.
                  child: ClipRect(
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        final offset = _controller.hasClients
                            ? math.max(0.0, _controller.offset)
                            : 0.0;
                        // The page already scrolls 1:1 with the list; pushing
                        // it back by the remainder leaves it at
                        // `pageScrollRatio` of the finger's pace.
                        return Transform.translate(
                          offset: Offset(
                            0,
                            offset * (1 - widget.pageScrollRatio),
                          ),
                          child: child,
                        );
                      },
                      child: KeyedSubtree(key: _pageKey, child: widget.page),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: ConstrainedBox(
                    key: _sheetKey,
                    constraints: BoxConstraints(
                      minHeight: math.max(
                        0,
                        constraints.maxHeight -
                            barHeight +
                            _anchorBottom +
                            widget.anchorHideMargin,
                      ),
                    ),
                    child: widget.sheet,
                  ),
                ),
              ],
            ),
            if (widget.sticky != null)
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  if (_pageHeight == 0) return const SizedBox.shrink();
                  final offset = _controller.hasClients
                      ? _controller.offset
                      : 0.0;
                  final restingTop =
                      _pageHeight - offset + _stickyRestingOffset;
                  return Positioned(
                    top: math.max(barHeight, restingTop),
                    left: 0,
                    right: 0,
                    height: widget.stickyHeight,
                    child: _ScrollForwarder(
                      controller: _controller,
                      child: child!,
                    ),
                  );
                },
                child: widget.sticky!,
              ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: barHeight,
              child: _ScrollForwarder(
                controller: _controller,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    final offset = _controller.hasClients
                        ? _controller.offset
                        : 0.0;
                    final fadeRange = _pageHeight - barHeight;
                    final progress = fadeRange <= 0
                        ? 0.0
                        : (offset / fadeRange).clamp(0.0, 1.0);
                    final anchorHidden =
                        widget.anchorKey != null &&
                        _pageHeight > 0 &&
                        _pageHeight - offset + _anchorBottom <= barHeight;
                    return widget.topBar(
                      context,
                      D3ScrollOverSheetState(
                        progress: progress,
                        anchorHidden: anchorHidden,
                        barHeight: barHeight,
                        scrollOffset: offset,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Hands vertical drags that start on an overlay (the top bar, the sticky
/// widget) to the page's scroll position. The overlays sit above the scroll
/// view, so without this a swipe that begins on them scrolls nothing.
///
/// Uses [ScrollPosition.drag], so the scroll gets the platform's own physics,
/// including the fling when the finger lifts. Horizontal drags are untouched —
/// a horizontally scrolling child (a tab strip) still scrolls sideways.
class _ScrollForwarder extends StatefulWidget {
  const _ScrollForwarder({required this.controller, required this.child});

  final ScrollController controller;
  final Widget child;

  @override
  State<_ScrollForwarder> createState() => _ScrollForwarderState();
}

class _ScrollForwarderState extends State<_ScrollForwarder> {
  Drag? _drag;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onVerticalDragStart: (details) {
        if (!widget.controller.hasClients) return;
        _drag = widget.controller.position.drag(details, () => _drag = null);
      },
      onVerticalDragUpdate: (details) => _drag?.update(details),
      onVerticalDragEnd: (details) {
        _drag?.end(details);
        _drag = null;
      },
      onVerticalDragCancel: () {
        _drag?.cancel();
        _drag = null;
      },
      child: widget.child,
    );
  }
}
