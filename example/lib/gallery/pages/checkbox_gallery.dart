import 'package:flutter/material.dart';
import 'package:d3_ui/d3_ui.dart';

import '../shared/gallery_section.dart';

class CheckboxGallery extends StatefulWidget {
  const CheckboxGallery({
    super.key,
    required this.themeMode,
    required this.onToggleTheme,
  });

  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  @override
  State<CheckboxGallery> createState() => _CheckboxGalleryState();
}

class _CheckboxGalleryState extends State<CheckboxGallery> {
  // Standalone
  bool _checked = true;
  bool _unchecked = false;

  // Labelled
  bool _terms = false;
  bool _marketing = false;

  // Select-all pattern
  final List<bool> _items = [true, true, false, false, false];

  bool? get _allValue {
    final count = _items.where((v) => v).length;
    if (count == 0) return false;
    if (count == _items.length) return true;
    return null; // indeterminate
  }

  void _toggleAll() {
    final next = _allValue != true;
    setState(() {
      for (var i = 0; i < _items.length; i++) {
        _items[i] = next;
      }
    });
  }

  static const _itemLabels = [
    'Design tokens',
    'Components',
    'Documentation',
    'Example app',
    'Release notes',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return D3Screen(
      title: 'D3Checkbox',
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
            title: 'All states',
            child: GallerySectionCard(child: Wrap(
              spacing: 20,
              runSpacing: 16,
              children: [
                _StateItem(
                  label: 'checked',
                  child: D3Checkbox(
                    value: _checked,
                    onChanged: (v) => setState(() => _checked = v),
                  ),
                ),
                _StateItem(
                  label: 'unchecked',
                  child: D3Checkbox(
                    value: _unchecked,
                    onChanged: (v) => setState(() => _unchecked = v),
                  ),
                ),
                _StateItem(
                  label: 'indeterminate',
                  child: D3Checkbox(
                    value: null,
                    onChanged: (_) {},
                  ),
                ),
                _StateItem(
                  label: 'disabled',
                  child: D3Checkbox(value: false, onChanged: null),
                ),
                _StateItem(
                  label: 'checked · disabled',
                  child: D3Checkbox(value: true, onChanged: null),
                ),
              ],
            )),
          ),

          // ── With label ────────────────────────────────────────────────────
          GallerySection(
            title: 'With label',
            child: GallerySectionCard(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                D3Checkbox(
                  value: _terms,
                  label: 'I agree to the terms of service',
                  onChanged: (v) => setState(() => _terms = v),
                ),
                D3Checkbox(
                  value: _marketing,
                  label: 'Send me product updates',
                  onChanged: (v) => setState(() => _marketing = v),
                ),
                D3Checkbox(
                  value: false,
                  label: 'Share usage analytics',
                  onChanged: null,
                ),
              ],
            )),
          ),

          // ── Select-all pattern ────────────────────────────────────────────
          GallerySection(
            title: 'Select all (indeterminate)',
            child: D3ListTileGroup(
              children: [
                // Select-all header row
                D3ListTile(
                  leading: D3Checkbox(
                    value: _allValue,
                    onChanged: (_) => _toggleAll(),
                    semanticsLabel: 'Select all',
                  ),
                  titleWidget: Text(
                    _allValue == null
                        ? '${_items.where((v) => v).length} selected'
                        : _allValue == true
                            ? 'All selected'
                            : 'Select all',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  onTap: _toggleAll,
                ),

                // Individual items
                ...List.generate(_itemLabels.length, (i) {
                  final isLast = i == _itemLabels.length - 1;
                  return D3ListTile(
                    leading: D3Checkbox(
                      value: _items[i],
                      onChanged: (v) => setState(() => _items[i] = v),
                      semanticsLabel: _itemLabels[i],
                    ),
                    title: _itemLabels[i],
                    onTap: () => setState(() => _items[i] = !_items[i]),
                  );
                }),
              ],
            ),
          ),

        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper: labelled state column
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
        Text(
          label,
          style: TextStyle(fontSize: 10, color: colors.onSurfaceVariant),
        ),
      ],
    );
  }
}
