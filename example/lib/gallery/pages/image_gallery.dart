import 'package:flutter/material.dart';
import 'package:d3_ui/d3_ui.dart';

import '../shared/gallery_section.dart';

class ImageGallery extends StatelessWidget {
  const ImageGallery({
    super.key,
    required this.themeMode,
    required this.onToggleTheme,
  });

  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  // A few public-domain / openly-licensed test images.
  static const _covers = [
    'https://upload.wikimedia.org/wikipedia/en/thumb/2/2e/Fullmetal_Alchemist_Manga_cover.jpg/220px-Fullmetal_Alchemist_Manga_cover.jpg',
    'https://upload.wikimedia.org/wikipedia/en/thumb/9/9b/Spirited_Away_Japanese_poster.png/220px-Spirited_Away_Japanese_poster.png',
    'https://upload.wikimedia.org/wikipedia/en/thumb/7/77/My_Neighbor_Totoro_-_Tonari_no_Totoro_%28Movie_Poster%29.jpg/220px-My_Neighbor_Totoro_-_Tonari_no_Totoro_%28Movie_Poster%29.jpg',
    'https://upload.wikimedia.org/wikipedia/en/thumb/d/d5/Princess_Mononoke_Japanese_poster.png/220px-Princess_Mononoke_Japanese_poster.png',
    'https://upload.wikimedia.org/wikipedia/en/thumb/4/40/Nausicaa_of_the_Valley_of_the_Wind_poster.jpg/220px-Nausicaa_of_the_Valley_of_the_Wind_poster.jpg',
    'https://upload.wikimedia.org/wikipedia/en/thumb/8/8c/Howl%27s_Moving_Castle_%28Howl_no_Ugoku_Shiro%29_Japanese_poster.jpg/220px-Howl%27s_Moving_Castle_%28Howl_no_Ugoku_Shiro%29_Japanese_poster.jpg',
    'https://upload.wikimedia.org/wikipedia/en/thumb/4/43/Porco-rosso-poster.jpg/220px-Porco-rosso-poster.jpg',
    'https://upload.wikimedia.org/wikipedia/en/thumb/3/3c/Kiki%27s_delivery_service_japanese_poster.jpg/220px-Kiki%27s_delivery_service_japanese_poster.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return D3Screen(
      title: 'D3Image',
      leading: D3ScreenLeading.none,
      backgroundColor: colors.surfaceVariant,
      actions: [
        D3ScreenAction.icon(
          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          onPressed: onToggleTheme,
          semanticsLabel: 'Toggle theme',
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // ── Fixed size ────────────────────────────────────────────────────
          GallerySection(
            title: 'Fixed size',
            child: GallerySectionCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  D3Image(
                    url: _covers[0],
                    width: 80,
                    height: 112,
                    borderRadius: D3Radius.circularSm,
                    semanticsLabel: 'Cover art',
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fullmetal Alchemist',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '80 × 112dp, D3Radius.circularSm',
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Aspect ratio ──────────────────────────────────────────────────
          GallerySection(
            title: 'Aspect ratio (2/3)',
            child: GallerySectionCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  D3Image(
                    url: _covers[1],
                    width: 80,
                    aspectRatio: 2 / 3,
                    borderRadius: D3Radius.circularSm,
                    semanticsLabel: 'Cover art',
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Height inferred from width × (3/2). No hardcoded height needed.',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Border radius variants ─────────────────────────────────────────
          GallerySection(
            title: 'Border radius',
            child: GallerySectionCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _LabelledImage(
                    url: _covers[2],
                    borderRadius: D3Radius.circularXs,
                    label: 'xs',
                  ),
                  _LabelledImage(
                    url: _covers[3],
                    borderRadius: D3Radius.circularMd,
                    label: 'md',
                  ),
                  _LabelledImage(
                    url: _covers[4],
                    borderRadius: D3Radius.circularXl,
                    label: 'xl',
                  ),
                  _LabelledImage(
                    url: _covers[5],
                    borderRadius: BorderRadius.zero,
                    label: 'none',
                  ),
                ],
              ),
            ),
          ),

          // ── Error state ───────────────────────────────────────────────────
          GallerySection(
            title: 'Error state',
            child: GallerySectionCard(
              child: Row(
                children: [
                  const D3Image(
                    url: 'https://broken.url/image.jpg',
                    width: 80,
                    aspectRatio: 2 / 3,
                    borderRadius: D3Radius.circularSm,
                  ),
                  const SizedBox(width: 12),
                  const D3Image(
                    url: null,
                    width: 80,
                    aspectRatio: 2 / 3,
                    borderRadius: D3Radius.circularSm,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Broken URL or null — shows icon + "No image" label with border.',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Synchronised shimmer grid ──────────────────────────────────────
          GallerySection(
            title: 'Grid — synchronised shimmer',
            child: GallerySectionCard(
              child: D3Shimmer(
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 2 / 3,
                  ),
                  itemCount: _covers.length,
                  itemBuilder: (ctx, i) => D3Image(
                    url: _covers[i],
                    aspectRatio: 2 / 3,
                    borderRadius: D3Radius.circularSm,
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

class _LabelledImage extends StatelessWidget {
  const _LabelledImage({
    required this.url,
    required this.borderRadius,
    required this.label,
  });

  final String url;
  final BorderRadius borderRadius;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    return Column(
      children: [
        D3Image(
          url: url,
          width: 60,
          aspectRatio: 2 / 3,
          borderRadius: borderRadius,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: colors.onSurfaceVariant),
        ),
      ],
    );
  }
}
