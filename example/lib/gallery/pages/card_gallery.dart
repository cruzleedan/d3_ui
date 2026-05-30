import 'package:flutter/material.dart';
import 'package:d3_ui/d3_ui.dart';

import '../shared/gallery_section.dart';

class CardGallery extends StatelessWidget {
  const CardGallery({
    super.key,
    required this.themeMode,
    required this.onToggleTheme,
  });

  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'D3Card',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: colors.onSurface,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: colors.onSurfaceVariant,
            ),
            onPressed: onToggleTheme,
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          children: [
            GallerySection(
              title: 'Elevated — static',
              child: D3Card(
                title: 'Getting started with tokens',
                subtitle: 'Design · 5 min read',
                eyebrow: 'Guide',
                content: Text(
                  'Learn how color, spacing, and radius tokens power every component in the system.',
                  style: TextStyle(
                      fontSize: 13,
                      color: colors.onSurfaceVariant,
                      height: 1.5),
                ),
              ),
            ),
            GallerySection(
              title: 'Elevated — tappable with media',
              child: D3Card(
                media: Container(
                  color: colors.primaryContainer,
                  child: Center(
                    child: Icon(Icons.auto_awesome_rounded,
                        size: 48, color: colors.primary),
                  ),
                ),
                eyebrow: 'New',
                title: 'Design system v2',
                subtitle: 'What\'s changed in this release',
                content: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Revised color tokens, snappier motion, and three new components.',
                    style: TextStyle(
                        fontSize: 13,
                        color: colors.onSurfaceVariant,
                        height: 1.5),
                  ),
                ),
                footerAction: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: colors.primary,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Read more',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ),
                footerTrailing: Text(
                  'Mar 2025',
                  style:
                      TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
                ),
                onTap: () {},
              ),
            ),
            GallerySection(
              title: 'Tonal',
              child: D3Card(
                variant: D3CardVariant.tonal,
                eyebrow: 'Featured',
                title: 'Flat and minimal, snappy and smooth',
                content: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'The design system adapts naturally to device typography settings and looks great on both Android and iOS.',
                    style: TextStyle(
                        fontSize: 13,
                        color:
                            colors.onPrimaryContainer.withValues(alpha: 0.75),
                        height: 1.5),
                  ),
                ),
                footerAction: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: colors.primary,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Learn more',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ),
                onTap: () {},
              ),
            ),
            GallerySection(
              title: 'Content only',
              child: D3Card(
                content: Row(
                  children: [
                    Icon(Icons.check_circle_outline_rounded,
                        color: colors.success, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'All systems operational',
                        style: TextStyle(
                            fontSize: 13,
                            color: colors.onSurface,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GallerySection(
              title: 'Footer only',
              child: D3Card(
                title: 'Unsaved changes',
                content: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'You have edits that haven\'t been saved yet.',
                    style: TextStyle(
                        fontSize: 13,
                        color: colors.onSurfaceVariant,
                        height: 1.5),
                  ),
                ),
                footerAction: D3Button(
                  label: 'Save',
                  size: D3ButtonSize.sm,
                  onPressed: () {},
                ),
                footerTrailing: D3Button(
                  label: 'Discard',
                  size: D3ButtonSize.sm,
                  variant: D3ButtonVariant.ghost,
                  onPressed: () {},
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
