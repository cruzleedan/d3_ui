import 'package:flutter/material.dart';
import 'package:d3_ui/d3_ui.dart';

import '../shared/gallery_section.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Entry point — lists all D3Screen variants
// ─────────────────────────────────────────────────────────────────────────────

class ScreenGallery extends StatelessWidget {
  const ScreenGallery({
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
          'D3Screen',
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
            tooltip: 'Toggle theme',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // ── Box variants ────────────────────────────────────────────────
          GallerySection(
            title: 'Box — auto back',
            child: _DemoTile(
              label: 'Profile (back arrow)',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => _BoxBackScreen(
                    themeMode: themeMode,
                    onToggleTheme: onToggleTheme,
                  ),
                ),
              ),
            ),
          ),

          GallerySection(
            title: 'Box — cancel (modal)',
            child: _DemoTile(
              label: 'Edit profile (cancel)',
              onTap: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => _CancelModalScreen(
                  themeMode: themeMode,
                  onToggleTheme: onToggleTheme,
                ),
              ),
            ),
          ),

          GallerySection(
            title: 'Box — with action',
            child: _DemoTile(
              label: 'Contacts (add icon)',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => _BoxActionScreen(
                    themeMode: themeMode,
                    onToggleTheme: onToggleTheme,
                  ),
                ),
              ),
            ),
          ),

          GallerySection(
            title: 'Box — text action',
            child: _DemoTile(
              label: 'New post (save)',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => _BoxTextActionScreen(
                    themeMode: themeMode,
                    onToggleTheme: onToggleTheme,
                  ),
                ),
              ),
            ),
          ),

          GallerySection(
            title: 'Box — no leading',
            child: _DemoTile(
              label: 'Home (no leading)',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => _BoxNoLeadingScreen(
                    themeMode: themeMode,
                    onToggleTheme: onToggleTheme,
                  ),
                ),
              ),
            ),
          ),

          // ── Sliver variants ─────────────────────────────────────────────
          GallerySection(
            title: 'Sliver — large title + search',
            child: _DemoTile(
              label: 'Contacts (sliver + search)',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => _SliverSearchScreen(
                    themeMode: themeMode,
                    onToggleTheme: onToggleTheme,
                  ),
                ),
              ),
            ),
          ),

          GallerySection(
            title: 'Sliver — no leading',
            child: _DemoTile(
              label: 'Inbox (sliver, no leading)',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => _SliverNoLeadingScreen(
                    themeMode: themeMode,
                    onToggleTheme: onToggleTheme,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helpers
// ─────────────────────────────────────────────────────────────────────────────

class _DemoTile extends StatelessWidget {
  const _DemoTile({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colors.surfaceVariant,
          borderRadius: BorderRadius.circular(D3Radius.md),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colors.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

/// Filler list used inside demo screens to make them scrollable.
Widget _fillerList(D3ColorTokens colors, {int count = 12}) {
  return SliverList.builder(
    itemCount: count,
    itemBuilder: (_, i) => Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      height: 56,
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(D3Radius.sm),
      ),
    ),
  );
}

Widget _fillerListBox(D3ColorTokens colors, {int count = 12}) {
  return ListView.builder(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
    itemCount: count,
    itemBuilder: (_, i) => Container(
      margin: const EdgeInsets.only(bottom: 8),
      height: 56,
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(D3Radius.sm),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Demo screens
// ─────────────────────────────────────────────────────────────────────────────

class _BoxBackScreen extends StatelessWidget {
  const _BoxBackScreen({required this.themeMode, required this.onToggleTheme});
  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    return D3Screen(
      title: 'Profile',
      actions: [
        D3ScreenAction.icon(
          Icons.dark_mode_outlined,
          onPressed: onToggleTheme,
          semanticsLabel: 'Toggle theme',
        ),
      ],
      body: _fillerListBox(colors),
    );
  }
}

class _CancelModalScreen extends StatelessWidget {
  const _CancelModalScreen(
      {required this.themeMode, required this.onToggleTheme});
  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.85,
        child: D3Screen(
          title: 'Edit profile',
          leading: D3ScreenLeading.cancel,
          body: _fillerListBox(colors, count: 6),
        ),
      ),
    );
  }
}

class _BoxActionScreen extends StatelessWidget {
  const _BoxActionScreen(
      {required this.themeMode, required this.onToggleTheme});
  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    return D3Screen(
      title: 'Contacts',
      actions: [
        D3ScreenAction.icon(
          Icons.add_rounded,
          onPressed: () {},
          semanticsLabel: 'Add contact',
        ),
      ],
      body: _fillerListBox(colors),
    );
  }
}

class _BoxTextActionScreen extends StatelessWidget {
  const _BoxTextActionScreen(
      {required this.themeMode, required this.onToggleTheme});
  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    return D3Screen(
      title: 'New post',
      actions: [
        D3ScreenAction.text('Save', onPressed: () => Navigator.pop(context)),
      ],
      body: _fillerListBox(colors, count: 4),
    );
  }
}

class _BoxNoLeadingScreen extends StatelessWidget {
  const _BoxNoLeadingScreen(
      {required this.themeMode, required this.onToggleTheme});
  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    return D3Screen(
      title: 'Home',
      leading: D3ScreenLeading.none,
      actions: [
        D3ScreenAction.icon(
          Icons.notifications_outlined,
          onPressed: () {},
          semanticsLabel: 'Notifications',
        ),
      ],
      body: _fillerListBox(colors),
    );
  }
}

class _SliverSearchScreen extends StatelessWidget {
  const _SliverSearchScreen(
      {required this.themeMode, required this.onToggleTheme});
  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    return D3Screen(
      title: 'Contacts',
      subtitle: '12 people',
      layout: D3ScreenLayout.sliver,
      sliverHeader: D3SearchBar(hint: 'Search contacts…'),
      actions: [
        D3ScreenAction.icon(
          Icons.add_rounded,
          onPressed: () {},
          semanticsLabel: 'Add contact',
        ),
      ],
      body: CustomScrollView(
        slivers: [_fillerList(colors)],
      ),
    );
  }
}

class _SliverNoLeadingScreen extends StatelessWidget {
  const _SliverNoLeadingScreen(
      {required this.themeMode, required this.onToggleTheme});
  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    return D3Screen(
      title: 'Inbox',
      leading: D3ScreenLeading.none,
      layout: D3ScreenLayout.sliver,
      actions: [
        D3ScreenAction.icon(
          Icons.edit_outlined,
          onPressed: () {},
          semanticsLabel: 'Compose',
        ),
      ],
      body: CustomScrollView(
        slivers: [_fillerList(colors)],
      ),
    );
  }
}
