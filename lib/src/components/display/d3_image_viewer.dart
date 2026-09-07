import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:d3_ui/src/tokens/d3_spacing.dart';

// ─────────────────────────────────────────────────────────────────────────────
// D3ImageSource
// ─────────────────────────────────────────────────────────────────────────────

/// Describes a single image shown inside [D3ImageViewer].
///
/// Use [D3ImageSource.local] for file-system paths (e.g. a freshly captured
/// photo) and [D3ImageSource.network] for remote URLs.
class D3ImageSource {
  const D3ImageSource.local(this.path) : isLocal = true;
  const D3ImageSource.network(this.path) : isLocal = false;

  final String path;
  final bool isLocal;
}

// ─────────────────────────────────────────────────────────────────────────────
// D3ImageViewer
// ─────────────────────────────────────────────────────────────────────────────

/// Full-screen, pageable image viewer styled for the d3 design system.
///
/// Renders [images] as a horizontal [PageView] with pinch-to-zoom
/// ([InteractiveViewer]). Navigation arrows and dot indicators are shown
/// automatically when there are multiple images.
///
/// **Opening it**
///
/// Prefer [push] over pushing this widget directly with a plain
/// `MaterialPageRoute` -- it also drags down to dismiss (unzoomed, one
/// finger), and that gesture is meant to visibly reveal the screen
/// underneath as it moves, which needs the route itself to be
/// non-opaque. [push] sets that up; a plain route would still show the
/// viewer correctly, it just would not reveal anything behind it while
/// dragging.
///
/// **Customising the AppBar**
///
/// Pass any widgets to [actions] to add trailing buttons — typically icon
/// buttons for share, delete, download, etc. The caller owns the interaction
/// logic (confirmation dialogs, state mutations) so the viewer stays generic:
///
/// ```dart
/// D3ImageViewer(
///   images: receipts,
///   initialIndex: tappedIndex,
///   actions: [
///     IconButton(
///       icon: const Icon(Icons.delete_outline, color: Colors.white),
///       tooltip: 'Delete',
///       onPressed: () async {
///         final ok = await D3Dialog.show(context, ...);
///         if (ok == true && context.mounted) {
///           onDelete(viewer.currentIndex);
///           Navigator.of(context).pop();
///         }
///       },
///     ),
///   ],
/// )
/// ```
///
/// **Accessing the current index from actions**
///
/// Wrap the viewer in a [ValueListenableBuilder] keyed to a
/// [ValueNotifier<int>] if you need the current page from an external scope.
/// Alternatively pass a callback via [onPageChanged].
class D3ImageViewer extends StatefulWidget {
  const D3ImageViewer({
    super.key,
    required this.images,
    this.initialIndex = 0,
    this.title,
    this.actions = const [],
    this.actionsBuilder,
    this.onPageChanged,
    this.emptyText = 'No images',
    this.resolveImage,
  }) : assert(
         actions.length == 0 || actionsBuilder == null,
         'pass at most one of actions/actionsBuilder',
       );

  /// Images to display. Must not be empty.
  final List<D3ImageSource> images;

  /// Zero-based index of the image to show first.
  final int initialIndex;

  /// Optional AppBar title widget. When null the counter ("1 / 3") is shown
  /// for multi-image sets and nothing for single images.
  final Widget? title;

  /// Widgets added to the AppBar trailing area, fixed for the whole viewer
  /// session regardless of which page is showing.
  ///
  /// Use [actionsBuilder] instead when the right actions depend on which
  /// image is currently visible (e.g. one image in the set has an action
  /// the others don't) — passing both is a caller error.
  final List<Widget> actions;

  /// Like [actions], but re-evaluated on every page change with the
  /// current zero-based index, so the AppBar's trailing buttons can differ
  /// per image rather than being fixed for the whole viewer session.
  ///
  /// ```dart
  /// D3ImageViewer(
  ///   images: photos,
  ///   actionsBuilder: (index) => [
  ///     if (photos[index].hasMarkup)
  ///       IconButton(icon: const Icon(Icons.download), onPressed: ...),
  ///   ],
  /// )
  /// ```
  final List<Widget> Function(int index)? actionsBuilder;

  /// Called whenever the page changes. Receives the new zero-based index.
  final ValueChanged<int>? onPageChanged;

  /// Text shown when [images] is empty.
  final String emptyText;

  /// Resolves the *actual* image to show for a given index,
  /// asynchronously, called once per index the first time it becomes
  /// the current page (on initial build and again after each page
  /// change) -- not on every rebuild, and not for pages the user never
  /// visits.
  ///
  /// The corresponding entry from [images] is shown immediately while
  /// this resolves, then swapped in place (the same `replaceImage`
  /// mechanism a caller can also trigger manually via
  /// `D3ImageViewerState`) once it completes -- so a slow resolution
  /// never blocks the viewer from opening, it just briefly shows the
  /// passed-in source first.
  ///
  /// For a caller whose real image needs a transform [images] itself
  /// can't express up front (e.g. an annotated photo that must be
  /// flattened before it can be *shown*, not just before it can be
  /// shared) -- resolving eagerly for every entry in [images] would
  /// waste that transform's cost on pages the user may never scroll to;
  /// this defers it to exactly the pages actually viewed.
  ///
  /// ```dart
  /// D3ImageViewer(
  ///   images: [for (final p in photos) D3ImageSource.local(p.path)],
  ///   resolveImage: (index) async {
  ///     final photo = photos[index];
  ///     if (photo.annotations == null) return D3ImageSource.local(photo.path);
  ///     final flattened = await flatten(photo);
  ///     return D3ImageSource.local(flattened);
  ///   },
  /// )
  /// ```
  final Future<D3ImageSource> Function(int index)? resolveImage;

  /// Pushes a [D3ImageViewer] via a non-opaque route, so its own
  /// swipe-down-to-dismiss drag visibly reveals the screen underneath
  /// as it moves -- a plain `Navigator.push(MaterialPageRoute(...))`
  /// paints an opaque barrier that hides whatever's behind regardless
  /// of the viewer's own [Opacity], since the route beneath is either
  /// not kept in the tree at all or is painted over. Prefer this over
  /// pushing [D3ImageViewer] directly whenever the drag-to-dismiss
  /// reveal is wanted (which is always, for this widget) -- the plain
  /// route form still works but the reveal effect will not show.
  static Future<T?> push<T>(
    BuildContext context, {
    required List<D3ImageSource> images,
    int initialIndex = 0,
    Widget? title,
    List<Widget> actions = const [],
    List<Widget> Function(int index)? actionsBuilder,
    ValueChanged<int>? onPageChanged,
    String emptyText = 'No images',
    Future<D3ImageSource> Function(int index)? resolveImage,
  }) {
    return Navigator.of(context).push<T>(
      PageRouteBuilder<T>(
        opaque: false,
        barrierColor: Colors.transparent,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (context, _, _) => D3ImageViewer(
          images: images,
          initialIndex: initialIndex,
          title: title,
          actions: actions,
          actionsBuilder: actionsBuilder,
          onPageChanged: onPageChanged,
          emptyText: emptyText,
          resolveImage: resolveImage,
        ),
      ),
    );
  }

  @override
  State<D3ImageViewer> createState() => D3ImageViewerState();
}

// Public state so callers can read [currentIndex] via a GlobalKey if needed.
class D3ImageViewerState extends State<D3ImageViewer>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late int _currentIndex;

  /// One [TransformationController] per currently-built page, so the
  /// dismiss gesture below (owned here, at the whole-screen level) can
  /// check whether the *current* page is zoomed in without reaching
  /// into each page's own private state. Populated lazily as pages
  /// build, matching the same per-index-key pattern `D3PhotoStrip` uses
  /// for its own thumbnails -- entries for indices no longer valid are
  /// pruned in [build] rather than left to accumulate.
  final Map<int, TransformationController> _zoomControllers = {};

  TransformationController _zoomControllerFor(int index) {
    return _zoomControllers.putIfAbsent(index, TransformationController.new);
  }

  bool get _currentPageIsZoomed {
    final controller = _zoomControllers[_currentIndex];
    if (controller == null) return false;
    return controller.value.getMaxScaleOnAxis() > 1.01;
  }

  late final AnimationController _snapBack = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  )..addListener(() {
      setState(() => _dragDy = _snapBackStart * (1 - _snapBack.value));
    });

  /// [_dragDy] at the moment a snap-back animation starts -- read by the
  /// listener above on every tick. A field rather than a captured local
  /// so the listener can be registered once in the initializer instead
  /// of being re-added (and left stacked, one extra call per past
  /// release) every time [_animateSnapBack] runs.
  double _snapBackStart = 0;

  /// How far the whole screen has been dragged down this
  /// swipe-to-dismiss gesture, in logical pixels. Drives the
  /// translate/fade/scale in [build]; reset to 0 once a drag ends
  /// (whether it dismissed or snapped back).
  double _dragDy = 0;

  /// Past this many logical pixels of downward drag, releasing
  /// dismisses instead of snapping back. Unaffected by screen size --
  /// deliberately a fixed, hand-feel distance rather than e.g. a
  /// fraction of screen height, so it takes the same amount of thumb
  /// travel on a small phone as a large tablet.
  static const double _dismissThreshold = 120;

  /// Local, mutable copy of [D3ImageViewer.images] -- seeded from it, but
  /// evolves independently afterward via [replaceImage], the same way
  /// [_currentIndex] is seeded from [D3ImageViewer.initialIndex] but then
  /// tracked as this state's own value. Needed because [replaceImage]
  /// has to change what's actually painted without the caller rebuilding
  /// this whole widget (and, with it, the route/PageView/scroll position
  /// it lives in) from further up the tree.
  late List<D3ImageSource> _images;

  /// Indices [D3ImageViewer.resolveImage] has already been called for
  /// (successfully or not) -- so revisiting a page, or any other
  /// rebuild, never calls it a second time for the same index.
  final Set<int> _resolved = {};

  /// The zero-based index of the currently visible image.
  int get currentIndex => _currentIndex;

  int get _count => _images.length;

  @override
  void initState() {
    super.initState();
    _images = List.of(widget.images);
    _currentIndex = _images.isEmpty
        ? 0
        : widget.initialIndex.clamp(0, _count - 1);
    _pageController = PageController(initialPage: _currentIndex);
    _resolveCurrentIfNeeded();
  }

  @override
  void didUpdateWidget(covariant D3ImageViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A normal declarative rebuild from further up the tree (the parent
    // passed a genuinely new `images` list) still takes effect --
    // [replaceImage] is an additional, imperative way to update this
    // state, not a replacement for the ordinary Flutter data flow.
    if (!identical(widget.images, oldWidget.images)) {
      _images = List.of(widget.images);
      _resolved.clear();
      if (_currentIndex >= _images.length) {
        _currentIndex = _images.isEmpty ? 0 : _images.length - 1;
      }
      _resolveCurrentIfNeeded();
    }
  }

  /// Calls [D3ImageViewer.resolveImage] for [_currentIndex], exactly
  /// once per index, swapping the result in via [replaceImage] when (if)
  /// it resolves. A no-op when [D3ImageViewer.resolveImage] is null, the
  /// index is already resolved, or [_images] is empty.
  void _resolveCurrentIfNeeded() {
    final resolver = widget.resolveImage;
    if (resolver == null || _images.isEmpty) return;
    final index = _currentIndex;
    if (!_resolved.add(index)) return;

    resolver(index).then((source) {
      if (!mounted) return;
      replaceImage(index, source);
    });
  }

  /// Swaps the image shown at [index] for [source], in place -- for a
  /// caller that produces a new version of one image *after* this
  /// viewer is already on screen (e.g. an edit/annotation flow whose own
  /// screen pops back into this one) and wants the update to appear
  /// immediately, without leaving and re-entering the viewer.
  ///
  /// Does not touch [D3ImageViewer.images] itself or notify the widget
  /// that built this viewer -- if the caller's own underlying data
  /// (e.g. a list of file paths it owns) also needs updating so a later,
  /// fresh build of this viewer shows the same replacement, that is the
  /// caller's separate responsibility.
  void replaceImage(int index, D3ImageSource source) {
    if (index < 0 || index >= _images.length) return;
    setState(() => _images[index] = source);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _snapBack.dispose();
    for (final controller in _zoomControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _goTo(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  /// Whether the interaction currently in progress on [InteractiveViewer]
  /// started as (and has stayed) a single-finger touch -- set in
  /// [_onInteractionStart], read in [_onInteractionUpdate]/
  /// [_onInteractionEnd] to decide whether this interaction is "our"
  /// dismiss drag at all. Needed because [InteractiveViewer]'s own
  /// callbacks fire for *every* interaction it handles (pans, pinches,
  /// and everything between), not just the single-finger case this
  /// gesture cares about.
  bool _dragIsSingleFinger = false;

  void _onInteractionStart(ScaleStartDetails details) {
    _dragIsSingleFinger = details.pointerCount == 1;
  }

  void _onInteractionUpdate(ScaleUpdateDetails details) {
    if (_currentPageIsZoomed || !_dragIsSingleFinger) return;
    // A second finger touching down mid-gesture changes pointerCount
    // without a fresh onInteractionStart -- once that happens this is
    // no longer "our" gesture (a pinch is starting), so stop treating
    // further updates as dismiss drag and let InteractiveViewer's own
    // pan/scale handling take over from here for the rest of this
    // interaction.
    if (details.pointerCount != 1) {
      _dragIsSingleFinger = false;
      _animateSnapBack();
      return;
    }
    setState(
      () => _dragDy = (_dragDy + details.focalPointDelta.dy).clamp(0, 400),
    );
  }

  void _onInteractionEnd(ScaleEndDetails details) {
    if (!_dragIsSingleFinger) return;
    // Dismiss either on distance (dragged past the threshold) or on a
    // fast downward flick released before reaching it -- matching how
    // e.g. iOS/Google Photos treat a quick flick as clear dismiss
    // intent even if the finger didn't travel far.
    final pastThreshold = _dragDy > _dismissThreshold;
    final fastFlick = details.velocity.pixelsPerSecond.dy > 800;
    if (pastThreshold || fastFlick) {
      Navigator.maybePop(context);
      return;
    }
    _animateSnapBack();
  }

  void _animateSnapBack() {
    _snapBackStart = _dragDy;
    _snapBack
      ..reset()
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    if (_images.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Text(
            widget.emptyText,
            style: const TextStyle(color: Colors.white54),
          ),
        ),
      );
    }

    final defaultTitle = _count > 1
        ? Text(
            '${_currentIndex + 1} / $_count',
            style: const TextStyle(color: Colors.white),
          )
        : null;

    // Stale entries (an index no longer present, e.g. after replaceImage
    // shrinks the effective count -- doesn't happen today but keeps this
    // correct if it ever does) are pruned rather than left to accumulate.
    _zoomControllers.removeWhere((index, controller) {
      final stale = index >= _count;
      if (stale) controller.dispose();
      return stale;
    });

    final scaffold = Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: widget.title ?? defaultTitle,
        actions: widget.actionsBuilder?.call(_currentIndex) ?? widget.actions,
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _count,
            onPageChanged: (i) {
              setState(() => _currentIndex = i);
              _resolveCurrentIfNeeded();
              widget.onPageChanged?.call(i);
            },
            itemBuilder: (context, index) {
              final isCurrent = index == _currentIndex;
              return _D3ViewerPage(
                source: _images[index],
                zoomController: _zoomControllerFor(index),
                // Only the current page's interactions can mean
                // anything to the whole-screen dismiss gesture -- a
                // pre-built neighbour (PageView keeps adjacent pages
                // around for swipe pre-caching) receives no touches of
                // its own to report.
                onInteractionStart: isCurrent ? _onInteractionStart : null,
                onInteractionUpdate: isCurrent ? _onInteractionUpdate : null,
                onInteractionEnd: isCurrent ? _onInteractionEnd : null,
              );
            },
          ),

          // Left arrow
          if (_count > 1 && _currentIndex > 0)
            _NavArrow(
              alignment: Alignment.centerLeft,
              icon: Icons.chevron_left,
              onTap: () => _goTo(_currentIndex - 1),
            ),

          // Right arrow
          if (_count > 1 && _currentIndex < _count - 1)
            _NavArrow(
              alignment: Alignment.centerRight,
              icon: Icons.chevron_right,
              onTap: () => _goTo(_currentIndex + 1),
            ),

          // Dot indicators
          if (_count > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_count, (i) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _currentIndex ? 10 : 6,
                    height: i == _currentIndex ? 10 : 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == _currentIndex
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.4),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );

    // The whole screen (AppBar, body, everything) drags and fades
    // together, like a modal being pulled off screen -- not just the
    // image inside a fixed frame. Scale/opacity both max out well
    // before _dismissThreshold so the screen already reads as
    // "about to close" at the moment it actually would.
    final progress = (_dragDy / _dismissThreshold).clamp(0.0, 1.0);
    final screenScale = 1 - progress * 0.1;
    final screenOpacity = 1 - progress * 0.4;

    return Transform.translate(
      offset: Offset(0, _dragDy),
      child: Opacity(
        opacity: screenOpacity,
        child: Transform.scale(scale: screenScale, child: scaffold),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _D3ViewerPage
// ─────────────────────────────────────────────────────────────────────────────

/// One page of [D3ImageViewer]: the zoomable image.
///
/// [zoomController] is owned by [D3ImageViewerState], not this widget --
/// the whole-screen swipe-down-to-dismiss gesture (also owned there)
/// needs to read the *current* page's zoom level to decide whether a
/// vertical drag should dismiss or be left for [InteractiveViewer] to
/// pan with, and reaching into a StatefulWidget's own private State from
/// outside is not possible, so the controller is threaded in instead.
///
/// [onInteractionStart]/[onInteractionUpdate]/[onInteractionEnd] forward
/// straight to [InteractiveViewer]'s own identically-named callbacks --
/// this is what actually drives the whole-screen dismiss gesture,
/// rather than a sibling [GestureDetector]/[RawGestureDetector]
/// competing with [InteractiveViewer] for the same pointer. That
/// approach (tried first) could not be made reliable:
/// [InteractiveViewer] always registers its own `ScaleGestureRecognizer`
/// once mounted, and a sibling recognizer's odds of resolving the
/// gesture arena first for a single-finger drag turned out to depend on
/// where on screen the drag started (confirmed on-device: the dismiss
/// drag worked reliably from the AppBar, where nothing else was
/// competing, but not from over the image itself, where it was racing
/// InteractiveViewer and often losing). [InteractiveViewer]'s own
/// interaction callbacks sidestep the race entirely -- they fire for
/// every gesture it handles regardless of who "wins" anything, since
/// there is no competing recognizer to win against, and
/// [ScaleStartDetails]/[ScaleUpdateDetails]/[ScaleEndDetails] all carry
/// a `pointerCount` field, which is what actually distinguishes "this
/// is a single-finger drag" from "this is a pinch" here.
class _D3ViewerPage extends StatelessWidget {
  const _D3ViewerPage({
    required this.source,
    required this.zoomController,
    this.onInteractionStart,
    this.onInteractionUpdate,
    this.onInteractionEnd,
  });

  final D3ImageSource source;
  final TransformationController zoomController;
  final GestureScaleStartCallback? onInteractionStart;
  final GestureScaleUpdateCallback? onInteractionUpdate;
  final GestureScaleEndCallback? onInteractionEnd;

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: zoomController,
      minScale: 0.5,
      maxScale: 6.0,
      onInteractionStart: onInteractionStart,
      onInteractionUpdate: onInteractionUpdate,
      onInteractionEnd: onInteractionEnd,
      child: Center(
        child: _D3ViewerImage(source: source),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _NavArrow
// ─────────────────────────────────────────────────────────────────────────────

class _NavArrow extends StatelessWidget {
  const _NavArrow({
    required this.alignment,
    required this.icon,
    required this.onTap,
  });

  final Alignment alignment;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: D3Spacing.s8),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(D3Spacing.s8),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _D3ViewerImage
// ─────────────────────────────────────────────────────────────────────────────

class _D3ViewerImage extends StatelessWidget {
  const _D3ViewerImage({required this.source});

  final D3ImageSource source;

  @override
  Widget build(BuildContext context) {
    if (source.isLocal) {
      return Image.file(
        File(source.path),
        fit: BoxFit.contain,
        errorBuilder: (ctx, err, st) => const _ErrorPlaceholder(),
      );
    }
    return Image.network(
      source.path,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      },
      errorBuilder: (ctx, err, st) => const _ErrorPlaceholder(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ErrorPlaceholder
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorPlaceholder extends StatelessWidget {
  const _ErrorPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.broken_image_outlined, color: Colors.white54, size: 64),
        SizedBox(height: 12),
        Text('Could not load image', style: TextStyle(color: Colors.white54)),
      ],
    );
  }
}
