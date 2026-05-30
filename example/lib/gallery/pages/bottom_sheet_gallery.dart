import 'package:flutter/material.dart';
import 'package:d3_ui/d3_ui.dart';

import '../shared/gallery_section.dart';

class BottomSheetGallery extends StatelessWidget {
  const BottomSheetGallery({
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
          'D3BottomSheet',
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
              title: 'Simple — no title',
              child: D3Button(
                label: 'Open sheet',
                isFullWidth: true,
                onPressed: () => D3BottomSheet.show(
                  context,
                  child: const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('Just content, no header title.'),
                  ),
                ),
              ),
            ),
            GallerySection(
              title: 'With title & subtitle',
              child: D3Button(
                label: 'Open sheet',
                isFullWidth: true,
                onPressed: () => D3BottomSheet.show(
                  context,
                  title: 'Sort results',
                  subtitle: 'Choose your preferred order',
                  headerAction: TextButton(
                    onPressed: () {},
                    child: const Text('Reset'),
                  ),
                  child: _SortPickerContent(),
                ),
              ),
            ),
            GallerySection(
              title: 'Multiple snap points',
              child: D3Button(
                label: 'Open sheet',
                isFullWidth: true,
                onPressed: () => D3BottomSheet.show(
                  context,
                  title: 'Drag me',
                  subtitle: 'Peek → half → expanded',
                  snapPoints: [
                    D3SnapPoint.peek,
                    D3SnapPoint.half,
                    D3SnapPoint.expanded
                  ],
                  initialSnap: D3SnapPoint.peek,
                  child: const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('Drag the handle or scroll up to expand.'),
                  ),
                ),
              ),
            ),
            GallerySection(
              title: 'Picker — returns a value',
              child: _PickerExample(),
            ),
            GallerySection(
              title: 'Discard guard',
              child: D3Button(
                label: 'Open sheet with guard',
                isFullWidth: true,
                onPressed: () => D3BottomSheet.show(
                  context,
                  title: 'Edit profile',
                  subtitle: 'Unsaved changes are guarded',
                  onConfirmDiscard: () async {
                    return await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Discard changes?'),
                            content: const Text(
                                'You have unsaved changes. If you close now, they\'ll be lost.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Keep editing'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      Theme.of(context).colorScheme.error,
                                ),
                                child: const Text('Discard'),
                              ),
                            ],
                          ),
                        ) ??
                        false;
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('Try tapping × or the back button.'),
                  ),
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

// ── Sort picker content ────────────────────────────────────────────────────

class _SortPickerContent extends StatefulWidget {
  @override
  State<_SortPickerContent> createState() => _SortPickerContentState();
}

class _SortPickerContentState extends State<_SortPickerContent> {
  int _selected = 0;

  static const _options = [
    (Icons.access_time_rounded, 'Most recent'),
    (Icons.star_outline_rounded, 'Top rated'),
    (Icons.near_me_outlined, 'Nearest first'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    return Column(
      children: [
        ..._options.asMap().entries.map((e) {
          final selected = e.key == _selected;
          return GestureDetector(
            onTap: () => setState(() => _selected = e.key),
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected
                      ? colors.primary
                      : colors.outline.withValues(alpha: 0.4),
                  width: selected ? 1.5 : 0.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(e.value.$1,
                      size: 18,
                      color:
                          selected ? colors.primary : colors.onSurfaceVariant),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      e.value.$2,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w400,
                        color: selected ? colors.primary : colors.onSurface,
                      ),
                    ),
                  ),
                  if (selected)
                    Icon(Icons.check_rounded, size: 18, color: colors.primary),
                ],
              ),
            ),
          );
        }),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          child: D3Button(
            label: 'Apply',
            isFullWidth: true,
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }
}

// ── Picker example ─────────────────────────────────────────────────────────

class _PickerExample extends StatefulWidget {
  @override
  State<_PickerExample> createState() => _PickerExampleState();
}

class _PickerExampleState extends State<_PickerExample> {
  String? _picked;

  static const _options = ['Most recent', 'Top rated', 'Nearest first'];

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        D3Button(
          label: 'Pick sort order',
          isFullWidth: true,
          onPressed: () async {
            final result = await D3BottomSheet.show<String>(
              context,
              title: 'Sort by',
              child: Column(
                children: _options
                    .map((o) => ListTile(
                          title: Text(o),
                          onTap: () => Navigator.pop(context, o),
                        ))
                    .toList(),
              ),
            );
            if (result != null) setState(() => _picked = result);
          },
        ),
        if (_picked != null) ...[
          const SizedBox(height: 10),
          Text(
            'Picked: $_picked',
            style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
          ),
        ],
      ],
    );
  }
}
