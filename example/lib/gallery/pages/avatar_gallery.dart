import 'package:flutter/material.dart';
import 'package:d3_ui/d3_ui.dart';

import '../shared/gallery_section.dart';

class AvatarGallery extends StatelessWidget {
  const AvatarGallery({
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
              const GallerySection(
                title: 'Sizes — initials',
                child: Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.end,
                  children: [
                    _LabelledAvatar(
                      avatar: D3Avatar(
                          name: 'Dan Lee', size: D3AvatarSize.xs),
                      label: 'xs',
                    ),
                    _LabelledAvatar(
                      avatar: D3Avatar(
                          name: 'Dan Lee', size: D3AvatarSize.sm),
                      label: 'sm',
                    ),
                    _LabelledAvatar(
                      avatar: D3Avatar(
                          name: 'Dan Lee', size: D3AvatarSize.md),
                      label: 'md',
                    ),
                    _LabelledAvatar(
                      avatar: D3Avatar(
                          name: 'Dan Lee', size: D3AvatarSize.lg),
                      label: 'lg',
                    ),
                    _LabelledAvatar(
                      avatar: D3Avatar(
                          name: 'Dan Lee', size: D3AvatarSize.xl),
                      label: 'xl',
                    ),
                  ],
                ),
              ),
              const GallerySection(
                title: 'Deterministic colors',
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    D3Avatar(name: 'Alice Brown'),
                    D3Avatar(name: 'Bob Chen'),
                    D3Avatar(name: 'Clara Davis'),
                    D3Avatar(name: 'Dan Lee'),
                    D3Avatar(name: 'Eva Morales'),
                    D3Avatar(name: 'Frank Nguyen'),
                    D3Avatar(name: 'Grace Park'),
                  ],
                ),
              ),
              const GallerySection(
                title: 'Online indicator',
                child: Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.end,
                  children: [
                    _LabelledAvatar(
                      avatar: D3Avatar(
                        name: 'Dan Lee',
                        size: D3AvatarSize.md,
                        indicator: D3AvatarIndicator.online,
                      ),
                      label: 'online',
                    ),
                    _LabelledAvatar(
                      avatar: D3Avatar(
                        name: 'Jane Kim',
                        size: D3AvatarSize.md,
                        indicator: D3AvatarIndicator.busy,
                      ),
                      label: 'busy',
                    ),
                    _LabelledAvatar(
                      avatar: D3Avatar(
                        name: 'Mark Santos',
                        size: D3AvatarSize.md,
                        indicator: D3AvatarIndicator.offline,
                      ),
                      label: 'offline',
                    ),
                    _LabelledAvatar(
                      avatar: D3Avatar(
                        name: 'Amy Chen',
                        size: D3AvatarSize.lg,
                        indicator: D3AvatarIndicator.online,
                      ),
                      label: 'lg',
                    ),
                    _LabelledAvatar(
                      avatar: D3Avatar(
                        name: 'Luis Reyes',
                        size: D3AvatarSize.xl,
                        indicator: D3AvatarIndicator.online,
                      ),
                      label: 'xl',
                    ),
                  ],
                ),
              ),
              const GallerySection(
                title: 'Square shape',
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.end,
                  children: [
                    D3Avatar(
                        name: 'Dan Lee',
                        size: D3AvatarSize.sm,
                        shape: D3AvatarShape.square),
                    D3Avatar(
                        name: 'Jane Kim',
                        size: D3AvatarSize.md,
                        shape: D3AvatarShape.square),
                    D3Avatar(
                        name: 'Mark Santos',
                        size: D3AvatarSize.lg,
                        shape: D3AvatarShape.square),
                    D3Avatar(
                        name: 'Amy Chen',
                        size: D3AvatarSize.xl,
                        shape: D3AvatarShape.square),
                  ],
                ),
              ),
              const GallerySection(
                title: 'With image (falls back to initials on error)',
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    D3Avatar(
                      name: 'Dan Lee',
                      imageUrl: 'https://i.pravatar.cc/150?img=3',
                      size: D3AvatarSize.lg,
                      indicator: D3AvatarIndicator.online,
                    ),
                    D3Avatar(
                      name: 'Jane Kim',
                      imageUrl: 'https://i.pravatar.cc/150?img=5',
                      size: D3AvatarSize.lg,
                    ),
                    // Intentionally broken URL — should show initials fallback
                    D3Avatar(
                      name: 'Error State',
                      imageUrl: 'https://example.invalid/404.jpg',
                      size: D3AvatarSize.lg,
                    ),
                  ],
                ),
              ),
              GallerySection(
                title: 'Group — stacked with overflow',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    D3AvatarGroup(
                      size: D3AvatarSize.md,
                      avatars: const [
                        D3Avatar(name: 'Dan Lee'),
                        D3Avatar(name: 'Jane Kim'),
                        D3Avatar(name: 'Mark Santos'),
                        D3Avatar(name: 'Amy Chen'),
                        D3Avatar(name: 'Luis Reyes'),
                        D3Avatar(name: 'Grace Park'),
                      ],
                      max: 4,
                    ),
                    const SizedBox(height: 12),
                    D3AvatarGroup(
                      size: D3AvatarSize.sm,
                      avatars: const [
                        D3Avatar(name: 'Alice Brown'),
                        D3Avatar(name: 'Bob Chen'),
                        D3Avatar(name: 'Clara Davis'),
                        D3Avatar(name: 'Dan Lee'),
                        D3Avatar(name: 'Eva Morales'),
                      ],
                      max: 3,
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

/// Small helper that stacks an avatar above a size label.
class _LabelledAvatar extends StatelessWidget {
  const _LabelledAvatar({required this.avatar, required this.label});

  final D3Avatar avatar;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        avatar,
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
