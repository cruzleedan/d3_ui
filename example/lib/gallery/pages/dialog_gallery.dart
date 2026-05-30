import 'package:flutter/material.dart';
import 'package:d3_ui/d3_ui.dart';

import '../shared/gallery_section.dart';

class DialogGallery extends StatelessWidget {
  const DialogGallery({
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
              // ── Centered icon (stacked buttons) ───────────────────────────

              GallerySection(
                title: 'Centered icon — destructive',
                child: D3Button(
                  label: 'Delete account',
                  variant: D3ButtonVariant.ghost,
                  onPressed: () => D3Dialog.show<bool>(
                    context,
                    icon: Icons.delete_outline_rounded,
                    iconColor: colors.error,
                    title: 'Delete account',
                    message:
                        'This will permanently delete your account and all associated data. This cannot be undone.',
                    actions: [
                      D3DialogAction(
                        label: 'Cancel',
                        onPressed: () => Navigator.pop(context, false),
                      ),
                      D3DialogAction(
                        label: 'Delete',
                        isDestructive: true,
                        onPressed: () => Navigator.pop(context, true),
                      ),
                    ],
                  ),
                ),
              ),

              GallerySection(
                title: 'Centered icon — confirmation',
                child: D3Button(
                  label: 'Save changes',
                  onPressed: () => D3Dialog.show<bool>(
                    context,
                    icon: Icons.save_outlined,
                    title: 'Save changes?',
                    message:
                        'Your changes will be saved and visible to others.',
                    actions: [
                      D3DialogAction(
                        label: 'Cancel',
                        onPressed: () => Navigator.pop(context, false),
                      ),
                      D3DialogAction(
                        label: 'Save',
                        isDefault: true,
                        onPressed: () => Navigator.pop(context, true),
                      ),
                    ],
                  ),
                ),
              ),

              GallerySection(
                title: 'Centered icon — sign out',
                child: D3Button(
                  label: 'Sign out',
                  variant: D3ButtonVariant.tonal,
                  onPressed: () => D3Dialog.show<bool>(
                    context,
                    icon: Icons.logout_rounded,
                    iconColor: colors.error,
                    title: 'Sign out?',
                    message: 'You will be returned to the login screen.',
                    actions: [
                      D3DialogAction(
                        label: 'Cancel',
                        onPressed: () => Navigator.pop(context, false),
                      ),
                      D3DialogAction(
                        label: 'Sign out',
                        isDestructive: true,
                        onPressed: () => Navigator.pop(context, true),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Leading icon (text buttons) ────────────────────────────────

              GallerySection(
                title: 'Leading icon — alert',
                child: D3Button(
                  label: 'Show alert',
                  variant: D3ButtonVariant.outlined,
                  onPressed: () => D3Dialog.show(
                    context,
                    icon: Icons.wifi_off_rounded,
                    iconColor: colors.primary,
                    iconPlacement: D3DialogIconPlacement.leading,
                    title: 'Connection lost',
                    message: 'Check your internet connection and try again.',
                    actions: [
                      D3DialogAction(
                        label: 'OK',
                        isDefault: true,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              ),

              GallerySection(
                title: 'Leading icon — warning',
                child: D3Button(
                  label: 'Show warning',
                  variant: D3ButtonVariant.outlined,
                  onPressed: () => D3Dialog.show(
                    context,
                    icon: Icons.warning_amber_rounded,
                    iconColor: Colors.orange,
                    iconPlacement: D3DialogIconPlacement.leading,
                    title: 'Storage almost full',
                    message:
                        'You have used 90% of your storage. Free up space to continue syncing.',
                    actions: [
                      D3DialogAction(
                        label: 'Later',
                        onPressed: () => Navigator.pop(context),
                      ),
                      D3DialogAction(
                        label: 'Manage storage',
                        isDefault: true,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              ),

              // ── No icon ────────────────────────────────────────────────────

              GallerySection(
                title: 'No icon — session expired',
                child: D3Button(
                  label: 'Show message',
                  variant: D3ButtonVariant.tonal,
                  onPressed: () => D3Dialog.show(
                    context,
                    message:
                        'Your session has expired. Please sign in again to continue.',
                    actions: [
                      D3DialogAction(
                        label: 'Sign in',
                        isDefault: true,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Custom content ─────────────────────────────────────────────

              GallerySection(
                title: 'Custom content — rename',
                child: D3Button(
                  label: 'Rename',
                  variant: D3ButtonVariant.outlined,
                  onPressed: () {
                    final controller =
                        TextEditingController(text: 'My project');
                    D3Dialog.show(
                      context,
                      title: 'Rename project',
                      content: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: TextField(
                          controller: controller,
                          autofocus: true,
                          style:
                              TextStyle(fontSize: 14, color: colors.onSurface),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(D3Radius.sm),
                              borderSide: BorderSide(
                                color: colors.outline.withValues(alpha: 0.4),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(D3Radius.sm),
                              borderSide: BorderSide(
                                color: colors.outline.withValues(alpha: 0.4),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(D3Radius.sm),
                              borderSide:
                                  BorderSide(color: colors.primary, width: 1.5),
                            ),
                          ),
                        ),
                      ),
                      actions: [
                        D3DialogAction(
                          label: 'Cancel',
                          onPressed: () => Navigator.pop(context),
                        ),
                        D3DialogAction(
                          label: 'Rename',
                          isDefault: true,
                          onPressed: () =>
                              Navigator.pop(context, controller.text),
                        ),
                      ],
                    );
                  },
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
