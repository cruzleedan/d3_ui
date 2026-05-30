import 'package:flutter/material.dart';
import 'package:d3_ui/d3_ui.dart';

/// White card container for gallery section content that isn't a D3ListTileGroup.
/// Use this to wrap Wrap/Column/Row state grids so they sit on a white card
/// against the surfaceVariant page background (iOS grouped table look).
class GallerySectionCard extends StatelessWidget {
  const GallerySectionCard({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(D3Radius.lg),
        border: Border.all(
          color: colors.outline,
          width: 0.5,
        ),
      ),
      child: child,
    );
  }
}

/// A labelled section used throughout the gallery pages.
class GallerySection extends StatelessWidget {
  const GallerySection({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: child,
          ),
        ],
      ),
    );
  }
}
