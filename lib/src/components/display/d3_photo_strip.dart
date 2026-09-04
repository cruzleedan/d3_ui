import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:d3_ui/d3_ui.dart';

// ─────────────────────────────────────────────────────────────────────────────
// D3PhotoStrip
// ─────────────────────────────────────────────────────────────────────────────

/// A horizontal row of local-file photo thumbnails with an accessible
/// remove affordance and tap-to-view wiring into [D3ImageViewer].
///
/// Generalizes a pattern that appears independently across several apps
/// (checklist items, amendment screens, report content): a scrollable row
/// of square thumbnails, each opening a full-screen [D3ImageViewer] on tap,
/// with an optional remove button per thumbnail. Centralizing it here fixes
/// touch-target and semantics gaps once instead of per call site — the
/// remove button's hit area meets the 48dp Material minimum regardless of
/// its visible glyph size (see [D3PhotoStripTokens]).
///
/// ```dart
/// D3PhotoStrip(
///   photoPaths: item.photoPaths,
///   itemLabel: item.text,
///   onRemove: (index) => removePhoto(item.id, index),
/// )
///
/// // Read-only (e.g. report/detail views) — omit onRemove.
/// D3PhotoStrip(
///   photoPaths: result.photoPaths,
///   itemLabel: result.itemText,
/// )
/// ```
class D3PhotoStrip extends StatelessWidget {
  const D3PhotoStrip({
    super.key,
    required this.photoPaths,
    required this.itemLabel,
    this.onRemove,
    this.viewerTitle,
  });

  /// Local file paths, in display order.
  final List<String> photoPaths;

  /// Describes what these photos belong to (e.g. the checklist item's
  /// text) — used to build each thumbnail's `Semantics` label ("Photo 2 of
  /// 3 for `itemLabel`").
  final String itemLabel;

  /// Called with the tapped photo's index when its remove button is
  /// pressed. When null, no remove button is shown (read-only strip).
  final ValueChanged<int>? onRemove;

  /// Optional title widget for the full-screen [D3ImageViewer]. Defaults to
  /// the viewer's own "N / M" counter.
  final Widget? viewerTitle;

  void _openViewer(BuildContext context, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => D3ImageViewer(
          images: [for (final p in photoPaths) D3ImageSource.local(p)],
          initialIndex: index,
          title: viewerTitle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (photoPaths.isEmpty) return const SizedBox.shrink();

    final tokens = context.d3PhotoStripTokens;

    return SizedBox(
      height: tokens.thumbnailSize,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: photoPaths.length,
        separatorBuilder: (_, _) => SizedBox(width: tokens.thumbnailGap),
        itemBuilder: (context, index) {
          return _D3PhotoThumbnail(
            path: photoPaths[index],
            index: index,
            count: photoPaths.length,
            itemLabel: itemLabel,
            tokens: tokens,
            onTap: () => _openViewer(context, index),
            onRemove: onRemove == null ? null : () => onRemove!(index),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _D3PhotoThumbnail
// ─────────────────────────────────────────────────────────────────────────────

class _D3PhotoThumbnail extends StatelessWidget {
  const _D3PhotoThumbnail({
    required this.path,
    required this.index,
    required this.count,
    required this.itemLabel,
    required this.tokens,
    required this.onTap,
    required this.onRemove,
  });

  final String path;
  final int index;
  final int count;
  final String itemLabel;
  final D3PhotoStripTokens tokens;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    final radius = BorderRadius.circular(tokens.thumbnailRadius);

    return Semantics(
      label: 'Photo ${index + 1} of $count for $itemLabel',
      button: true,
      image: true,
      child: SizedBox(
        width: tokens.thumbnailSize,
        height: tokens.thumbnailSize,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Material(
              color: colors.surfaceVariant,
              shape: RoundedRectangleBorder(borderRadius: radius),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onTap,
                child: Image.file(
                  File(path),
                  width: tokens.thumbnailSize,
                  height: tokens.thumbnailSize,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Icon(
                    Icons.broken_image_outlined,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            if (onRemove != null)
              Positioned(
                top: tokens.removeButtonOffset,
                right: tokens.removeButtonOffset,
                child: Semantics(
                  label: 'Remove photo ${index + 1}',
                  button: true,
                  child: SizedBox(
                    width: tokens.removeButtonHitSize,
                    height: tokens.removeButtonHitSize,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: onRemove,
                        child: Center(
                          child: Container(
                            width: tokens.removeButtonGlyphSize,
                            height: tokens.removeButtonGlyphSize,
                            decoration: BoxDecoration(
                              color: colors.error,
                              shape: BoxShape.circle,
                              border: Border.all(color: colors.surface, width: 1.5),
                            ),
                            child: Icon(
                              Icons.close,
                              size: tokens.removeButtonGlyphSize * 0.7,
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
