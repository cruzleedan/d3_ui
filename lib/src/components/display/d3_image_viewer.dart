import 'dart:io';

import 'package:flutter/material.dart';
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
    this.onPageChanged,
    this.emptyText = 'No images',
  });

  /// Images to display. Must not be empty.
  final List<D3ImageSource> images;

  /// Zero-based index of the image to show first.
  final int initialIndex;

  /// Optional AppBar title widget. When null the counter ("1 / 3") is shown
  /// for multi-image sets and nothing for single images.
  final Widget? title;

  /// Widgets added to the AppBar trailing area.
  final List<Widget> actions;

  /// Called whenever the page changes. Receives the new zero-based index.
  final ValueChanged<int>? onPageChanged;

  /// Text shown when [images] is empty.
  final String emptyText;

  @override
  State<D3ImageViewer> createState() => D3ImageViewerState();
}

// Public state so callers can read [currentIndex] via a GlobalKey if needed.
class D3ImageViewerState extends State<D3ImageViewer> {
  late final PageController _pageController;
  late int _currentIndex;

  /// The zero-based index of the currently visible image.
  int get currentIndex => _currentIndex;

  int get _count => widget.images.length;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.images.isEmpty
        ? 0
        : widget.initialIndex.clamp(0, _count - 1);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
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

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: widget.title ?? defaultTitle,
        actions: widget.actions,
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _count,
            onPageChanged: (i) {
              setState(() => _currentIndex = i);
              widget.onPageChanged?.call(i);
            },
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 6.0,
                child: Center(
                  child: _D3ViewerImage(source: widget.images[index]),
                ),
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
