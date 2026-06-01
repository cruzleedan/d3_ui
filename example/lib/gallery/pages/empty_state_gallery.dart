import 'package:flutter/material.dart';
import 'package:d3_ui/d3_ui.dart';

import '../shared/gallery_section.dart';

class EmptyStateGallery extends StatelessWidget {
  const EmptyStateGallery({
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
                title: 'Default — single action',
                child: D3Card(
                  content: D3EmptyState(
                    icon: Icons.inbox_outlined,
                    title: 'No items yet',
                    message:
                        'Create your first item to get started. It will appear here once added.',
                    action: D3Button(
                      label: 'Create item',
                      onPressed: () {},
                    ),
                  ),
                ),
              ),
              GallerySection(
                title: 'No results — primary + secondary action',
                child: D3Card(
                  content: D3EmptyState(
                    icon: Icons.search_off_rounded,
                    iconColor: colors.primary,
                    title: 'No results found',
                    message:
                        'Try adjusting your search or filters to find what you\'re looking for.',
                    action: D3Button(
                      label: 'Clear filters',
                      onPressed: () {},
                    ),
                    secondaryAction: D3Button(
                      label: 'Browse all',
                      variant: D3ButtonVariant.ghost,
                      onPressed: () {},
                    ),
                  ),
                ),
              ),
              GallerySection(
                title: 'Error state',
                child: D3Card(
                  content: D3EmptyState(
                    icon: Icons.wifi_off_rounded,
                    iconColor: colors.error,
                    title: 'Something went wrong',
                    message:
                        'We couldn\'t load your data. Check your connection and try again.',
                    action: D3Button(
                      label: 'Try again',
                      onPressed: () {},
                    ),
                  ),
                ),
              ),
              const GallerySection(
                title: 'Compact — no action',
                child: Row(
                  children: [
                    Expanded(
                      child: D3Card(
                        content: D3EmptyState(
                          icon: Icons.check_circle_outline_rounded,
                          iconColor: Colors.green,
                          title: 'All caught up',
                          message: 'No notifications.',
                          compact: true,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: D3Card(
                        content: D3EmptyState(
                          icon: Icons.notifications_off_outlined,
                          iconColor: Colors.orange,
                          title: 'Notifications off',
                          message: 'Enable in settings.',
                          compact: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              GallerySection(
                title: 'Compact — with action',
                child: D3Card(
                  content: D3EmptyState(
                    icon: Icons.folder_open_outlined,
                    iconColor: colors.primary,
                    title: 'No documents',
                    message: 'Upload a file to get started.',
                    compact: true,
                    action: D3Button(
                      label: 'Upload',
                      size: D3ButtonSize.sm,
                      onPressed: () {},
                    ),
                  ),
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
