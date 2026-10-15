import 'package:d3_ui/d3_ui.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:material_ui/material_ui.dart';

import 'app.dart' show pageForId;
import 'brands.dart';
import 'page_model.dart';
import 'pages/components_page.dart';
import 'registry.dart';
import 'scope.dart';
import 'search/search_palette.dart';
import 'search/search_shortcuts.dart';
import 'version.dart';

/// Width from which the navigation rail sits beside the page and the bottom bar
/// goes away.
const double wideBreakpoint = 900;

/// The four places the navigation leads to. Components also opens the pane that
/// lists every component.
enum _Destination {
  home('Home', Icons.home_outlined, Icons.home_rounded, 'overview'),
  components(
    'Components',
    Icons.widgets_outlined,
    Icons.widgets_rounded,
    'components',
  ),
  theme('Theme', Icons.palette_outlined, Icons.palette_rounded, 'theme'),
  patterns(
    'Patterns',
    Icons.explore_outlined,
    Icons.explore_rounded,
    'patterns',
  );

  const _Destination(this.label, this.icon, this.activeIcon, this.pageId);

  final String label;
  final IconData icon;
  final IconData activeIcon;

  /// The page the destination opens.
  final String pageId;

  /// The destination a page belongs to.
  static _Destination of(ShowcasePage page) => switch (page.id) {
        'overview' => home,
        'theme' => theme,
        'patterns' => patterns,
        _ => components,
      };

  D3NavItem get navItem =>
      D3NavItem(icon: icon, activeIcon: activeIcon, label: label);
}

/// The showcase's chrome: a navigation rail (a bottom bar on phones), the
/// Components pane, search, brand and theme, and the current page.
class ShowcaseShell extends StatefulWidget {
  const ShowcaseShell({super.key, this.embed = false});

  /// Only the page, no navigation (for a frame in another site).
  final bool embed;

  @override
  State<ShowcaseShell> createState() => _ShowcaseShellState();
}

class _ShowcaseShellState extends State<ShowcaseShell> {
  ShowcasePage get _page => pageForId(ShowcaseScope.of(context).pageId);

  /// Pages visited, newest first, for the search palette's empty state.
  final List<String> _recent = [];

  void _open(String id) => ShowcaseScope.of(context).onPageChanged(id);

  void _noteVisit(ShowcasePage page) {
    if (page.group == ShowcaseGroup.start) return;
    _recent
      ..remove(page.id)
      ..insert(0, page.id);
    if (_recent.length > 8) _recent.removeLast();
  }

  Future<void> _search() async {
    final id = await showShowcaseSearch(
      context,
      recentIds: List.unmodifiable(_recent),
    );
    if (id != null && mounted) _open(id);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    final page = _page;
    _noteVisit(page);
    final body = ShowcaseNav(
      open: _open,
      // A short fade and rise when the page changes; none when the user prefers
      // reduced motion.
      child: AnimatedSwitcher(
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeIn,
        layoutBuilder: (current, previous) => Stack(
          fit: StackFit.expand,
          children: [...previous, if (current != null) current],
        ),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.012),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        ),
        child: KeyedSubtree(
          key: ValueKey(page.id),
          child: Builder(builder: page.builder),
        ),
      ),
    );

    if (widget.embed) {
      return Scaffold(backgroundColor: colors.surface, body: body);
    }

    final destination = _Destination.of(page);
    final wide = MediaQuery.sizeOf(context).width >= wideBreakpoint;
    final Widget scaffold = wide
        ? Scaffold(
            backgroundColor: colors.surface,
            body: Row(
              children: [
                D3NavRail(
                  items: [for (final d in _Destination.values) d.navItem],
                  selectedIndex: destination.index,
                  onDestinationSelected: (i) =>
                      _open(_Destination.values[i].pageId),
                  leading: _SearchButton(onPressed: _search),
                  trailing: const _RailUtilities(),
                ),
                if (destination == _Destination.components)
                  _ComponentsPane(current: page, onOpen: _open),
                Expanded(child: body),
              ],
            ),
          )
        : Scaffold(
            backgroundColor: colors.surface,
            appBar: AppBar(
              backgroundColor: colors.surface,
              scrolledUnderElevation: 0,
              title: Text(
                page.title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              actions: [
                _SearchButton(onPressed: _search, compact: true),
                const _BrandMenu(),
                const _ThemeButton(),
                const SizedBox(width: 4),
              ],
            ),
            body: body,
            bottomNavigationBar: D3NavBar(
              items: [for (final d in _Destination.values) d.navItem],
              selectedIndex: destination.index,
              onTabSelected: (i) => _open(_Destination.values[i].pageId),
            ),
          );
    return SearchShortcuts(onSearch: _search, child: scaffold);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Rail pieces
// ─────────────────────────────────────────────────────────────────────────────

String get _searchShortcutLabel {
  final mac = defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.iOS;
  return mac ? 'Cmd K' : 'Ctrl K';
}

/// The round search button on top of the rail (an icon in the app bar on a phone).
class _SearchButton extends StatelessWidget {
  const _SearchButton({required this.onPressed, this.compact = false});

  final VoidCallback onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    final label = 'Search ($_searchShortcutLabel)';
    return D3Tooltip(
      message: label,
      child: Semantics(
        container: true,
        button: true,
        label: 'Search',
        excludeSemantics: true,
        child: compact
            ? IconButton(
                onPressed: onPressed,
                constraints:
                    const BoxConstraints.tightFor(width: 48, height: 48),
                icon: const Icon(Icons.search_rounded),
              )
            : Material(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  onTap: onPressed,
                  borderRadius: BorderRadius.circular(18),
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: Icon(Icons.search_rounded, color: colors.primary),
                  ),
                ),
              ),
      ),
    );
  }
}

/// Brand picker, theme cycle and version at the bottom of the rail.
class _RailUtilities extends StatelessWidget {
  const _RailUtilities();

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _BrandMenu(),
        const SizedBox(height: 4),
        const _ThemeButton(),
        const SizedBox(height: 10),
        D3Tooltip(
          message: ShowcaseVersion.label,
          child: Text(
            ShowcaseVersion.short,
            style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

/// A round swatch of the current brand; opens a menu to choose another. The
/// whole showcase recolours live.
class _BrandMenu extends StatelessWidget {
  const _BrandMenu();

  @override
  Widget build(BuildContext context) {
    final scope = ShowcaseScope.of(context);
    final colors = context.d3Colors;
    final current =
        scope.brandThemes[scope.brand.id]!.light.colorScheme.primary;
    final wide = MediaQuery.sizeOf(context).width >= wideBreakpoint;
    return D3Menu(
      // From the rail's bottom the menu opens upwards, from the app bar down.
      alignment: wide ? Alignment.bottomLeft : Alignment.topRight,
      width: 240,
      entries: [
        const D3MenuSection('Brand'),
        for (final brand in showcaseBrands)
          D3MenuItem(
            label: brand.label,
            isSelected: brand.id == scope.brand.id,
            onPressed: () => scope.onBrandChanged(brand),
          ),
        const D3MenuDivider(),
        const D3MenuSection('Version'),
        D3MenuItem(label: ShowcaseVersion.label, enabled: false),
      ],
      triggerBuilder: (context, toggle) => D3Tooltip(
        message: 'Brand: ${scope.brand.label}',
        child: Semantics(
          container: true,
          button: true,
          label: 'Brand: ${scope.brand.label}',
          excludeSemantics: true,
          child: InkResponse(
            onTap: toggle,
            radius: 26,
            child: SizedBox(
              width: 48,
              height: 48,
              child: Center(
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: current,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.outline, width: 1.5),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One button that cycles light, dark, then the device setting.
class _ThemeButton extends StatelessWidget {
  const _ThemeButton();

  @override
  Widget build(BuildContext context) {
    final scope = ShowcaseScope.of(context);
    final (icon, name, next) = switch (scope.themeMode) {
      ThemeMode.light => (Icons.light_mode_outlined, 'light', ThemeMode.dark),
      ThemeMode.dark => (Icons.dark_mode_outlined, 'dark', ThemeMode.system),
      ThemeMode.system => (
          Icons.brightness_auto_outlined,
          'device setting',
          ThemeMode.light,
        ),
    };
    return D3Tooltip(
      message: 'Theme: $name (tap to change)',
      child: Semantics(
        container: true,
        button: true,
        label: 'Theme: $name',
        excludeSemantics: true,
        child: IconButton(
          onPressed: () => scope.onThemeModeChanged(next),
          constraints: const BoxConstraints.tightFor(width: 48, height: 48),
          icon: Icon(icon),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// The Components pane
// ─────────────────────────────────────────────────────────────────────────────

/// The list of every component, by group, beside the rail.
class _ComponentsPane extends StatelessWidget {
  const _ComponentsPane({required this.current, required this.onOpen});

  final ShowcasePage current;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    return Container(
      width: 248,
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: colors.outlineVariant)),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(12, 20, 12, 24),
        children: [
          _PaneItem(
            icon: Icons.apps_rounded,
            title: 'All components',
            selected: current.id == 'components',
            onTap: () => onOpen('components'),
          ),
          for (final group in componentGroups) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 18, 0, 6),
              child: Text(
                group.label.toUpperCase(),
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
            for (final page in showcasePages.where((p) => p.group == group))
              _PaneItem(
                icon: page.icon,
                title: page.title,
                selected: page.id == current.id,
                onTap: () => onOpen(page.id),
              ),
          ],
        ],
      ),
    );
  }
}

class _PaneItem extends StatelessWidget {
  const _PaneItem({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Semantics(
        button: true,
        selected: selected,
        child: Material(
          color: selected ? colors.primaryContainer : Colors.transparent,
          borderRadius: context.d3Shape.circularMd,
          child: InkWell(
            borderRadius: context.d3Shape.circularMd,
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 40),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      size: 18,
                      color:
                          selected ? colors.primary : colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w400,
                          color: selected ? colors.primary : colors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
