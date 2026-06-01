import 'package:flutter/material.dart';
import 'package:d3_ui/d3_ui.dart';

import '../shared/gallery_section.dart';

class ToggleGallery extends StatefulWidget {
  const ToggleGallery({
    super.key,
    required this.themeMode,
    required this.onToggleTheme,
  });

  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  @override
  State<ToggleGallery> createState() => _ToggleGalleryState();
}

class _ToggleGalleryState extends State<ToggleGallery> {
  // Standalone states
  bool _on = true;
  bool _off = false;

  // Labelled states
  bool _sync = true;
  bool _receipts = false;
  bool _location = true;

  // Settings screen states
  bool _wifi = true;
  bool _bluetooth = false;
  bool _darkMode = true;
  bool _notifications = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return D3Screen(
      title: 'D3Toggle',
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
          // ── Standalone ────────────────────────────────────────────────────
          GallerySection(
            title: 'Standalone',
            child: GallerySectionCard(
                child: Wrap(
              spacing: 24,
              runSpacing: 16,
              children: [
                Column(
                  children: [
                    D3Toggle(
                      value: _on,
                      onChanged: (v) => setState(() => _on = v),
                    ),
                    const SizedBox(height: 6),
                    Text('on',
                        style: TextStyle(
                            fontSize: 11, color: colors.onSurfaceVariant)),
                  ],
                ),
                Column(
                  children: [
                    D3Toggle(
                      value: _off,
                      onChanged: (v) => setState(() => _off = v),
                    ),
                    const SizedBox(height: 6),
                    Text('off',
                        style: TextStyle(
                            fontSize: 11, color: colors.onSurfaceVariant)),
                  ],
                ),
                Column(
                  children: [
                    D3Toggle(value: true, onChanged: null),
                    const SizedBox(height: 6),
                    Text('on · disabled',
                        style: TextStyle(
                            fontSize: 11, color: colors.onSurfaceVariant)),
                  ],
                ),
                Column(
                  children: [
                    D3Toggle(value: false, onChanged: null),
                    const SizedBox(height: 6),
                    Text('off · disabled',
                        style: TextStyle(
                            fontSize: 11, color: colors.onSurfaceVariant)),
                  ],
                ),
              ],
            )),
          ),

          // ── With label ────────────────────────────────────────────────────
          GallerySection(
            title: 'With label',
            child: GallerySectionCard(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                D3Toggle(
                  value: _sync,
                  label: 'Sync contacts',
                  onChanged: (v) => setState(() => _sync = v),
                ),
                const SizedBox(height: 16),
                D3Toggle(
                  value: _receipts,
                  label: 'Show read receipts',
                  onChanged: (v) => setState(() => _receipts = v),
                ),
                const SizedBox(height: 16),
                D3Toggle(
                  value: _location,
                  label: 'Share location',
                  onChanged: null,
                ),
              ],
            )),
          ),

          // ── In D3ListTile ─────────────────────────────────────────────────
          GallerySection(
            title: 'In D3ListTile',
            child: D3ListTileGroup(
              children: [
                D3ListTile(
                  leading: D3ListTileIcon(
                    icon: Icons.wifi_rounded,
                    color: colors.primary,
                  ),
                  title: 'Wi-Fi',
                  trailing: D3Toggle(
                    value: _wifi,
                    onChanged: (v) => setState(() => _wifi = v),
                    semanticsLabel: 'Wi-Fi',
                  ),
                  onTap: () => setState(() => _wifi = !_wifi),
                ),
                D3ListTile(
                  leading: D3ListTileIcon(
                    icon: Icons.bluetooth_rounded,
                    color: colors.primary,
                  ),
                  title: 'Bluetooth',
                  trailing: D3Toggle(
                    value: _bluetooth,
                    onChanged: (v) => setState(() => _bluetooth = v),
                    semanticsLabel: 'Bluetooth',
                  ),
                  onTap: () => setState(() => _bluetooth = !_bluetooth),
                ),
                D3ListTile(
                  leading: D3ListTileIcon(
                    icon: Icons.dark_mode_outlined,
                    color: colors.primary,
                  ),
                  title: 'Dark mode',
                  subtitle: 'Adapts to system setting',
                  trailing: D3Toggle(
                    value: _darkMode,
                    onChanged: (v) => setState(() => _darkMode = v),
                    semanticsLabel: 'Dark mode',
                  ),
                  onTap: () => setState(() => _darkMode = !_darkMode),
                ),
                D3ListTile(
                  leading: D3ListTileIcon(
                    icon: Icons.notifications_outlined,
                    color: colors.onSurfaceVariant,
                  ),
                  title: 'Notifications',
                  subtitle: 'Requires permission',
                  trailing: D3Toggle(
                    value: _notifications,
                    onChanged: null,
                    semanticsLabel: 'Notifications',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
