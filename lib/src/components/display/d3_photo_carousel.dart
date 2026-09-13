import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:d3_ui/d3_ui.dart';

// ─────────────────────────────────────────────────────────────────────────────
// D3PhotoCarousel
// ─────────────────────────────────────────────────────────────────────────────

/// Swipeable inline photo carousel with a "peek" layout — adjacent photos
/// are partially visible at the edges, signalling there's more to swipe to
/// without needing dots (Google Photos/Airbnb-style; more discoverable than
/// a page indicator alone, since the affordance is visible before the user
/// even tries to swipe). The centered photo is full-scale; neighbors are
/// slightly scaled down and dimmed for depth. A small "N/total" pill
/// overlays the current photo when there's more than one. Tap to open the
/// full-screen [D3ImageViewer] at the current page. A single photo renders
/// as a plain static image — no page mechanics or peek needed for one item.
///
/// Ported from a site_inspector-local widget of the same shape, unused
/// there in favor of [D3PhotoGallery]'s grid-of-thumbnails layout — kept
/// here as a real, reusable alternative presentation (a single hero photo
/// per item reads differently than a thumbnail grid) rather than left as
/// dead code in an app.
///
/// ```dart
/// D3PhotoCarousel(
///   photoPaths: item.photoPaths,
///   itemLabel: item.text,
/// )
/// ```
class D3PhotoCarousel extends StatefulWidget {
  const D3PhotoCarousel({
    super.key,
    required this.photoPaths,
    required this.itemLabel,
  });

  /// Local file paths, in display order.
  final List<String> photoPaths;

  /// Used as the full-screen [D3ImageViewer]'s title.
  final String itemLabel;

  @override
  State<D3PhotoCarousel> createState() => _D3PhotoCarouselState();
}

class _D3PhotoCarouselState extends State<D3PhotoCarousel> {
  static const _viewportFraction = 0.82;

  late final _pageController = PageController(
    viewportFraction: _viewportFraction,
  );
  double _page = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_pageController.position.hasContentDimensions) return;
    setState(() => _page = _pageController.page ?? 0);
  }

  @override
  void dispose() {
    _pageController.removeListener(_onScroll);
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _openViewer(int index) async {
    // Tracks the page the user ends up on inside the full-screen viewer
    // (they may swipe further while it's open) so the inline carousel
    // can jump to match on return — keeps the user's place instead of
    // resetting to wherever they tapped in from.
    var exitIndex = index;
    await D3ImageViewer.push(
      context,
      images: [for (final p in widget.photoPaths) D3ImageSource.local(p)],
      initialIndex: index,
      title: Text(widget.itemLabel),
      onPageChanged: (i) => exitIndex = i,
    );
    if (!mounted || exitIndex == index) return;
    _pageController.animateToPage(
      exitIndex,
      duration: D3Motion.moderate,
      curve: D3Motion.standard,
    );
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.photoPaths.length;

    if (count == 1) {
      return ClipRRect(
        borderRadius: D3Radius.circularMd,
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: GestureDetector(
            onTap: () => _openViewer(0),
            child: _D3CarouselImage(path: widget.photoPaths[0]),
          ),
        ),
      );
    }

    final currentIndex = _page.round().clamp(0, count - 1);

    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            // padEnds:true (the default) centers every page, including
            // the first and last — each gets the same small margin on
            // its outer side that every other page has between
            // neighbors, rather than a jarring flush-left/flush-right
            // treatment only on the edges. True per-page asymmetry
            // (page 0 flush, others centered) would need custom scroll
            // physics — not worth the risk of a subtly-off snap feel
            // for a cosmetic margin difference.
            itemCount: count,
            itemBuilder: (context, index) {
              // Distance from the centered page, in pages — 0 when
              // centered, growing as it scrolls toward/past a neighbor.
              final distance = (index - _page).abs().clamp(0.0, 1.0);
              final scale = 1 - (distance * 0.08);
              final opacity = 1 - (distance * 0.35);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: D3Spacing.s6),
                child: Transform.scale(
                  scale: scale,
                  child: Opacity(
                    opacity: opacity,
                    child: ClipRRect(
                      borderRadius: D3Radius.circularMd,
                      child: GestureDetector(
                        onTap: () => _openViewer(index),
                        child: _D3CarouselImage(path: widget.photoPaths[index]),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            right: D3Spacing.s16 + D3Spacing.s6,
            bottom: D3Spacing.s10,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: D3Spacing.s8,
                  vertical: D3Spacing.s2,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: D3Radius.circularFull,
                ),
                child: Text(
                  '${currentIndex + 1}/$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
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

class _D3CarouselImage extends StatelessWidget {
  const _D3CarouselImage({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    return Image.file(
      File(path),
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => ColoredBox(
        color: colors.surfaceContainerHigh,
        child: Icon(
          Icons.broken_image_outlined,
          color: colors.onSurfaceVariant,
        ),
      ),
    );
  }
}
