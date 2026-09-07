import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:d3_ui/d3_ui.dart';

// ─────────────────────────────────────────────────────────────────────────────
// D3PhotoGallery
// ─────────────────────────────────────────────────────────────────────────────

/// A wrapping grid of local-file photo thumbnails with an accessible
/// remove affordance and tap-to-view wiring into [D3ImageViewer].
///
/// Generalizes a pattern that appears independently across several apps
/// (checklist items, amendment screens, report content): a grid of square
/// thumbnails, each opening a full-screen [D3ImageViewer] on tap, with an
/// optional remove button per thumbnail. Centralizing it here fixes
/// touch-target and semantics gaps once instead of per call site — the
/// remove button's hit area meets the 48dp Material minimum regardless of
/// its visible glyph size (see [D3PhotoGalleryTokens]).
///
/// Wraps to as many rows as needed rather than scrolling horizontally
/// (originally `D3PhotoStrip`, a single scrolling row) — every photo, and
/// [onAdd]'s tile, is glanceable at once with no scroll gesture needed to
/// discover them. Reported on-device: with a single scrolling row, once
/// enough thumbnails filled the visible width the add-photo tile (always
/// the last item) scrolled out of view with no visual hint it was still
/// there, making it effectively undiscoverable once an item already had a
/// handful of photos. A caller embeds this in a layout that itself scrolls
/// (a checklist item's own card, already variable-height for other reasons
/// — the note field, status controls), so a taller grid for a photo-heavy
/// item is consistent with how the rest of that layout already behaves.
///
/// ```dart
/// D3PhotoGallery(
///   photoPaths: item.photoPaths,
///   itemLabel: item.text,
///   onRemove: (index) => removePhoto(item.id, index),
/// )
///
/// // Read-only (e.g. report/detail views) — omit onRemove.
/// D3PhotoGallery(
///   photoPaths: result.photoPaths,
///   itemLabel: result.itemText,
/// )
/// ```
class D3PhotoGallery extends StatefulWidget {
  const D3PhotoGallery({
    super.key,
    required this.photoPaths,
    required this.itemLabel,
    this.onRemove,
    this.viewerTitle,
    this.onAdd,
    this.viewerActionsBuilder,
    this.viewerResolveImage,
    this.thumbnailResolveImage,
  });

  /// Local file paths, in display order.
  final List<String> photoPaths;

  /// Describes what these photos belong to (e.g. the checklist item's
  /// text) — used to build each thumbnail's `Semantics` label ("Photo 2 of
  /// 3 for `itemLabel`").
  final String itemLabel;

  /// Called with the tapped photo's index when its remove button is
  /// pressed. When null, no remove button is shown (read-only gallery).
  final ValueChanged<int>? onRemove;

  /// Optional title widget for the full-screen [D3ImageViewer]. Defaults to
  /// the viewer's own "N / M" counter.
  final Widget? viewerTitle;

  /// When provided, an image-thumbnail-shaped `+` tile (sized to match
  /// the photo thumbnails) is appended after the last photo, and the
  /// gallery renders even when [photoPaths] is empty (just the tile
  /// alone) instead of collapsing to nothing. Use this instead of a
  /// separate "Add photo" button below the gallery so adding a photo
  /// reads as "an empty photo slot," not a generic action — and so
  /// callers don't need to reimplement this gallery's own thumbnail
  /// rendering just to add a trailing tile.
  final VoidCallback? onAdd;

  /// Extra AppBar trailing buttons for the full-screen viewer, forwarded
  /// straight into [D3ImageViewer.actionsBuilder] -- this gallery only
  /// ever deals in plain file paths/thumbnails, so it has no opinion on
  /// what those actions are or do; the caller supplies whatever a given
  /// photo needs (e.g. "Annotate"/"Download" for an app that marks up
  /// photos), keyed by the same zero-based index [photoPaths] uses.
  ///
  /// Re-evaluated as the user swipes between photos inside one viewer
  /// session, so actions stay correct for whichever photo is actually
  /// showing rather than being fixed to the one first tapped.
  final List<Widget> Function(int index)? viewerActionsBuilder;

  /// Forwarded straight into [D3ImageViewer.resolveImage] -- for a
  /// caller whose real display image needs an async transform this
  /// gallery's own plain `photoPaths` can't express (e.g. flattening
  /// annotations onto a photo before it can be *shown*, not just before
  /// it can be shared). Called once per photo the first time it becomes
  /// the visible page, not for every thumbnail up front.
  final Future<D3ImageSource> Function(int index)? viewerResolveImage;

  /// Like [viewerResolveImage], but for a thumbnail in this gallery
  /// itself rather than the full-screen viewer -- returns a local file
  /// path (a thumbnail is always a plain [Image.file], never network),
  /// resolved once per thumbnail as soon as it's built, showing
  /// [photoPaths]'s own entry immediately while it resolves.
  ///
  /// Unlike the viewer (one visible page at a time), every thumbnail in
  /// the gallery is live at once, so this runs for every visible
  /// thumbnail up front rather than being deferred to an as-visited
  /// basis -- a caller doing real work here (e.g. flattening
  /// annotations) should keep it cheap or already-cached at its own
  /// layer, since a long gallery means many concurrent calls.
  final Future<String> Function(int index)? thumbnailResolveImage;

  @override
  State<D3PhotoGallery> createState() => D3PhotoGalleryState();
}

class D3PhotoGalleryState extends State<D3PhotoGallery> {
  /// One key per currently-built thumbnail, so [refreshThumbnail] can
  /// reach a specific `_D3PhotoThumbnailState` without this gallery being
  /// a `StatelessWidget` wrapper the caller has no handle into. Rebuilt
  /// alongside the grid itself rather than cached across rebuilds --
  /// `GlobalKey`s are cheap and a stale one pointing at an unmounted
  /// thumbnail is worse than a fresh one each build.
  final Map<int, GlobalKey<_D3PhotoThumbnailState>> _thumbnailKeys = {};

  /// Forces the thumbnail at [index] to re-run `thumbnailResolveImage`,
  /// discarding whatever it last resolved to.
  ///
  /// Needed because a thumbnail only re-resolves on its own when
  /// [D3PhotoGallery.photoPaths]'s entry at that position actually
  /// changes -- an external event that changes what the resolver would
  /// now return (e.g. a photo's annotations were just edited on a
  /// screen pushed from this gallery's own viewer) leaves the thumbnail
  /// showing whatever it last resolved to. Call this once that event is
  /// known, mirroring how `D3ImageViewerState.replaceImage` lets a
  /// caller push a fresh image into an already-built viewer.
  ///
  /// **Caution:** the re-run reads whatever `thumbnailResolveImage`
  /// itself reads (often ambient app state, e.g. a Riverpod provider) --
  /// if that state hasn't actually finished updating yet by the time
  /// this is called, the resolver re-runs against the *old* value and
  /// this is a no-op in effect. A caller that already has the exact
  /// path to show (rather than needing it re-derived) should use
  /// [replaceThumbnail] instead, which has no such dependency.
  void refreshThumbnail(int index) {
    _thumbnailKeys[index]?.currentState?.refresh();
  }

  /// Sets the thumbnail at [index] to show [path] directly, with no
  /// re-run of `thumbnailResolveImage` and no dependency on any ambient
  /// state being current -- the imperative counterpart to
  /// [refreshThumbnail], for a caller that already knows the exact
  /// path to show (e.g. it just produced that file itself) rather than
  /// needing the resolver consulted again. Mirrors
  /// `D3ImageViewerState.replaceImage` exactly.
  void replaceThumbnail(int index, String path) {
    _thumbnailKeys[index]?.currentState?.replace(path);
  }

  void _openViewer(BuildContext context, int index) {
    D3ImageViewer.push(
      context,
      images: [for (final p in widget.photoPaths) D3ImageSource.local(p)],
      initialIndex: index,
      title: widget.viewerTitle,
      actionsBuilder: widget.viewerActionsBuilder,
      resolveImage: widget.viewerResolveImage,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.photoPaths.isEmpty && widget.onAdd == null) {
      return const SizedBox.shrink();
    }

    final tokens = context.d3PhotoGalleryTokens;

    _thumbnailKeys.removeWhere((index, _) => index >= widget.photoPaths.length);

    return Wrap(
      spacing: tokens.thumbnailGap,
      runSpacing: tokens.thumbnailGap,
      children: [
        for (var index = 0; index < widget.photoPaths.length; index++)
          _D3PhotoThumbnail(
            key: _thumbnailKeys.putIfAbsent(
              index,
              () => GlobalKey<_D3PhotoThumbnailState>(),
            ),
            path: widget.photoPaths[index],
            index: index,
            count: widget.photoPaths.length,
            itemLabel: widget.itemLabel,
            tokens: tokens,
            resolveImage: widget.thumbnailResolveImage,
            onTap: () => _openViewer(context, index),
            onRemove: widget.onRemove == null
                ? null
                : () => widget.onRemove!(index),
          ),
        if (widget.onAdd != null)
          _D3AddPhotoTile(onTap: widget.onAdd!, tokens: tokens),
      ],
    );
  }
}

class _D3AddPhotoTile extends StatelessWidget {
  const _D3AddPhotoTile({required this.onTap, required this.tokens});

  final VoidCallback onTap;
  final D3PhotoGalleryTokens tokens;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    final radius = BorderRadius.circular(tokens.thumbnailRadius);

    return Semantics(
      label: 'Add photo',
      button: true,
      child: SizedBox(
        width: tokens.thumbnailSize,
        height: tokens.thumbnailSize,
        child: Material(
          color: colors.surfaceContainerHigh,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: BorderSide(color: colors.outline.withValues(alpha: 0.4)),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Center(
              child: Icon(Icons.add, color: colors.onSurfaceVariant),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _D3PhotoThumbnail
// ─────────────────────────────────────────────────────────────────────────────

class _D3PhotoThumbnail extends StatefulWidget {
  const _D3PhotoThumbnail({
    super.key,
    required this.path,
    required this.index,
    required this.count,
    required this.itemLabel,
    required this.tokens,
    required this.onTap,
    required this.onRemove,
    this.resolveImage,
  });

  final String path;
  final int index;
  final int count;
  final String itemLabel;
  final D3PhotoGalleryTokens tokens;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  /// See `D3PhotoGallery.thumbnailResolveImage`.
  final Future<String> Function(int index)? resolveImage;

  @override
  State<_D3PhotoThumbnail> createState() => _D3PhotoThumbnailState();
}

class _D3PhotoThumbnailState extends State<_D3PhotoThumbnail> {
  /// `widget.path` until (if) `widget.resolveImage` resolves to
  /// something different -- shown immediately rather than waiting, the
  /// same "display now, swap when ready" pattern `D3ImageViewer
  /// .resolveImage` uses.
  late String _displayPath = widget.path;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didUpdateWidget(covariant _D3PhotoThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A genuinely different photo at this list position (e.g. the
    // caller's own underlying list changed) re-resolves from scratch;
    // resolveImage itself changing identity (a caller passing a new
    // closure on every rebuild, as an inline lambda commonly would)
    // must NOT retrigger this -- only the path actually changing means
    // there's a new photo to resolve.
    if (widget.path != oldWidget.path) {
      _displayPath = widget.path;
      _resolve();
    }
  }

  void _resolve() {
    final resolver = widget.resolveImage;
    if (resolver == null) return;
    resolver(widget.index).then((path) {
      if (!mounted) return;
      setState(() => _displayPath = path);
    });
  }

  /// See `D3PhotoGalleryState.refreshThumbnail`.
  void refresh() => _resolve();

  /// See `D3PhotoGalleryState.replaceThumbnail`.
  void replace(String path) => setState(() => _displayPath = path);

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    final radius = BorderRadius.circular(widget.tokens.thumbnailRadius);

    return Semantics(
      label: 'Photo ${widget.index + 1} of ${widget.count} for ${widget.itemLabel}',
      button: true,
      image: true,
      child: SizedBox(
        width: widget.tokens.thumbnailSize,
        height: widget.tokens.thumbnailSize,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Material(
              color: colors.surfaceVariant,
              shape: RoundedRectangleBorder(borderRadius: radius),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: widget.onTap,
                child: Image.file(
                  File(_displayPath),
                  width: widget.tokens.thumbnailSize,
                  height: widget.tokens.thumbnailSize,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Icon(
                    Icons.broken_image_outlined,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            if (widget.onRemove != null)
              Positioned(
                top: widget.tokens.removeButtonOffset,
                right: widget.tokens.removeButtonOffset,
                child: Semantics(
                  label: 'Remove photo ${widget.index + 1}',
                  button: true,
                  child: SizedBox(
                    width: widget.tokens.removeButtonHitSize,
                    height: widget.tokens.removeButtonHitSize,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: widget.onRemove,
                        child: Center(
                          child: Container(
                            width: widget.tokens.removeButtonGlyphSize,
                            height: widget.tokens.removeButtonGlyphSize,
                            decoration: BoxDecoration(
                              color: colors.error,
                              shape: BoxShape.circle,
                              border: Border.all(color: colors.surface, width: 1.5),
                            ),
                            child: Icon(
                              Icons.close,
                              size: widget.tokens.removeButtonGlyphSize * 0.7,
                              color: colors.onError,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
