import 'package:flutter/material.dart';
import 'package:d3_ui/d3_ui.dart';

import '../shared/gallery_section.dart';

class RadioGallery extends StatefulWidget {
  const RadioGallery({
    super.key,
    required this.themeMode,
    required this.onToggleTheme,
  });

  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  @override
  State<RadioGallery> createState() => _RadioGalleryState();
}

class _RadioGalleryState extends State<RadioGallery> {
  // Theme group
  String _theme = 'system';

  // Sort group
  String _sort = 'recent';

  // Plan group
  String? _plan = 'pro';

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return D3Screen(
      title: 'D3Radio',
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
          // ── Standalone states ─────────────────────────────────────────────
          GallerySection(
            title: 'States',
            child: GallerySectionCard(
                child: Wrap(
              spacing: 20,
              runSpacing: 16,
              children: [
                _StateItem(
                  label: 'selected',
                  child: D3Radio<String>(
                    value: 'a',
                    groupValue: 'a',
                    onChanged: (_) {},
                  ),
                ),
                _StateItem(
                  label: 'unselected',
                  child: D3Radio<String>(
                    value: 'b',
                    groupValue: 'a',
                    onChanged: (_) {},
                  ),
                ),
                _StateItem(
                  label: 'selected · disabled',
                  child: D3Radio<String>(
                    value: 'a',
                    groupValue: 'a',
                    onChanged: null,
                  ),
                ),
                _StateItem(
                  label: 'unselected · disabled',
                  child: D3Radio<String>(
                    value: 'b',
                    groupValue: 'a',
                    onChanged: null,
                  ),
                ),
              ],
            )),
          ),

          // ── With label — appearance group ─────────────────────────────────
          GallerySection(
            title: 'With label',
            child: GallerySectionCard(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final option in [
                  ('system', 'System default'),
                  ('light', 'Light'),
                  ('dark', 'Dark'),
                ])
                  D3Radio<String>(
                    value: option.$1,
                    groupValue: _theme,
                    label: option.$2,
                    onChanged: (v) => setState(() => _theme = v),
                  ),
              ],
            )),
          ),

          // ── In D3ListTile — sort order ─────────────────────────────────────
          GallerySection(
            title: 'In D3ListTile',
            child: D3ListTileGroup(
              children: [
                for (final option in [
                  ('recent', 'Most recent', 'Newest items first'),
                  ('oldest', 'Oldest first', null),
                  ('alpha', 'Alphabetical', null),
                  ('size', 'File size', 'Largest items first'),
                ])
                  D3ListTile(
                    leading: D3Radio<String>(
                      value: option.$1,
                      groupValue: _sort,
                      onChanged: (v) => setState(() => _sort = v),
                      semanticsLabel: option.$2,
                    ),
                    title: option.$2,
                    subtitle: option.$3,
                    onTap: () => setState(() => _sort = option.$1),
                  ),
              ],
            ),
          ),

          // ── Plan picker — nullable groupValue ─────────────────────────────
          GallerySection(
            title: 'Nullable group value',
            child: D3ListTileGroup(
              children: [
                for (final option in [
                  ('free', 'Free', 'Up to 3 projects'),
                  ('pro', 'Pro', 'Unlimited projects'),
                  ('team', 'Team', 'Collaboration features'),
                ])
                  D3ListTile(
                    leading: D3Radio<String>(
                      value: option.$1,
                      groupValue: _plan,
                      onChanged: (v) => setState(() => _plan = v),
                      semanticsLabel: option.$2,
                    ),
                    title: option.$2,
                    subtitle: option.$3,
                    onTap: () => setState(() => _plan = option.$1),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper
// ─────────────────────────────────────────────────────────────────────────────

class _StateItem extends StatelessWidget {
  const _StateItem({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    return Column(
      children: [
        child,
        Text(label,
            style: TextStyle(fontSize: 10, color: colors.onSurfaceVariant)),
      ],
    );
  }
}
