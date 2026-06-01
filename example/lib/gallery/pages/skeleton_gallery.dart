import 'package:flutter/material.dart';
import 'package:d3_ui/d3_ui.dart';

import '../shared/gallery_section.dart';

class SkeletonGallery extends StatefulWidget {
  const SkeletonGallery({
    super.key,
    required this.themeMode,
    required this.onToggleTheme,
  });

  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  @override
  State<SkeletonGallery> createState() => _SkeletonGalleryState();
}

class _SkeletonGalleryState extends State<SkeletonGallery> {
  bool _loaded = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return D3Screen(
      title: 'D3Skeleton',
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
          // ── Skeleton box ──────────────────────────────────────────────────
          GallerySection(
            title: 'D3SkeletonBox',
            child: GallerySectionCard(
              child: D3Shimmer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    D3SkeletonBox(
                      height: 140,
                      borderRadius: D3Radius.circularMd,
                    ),
                    const SizedBox(height: 12),
                    const D3SkeletonBox(height: 16, width: 180),
                    const SizedBox(height: 8),
                    const D3SkeletonBox(height: 13),
                    const SizedBox(height: 6),
                    const D3SkeletonBox(height: 13, width: 240),
                  ],
                ),
              ),
            ),
          ),

          // ── Skeleton text ─────────────────────────────────────────────────
          GallerySection(
            title: 'D3SkeletonText',
            child: GallerySectionCard(
              child: D3Shimmer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    D3SkeletonText(lines: 1, lineHeight: 18),
                    SizedBox(height: 12),
                    D3SkeletonText(lines: 2),
                    SizedBox(height: 12),
                    D3SkeletonText(lines: 3),
                    SizedBox(height: 12),
                    D3SkeletonText(lines: 4, lastLineWidthFraction: 0.4),
                  ],
                ),
              ),
            ),
          ),

          // ── List row skeleton ─────────────────────────────────────────────
          GallerySection(
            title: 'List row pattern',
            child: GallerySectionCard(
              child: D3Shimmer(
                child: Column(
                  children: List.generate(4, (i) => _SkeletonListRow()),
                ),
              ),
            ),
          ),

          // ── Cover grid skeleton ───────────────────────────────────────────
          GallerySection(
            title: 'Cover grid pattern',
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
                  itemCount: 8,
                  itemBuilder: (_, __) => D3SkeletonBox(
                    height: double.infinity,
                    borderRadius: D3Radius.circularSm,
                  ),
                ),
              ),
            ),
          ),

          // ── Toggle loaded/skeleton ─────────────────────────────────────────
          GallerySection(
            title: 'Loaded vs loading toggle',
            child: GallerySectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Simulate load',
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.onSurface,
                        ),
                      ),
                      const Spacer(),
                      D3Toggle(
                        value: _loaded,
                        onChanged: (v) => setState(() => _loaded = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _loaded
                        ? _LoadedCard(
                            key: const ValueKey('loaded'), colors: colors)
                        : D3Shimmer(
                            key: const ValueKey('skeleton'),
                            child: _SkeletonCard(),
                          ),
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

// ── Skeleton patterns ──────────────────────────────────────────────────────────

class _SkeletonListRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          D3SkeletonBox(
            width: 44,
            height: 44,
            borderRadius: BorderRadius.circular(D3Radius.full),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: D3SkeletonText(lines: 2, lineHeight: 12, spacing: 6),
          ),
        ],
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        D3SkeletonBox(
          width: 80,
          height: 112,
          borderRadius: D3Radius.circularSm,
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              D3SkeletonBox(height: 16, width: 140),
              SizedBox(height: 8),
              D3SkeletonText(lines: 3, lineHeight: 12),
            ],
          ),
        ),
      ],
    );
  }
}

class _LoadedCard extends StatelessWidget {
  const _LoadedCard({super.key, required this.colors});
  final D3ColorTokens colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80,
          height: 112,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: D3Radius.circularSm,
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.play_circle_outline_rounded,
            color: colors.primary,
            size: 28,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Fullmetal Alchemist: Brotherhood',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Two brothers search for a Philosopher\'s Stone after an '
                'attempt to revive their mother goes wrong.',
                style: TextStyle(
                  fontSize: 12,
                  color: colors.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
