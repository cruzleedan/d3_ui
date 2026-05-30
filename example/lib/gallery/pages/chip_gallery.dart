import 'package:flutter/material.dart';
import 'package:d3_ui/d3_ui.dart';

import '../shared/gallery_section.dart';

class ChipGallery extends StatefulWidget {
  const ChipGallery({
    super.key,
    required this.themeMode,
    required this.onToggleTheme,
  });

  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  @override
  State<ChipGallery> createState() => _ChipGalleryState();
}

class _ChipGalleryState extends State<ChipGallery> {
  final Set<String> _genres = {'Action', 'Romance'};
  D3WatchStatus _status = D3WatchStatus.watching;

  void _toggleGenre(String g) =>
      setState(() => _genres.contains(g) ? _genres.remove(g) : _genres.add(g));

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const genres = ['Action', 'Romance', 'Sci-fi', 'Fantasy', 'Horror', 'Comedy'];

    return D3Screen(
      title: 'D3Chip',
      leading: D3ScreenLeading.none,
      backgroundColor: colors.surfaceVariant,
      actions: [
        D3ScreenAction.icon(
          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          onPressed: widget.onToggleTheme,
          semanticsLabel: 'Toggle theme',
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [

          // ── Variants ──────────────────────────────────────────────────────
          GallerySection(
            title: 'Variants',
            child: GallerySectionCard(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  const D3Chip(label: 'Outlined', variant: D3ChipVariant.outlined),
                  const D3Chip(label: 'Tonal', variant: D3ChipVariant.tonal),
                  const D3Chip(label: 'Filled', variant: D3ChipVariant.filled),
                  D3Chip(
                    label: 'With icon',
                    variant: D3ChipVariant.tonal,
                    leadingIcon: Icons.star_outline_rounded,
                    onTap: () {},
                  ),
                  D3Chip(
                    label: 'Dismissible',
                    variant: D3ChipVariant.outlined,
                    trailingIcon: Icons.close_rounded,
                    onTap: () {},
                  ),
                  const D3Chip(
                    label: 'Disabled',
                    enabled: false,
                  ),
                ],
              ),
            ),
          ),

          // ── Filter chips (interactive) ─────────────────────────────────────
          GallerySection(
            title: 'Filter chips',
            child: GallerySectionCard(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: genres.map((g) => D3Chip(
                  label: g,
                  selected: _genres.contains(g),
                  onTap: () => _toggleGenre(g),
                )).toList(),
              ),
            ),
          ),

          // ── Status chips ──────────────────────────────────────────────────
          GallerySection(
            title: 'Status chips (D3StatusChip)',
            child: GallerySectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: D3WatchStatus.values
                        .map((s) => D3StatusChip(status: s))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  // Interactive — tap to cycle status
                  Row(
                    children: [
                      Text(
                        'Tap to cycle:',
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 10),
                      D3StatusChip(
                        status: _status,
                        onTap: () => setState(() {
                          final idx = D3WatchStatus.values.indexOf(_status);
                          _status = D3WatchStatus.values[
                              (idx + 1) % D3WatchStatus.values.length];
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }
}
