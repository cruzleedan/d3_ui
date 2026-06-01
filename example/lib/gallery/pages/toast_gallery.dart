import 'package:flutter/material.dart';
import 'package:d3_ui/d3_ui.dart';

import '../shared/gallery_section.dart';

class ToastGallery extends StatelessWidget {
  const ToastGallery({
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
                title: 'Variants',
                child: Column(
                  children: [
                    _ToastButton(
                      label: 'Success',
                      color: const Color(0xFF1D9E75),
                      onPressed: () => D3Toast.success(
                        context,
                        title: 'Changes saved',
                      ),
                    ),
                    const SizedBox(height: 10),
                    _ToastButton(
                      label: 'Error',
                      color: colors.error,
                      onPressed: () => D3Toast.error(
                        context,
                        title: 'Upload failed',
                        message: 'Check your connection and try again.',
                      ),
                    ),
                    const SizedBox(height: 10),
                    _ToastButton(
                      label: 'Warning',
                      color: const Color(0xFF854F0B),
                      onPressed: () => D3Toast.warning(
                        context,
                        title: 'Storage almost full',
                        message: 'Free up space to continue syncing.',
                      ),
                    ),
                    const SizedBox(height: 10),
                    _ToastButton(
                      label: 'Info',
                      color: const Color(0xFF0C447C),
                      onPressed: () => D3Toast.info(
                        context,
                        title: 'Tip: swipe left to delete',
                      ),
                    ),
                    const SizedBox(height: 10),
                    _ToastButton(
                      label: 'Neutral',
                      color: colors.onSurfaceVariant,
                      onPressed: () => D3Toast.show(
                        context,
                        title: 'New version available',
                        variant: D3ToastVariant.neutral,
                      ),
                    ),
                  ],
                ),
              ),
              GallerySection(
                title: 'With action',
                child: Column(
                  children: [
                    _ToastButton(
                      label: 'Success + undo',
                      color: const Color(0xFF1D9E75),
                      onPressed: () => D3Toast.success(
                        context,
                        title: 'Message deleted',
                        action: D3ToastAction(
                          label: 'Undo',
                          onPressed: () {},
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _ToastButton(
                      label: 'Error + retry',
                      color: colors.error,
                      onPressed: () => D3Toast.error(
                        context,
                        title: 'Sync failed',
                        message: 'Could not connect to server.',
                        action: D3ToastAction(
                          label: 'Retry',
                          onPressed: () {},
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _ToastButton(
                      label: 'Warning + action',
                      color: const Color(0xFF854F0B),
                      onPressed: () => D3Toast.warning(
                        context,
                        title: 'Storage almost full',
                        action: D3ToastAction(
                          label: 'Manage',
                          onPressed: () {},
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _ToastButton(
                      label: 'Neutral + update',
                      color: colors.primary,
                      onPressed: () => D3Toast.show(
                        context,
                        title: 'Version 2.1 available',
                        variant: D3ToastVariant.neutral,
                        action: D3ToastAction(
                          label: 'Update',
                          onPressed: () {},
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              GallerySection(
                title: 'Persistent (no auto-dismiss)',
                child: _ToastButton(
                  label: 'Show persistent toast',
                  color: colors.primary,
                  onPressed: () => D3Toast.show(
                    context,
                    title: 'You are offline',
                    message: 'Changes will sync when you reconnect.',
                    variant: D3ToastVariant.warning,
                    duration: Duration.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToastButton extends StatelessWidget {
  const _ToastButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: D3Button(
        label: label,
        variant: D3ButtonVariant.outlined,
        onPressed: onPressed,
      ),
    );
  }
}
