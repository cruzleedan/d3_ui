import 'package:flutter/material.dart';
import 'package:d3_ui/d3_ui.dart';

import '../shared/gallery_section.dart';

class ListTileGallery extends StatelessWidget {
  const ListTileGallery({
    super.key,
    required this.themeMode,
    required this.onToggleTheme,
  });

  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GallerySection(
                title: 'Settings group',
                child: D3ListTileGroup(
                  children: [
                    D3ListTile(
                      leading: D3ListTileIcon(
                        icon: Icons.notifications_outlined,
                        color: colors.primary,
                      ),
                      title: 'Notifications',
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {},
                    ),
                    D3ListTile(
                      leading: const D3ListTileIcon(
                        icon: Icons.lock_outline_rounded,
                        color: Colors.green,
                      ),
                      title: 'Privacy',
                      subtitle: 'Manage your data',
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {},
                    ),
                    D3ListTile(
                      leading: const D3ListTileIcon(
                        icon: Icons.palette_outlined,
                        color: Colors.purple,
                      ),
                      title: 'Appearance',
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              GallerySection(
                title: 'With toggles',
                child: D3ListTileGroup(
                  children: [
                    D3ListTile(
                      leading: const D3ListTileIcon(
                        icon: Icons.wifi_rounded,
                        color: Colors.blue,
                      ),
                      title: 'Wi-Fi',
                      trailing: Switch(
                        value: true,
                        onChanged: (_) {},
                      ),
                    ),
                    D3ListTile(
                      leading: const D3ListTileIcon(
                        icon: Icons.bluetooth_rounded,
                        color: Colors.indigo,
                      ),
                      title: 'Bluetooth',
                      trailing: Switch(
                        value: false,
                        onChanged: (_) {},
                      ),
                    ),
                  ],
                ),
              ),
              GallerySection(
                title: 'No leading',
                child: D3ListTileGroup(
                  children: [
                    D3ListTile(
                      title: 'Option A',
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {},
                    ),
                    D3ListTile(
                      title: 'Option B',
                      subtitle: 'With a subtitle',
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              GallerySection(
                title: 'Destructive action',
                child: D3ListTileGroup(
                  children: [
                    D3ListTile(
                      leading: D3ListTileIcon(
                        icon: Icons.logout_rounded,
                        color: colors.error,
                      ),
                      title: 'Sign out',
                      isDestructive: true,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              GallerySection(
                title: 'Disabled',
                child: D3ListTileGroup(
                  children: [
                    D3ListTile(
                      leading: D3ListTileIcon(
                        icon: Icons.cloud_outlined,
                        color: colors.primary,
                      ),
                      title: 'Cloud sync',
                      subtitle: 'Not available',
                      enabled: false,
                      trailing: const Icon(Icons.chevron_right_rounded),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
