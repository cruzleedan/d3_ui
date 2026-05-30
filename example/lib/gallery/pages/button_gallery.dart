import 'package:flutter/material.dart';
import 'package:d3_ui/d3_ui.dart';

import '../shared/gallery_section.dart';

class ButtonGallery extends StatefulWidget {
  const ButtonGallery({
    super.key,
    required this.themeMode,
    required this.onToggleTheme,
  });

  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  @override
  State<ButtonGallery> createState() => _ButtonGalleryState();
}

class _ButtonGalleryState extends State<ButtonGallery> {
  D3ButtonState _asyncState = D3ButtonState.idle;

  Future<void> _simulateAsync() async {
    if (_asyncState != D3ButtonState.idle) return;
    setState(() => _asyncState = D3ButtonState.loading);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _asyncState = D3ButtonState.success);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _asyncState = D3ButtonState.idle);
  }

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
          'D3Button',
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
            onPressed: widget.onToggleTheme,
            tooltip: 'Toggle theme',
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          children: [
            GallerySection(
              title: 'Variants',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _GalleryRow(
                      label: 'Filled',
                      child: D3Button(label: 'Continue', onPressed: () {})),
                  _GalleryRow(
                      label: 'Tonal',
                      child: D3Button(
                          label: 'Edit Profile',
                          variant: D3ButtonVariant.tonal,
                          onPressed: () {})),
                  _GalleryRow(
                      label: 'Outlined',
                      child: D3Button(
                          label: 'Cancel',
                          variant: D3ButtonVariant.outlined,
                          onPressed: () {})),
                  _GalleryRow(
                      label: 'Ghost',
                      child: D3Button(
                          label: 'Learn more',
                          variant: D3ButtonVariant.ghost,
                          onPressed: () {})),
                  _GalleryRow(
                      label: 'Danger',
                      child: D3Button(
                          label: 'Delete',
                          variant: D3ButtonVariant.danger,
                          leadingIcon: Icons.delete_outline_rounded,
                          onPressed: () {})),
                ],
              ),
            ),
            GallerySection(
              title: 'Sizes',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _GalleryRow(
                      label: 'XS',
                      child: D3Button(
                          label: 'Extra Small',
                          size: D3ButtonSize.xs,
                          onPressed: () {})),
                  _GalleryRow(
                      label: 'SM',
                      child: D3Button(
                          label: 'Small',
                          size: D3ButtonSize.sm,
                          onPressed: () {})),
                  _GalleryRow(
                      label: 'MD',
                      child: D3Button(
                          label: 'Medium (default)',
                          size: D3ButtonSize.md,
                          onPressed: () {})),
                  _GalleryRow(
                      label: 'LG',
                      child: D3Button(
                          label: 'Large',
                          size: D3ButtonSize.lg,
                          onPressed: () {})),
                ],
              ),
            ),
            GallerySection(
              title: 'With Icons',
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  D3Button(
                      label: 'Share',
                      leadingIcon: Icons.ios_share_rounded,
                      onPressed: () {}),
                  D3Button(
                      label: 'Export',
                      trailingIcon: Icons.arrow_outward_rounded,
                      variant: D3ButtonVariant.tonal,
                      onPressed: () {}),
                  D3Button(
                      label: 'Settings',
                      leadingIcon: Icons.tune_rounded,
                      variant: D3ButtonVariant.outlined,
                      onPressed: () {}),
                  D3Button.icon(icon: Icons.add_rounded, onPressed: () {}),
                  D3Button.icon(
                      icon: Icons.bookmark_outline_rounded,
                      variant: D3ButtonVariant.tonal,
                      onPressed: () {}),
                  D3Button.icon(
                      icon: Icons.more_horiz_rounded,
                      variant: D3ButtonVariant.outlined,
                      onPressed: () {}),
                ],
              ),
            ),
            GallerySection(
              title: 'Async State — tap to trigger',
              child: D3Button(
                label: 'Save Changes',
                leadingIcon: Icons.save_outlined,
                isFullWidth: true,
                size: D3ButtonSize.lg,
                buttonState: _asyncState,
                loadingLabel: 'Saving…',
                onPressed: _simulateAsync,
              ),
            ),
            GallerySection(
              title: 'Disabled',
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  D3Button(label: 'Filled', onPressed: null),
                  D3Button(
                      label: 'Tonal',
                      variant: D3ButtonVariant.tonal,
                      onPressed: null),
                  D3Button(
                      label: 'Outlined',
                      variant: D3ButtonVariant.outlined,
                      onPressed: null),
                  D3Button(
                      label: 'Danger',
                      variant: D3ButtonVariant.danger,
                      onPressed: null),
                ],
              ),
            ),
            GallerySection(
              title: 'Full Width',
              child: Column(
                children: [
                  D3Button(
                    label: 'Create Account',
                    isFullWidth: true,
                    size: D3ButtonSize.xl,
                    onPressed: () {},
                  ),
                  const SizedBox(height: 10),
                  D3Button(
                    label: 'Sign in instead',
                    isFullWidth: true,
                    size: D3ButtonSize.lg,
                    variant: D3ButtonVariant.outlined,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            GallerySection(
              title: 'Label overflow — ellipsis at maxLines: 1',
              child: SizedBox(
                width: 180,
                child: D3Button(
                  label:
                      'This is a very long button label that will be truncated',
                  onPressed: () {},
                  isFullWidth: true,
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

class _GalleryRow extends StatelessWidget {
  const _GalleryRow({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
