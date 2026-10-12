import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

import 'app.dart' show pageForId;
import 'brands.dart';
import 'page_model.dart';
import 'registry.dart';
import 'scope.dart';

/// Width from which the navigation sits beside the page instead of in a drawer.
const double wideBreakpoint = 900;

/// The showcase's chrome: navigation, the brand and theme controls, and the
/// current page. A side panel on wide screens, a drawer on narrow ones.
class ShowcaseShell extends StatefulWidget {
  const ShowcaseShell({super.key, this.initialPageId});

  final String? initialPageId;

  @override
  State<ShowcaseShell> createState() => _ShowcaseShellState();
}

class _ShowcaseShellState extends State<ShowcaseShell> {
  late ShowcasePage _page = pageForId(widget.initialPageId);
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void _open(ShowcasePage page, {required bool closeDrawer}) {
    setState(() => _page = page);
    if (closeDrawer) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    final wide = MediaQuery.sizeOf(context).width >= wideBreakpoint;
    final body = ShowcaseNav(
      open: (id) => _open(pageForId(id), closeDrawer: false),
      child: KeyedSubtree(
        key: ValueKey(_page.id),
        child: Builder(builder: _page.builder),
      ),
    );

    if (wide) {
      return Scaffold(
        backgroundColor: colors.surface,
        body: Row(
          children: [
            SizedBox(
              width: 292,
              child: _Navigation(
                current: _page,
                onOpen: (p) => _open(p, closeDrawer: false),
              ),
            ),
            VerticalDivider(width: 1, color: colors.outlineVariant),
            Expanded(child: body),
          ],
        ),
      );
    }
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        scrolledUnderElevation: 0,
        title: Text(
          _page.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      drawer: Drawer(
        backgroundColor: colors.surface,
        child: _Navigation(
          current: _page,
          onOpen: (p) => _open(p, closeDrawer: true),
        ),
      ),
      body: body,
    );
  }
}

class _Navigation extends StatelessWidget {
  const _Navigation({required this.current, required this.onOpen});

  final ShowcasePage current;
  final ValueChanged<ShowcasePage> onOpen;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    final scope = ShowcaseScope.of(context);
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        children: [
          Text(
            'd3_ui',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'A Flutter design system',
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
          ),
          const SizedBox(height: 18),
          _label(context, 'Brand'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final brand in showcaseBrands)
                _BrandChip(
                  brand: brand,
                  selected: brand.id == scope.brand.id,
                  onTap: () => scope.onBrandChanged(brand),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            scope.brand.summary,
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
          ),
          const SizedBox(height: 16),
          _label(context, 'Theme'),
          D3SegmentedControl<ThemeMode>(
            expand: true,
            selected: scope.themeMode,
            onChanged: scope.onThemeModeChanged,
            segments: const [
              D3Segment(value: ThemeMode.light, label: 'Light'),
              D3Segment(value: ThemeMode.dark, label: 'Dark'),
              D3Segment(value: ThemeMode.system, label: 'System'),
            ],
          ),
          const SizedBox(height: 20),
          for (final group in ShowcaseGroup.values)
            ..._groupItems(context, group),
        ],
      ),
    );
  }

  Widget _label(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: context.d3Colors.onSurfaceVariant,
          ),
        ),
      );

  List<Widget> _groupItems(BuildContext context, ShowcaseGroup group) {
    final pages = showcasePages.where((p) => p.group == group).toList();
    if (pages.isEmpty) return const [];
    final colors = context.d3Colors;
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(4, 14, 0, 6),
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
      for (final page in pages)
        _NavItem(
          page: page,
          selected: page.id == current.id,
          onTap: () => onOpen(page),
        ),
    ];
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.page,
    required this.selected,
    required this.onTap,
  });

  final ShowcasePage page;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: selected ? colors.primaryContainer : Colors.transparent,
        borderRadius: context.d3Shape.circularMd,
        child: InkWell(
          borderRadius: context.d3Shape.circularMd,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            child: Row(
              children: [
                Icon(
                  page.icon,
                  size: 18,
                  color: selected ? colors.primary : colors.onSurfaceVariant,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    page.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      color: selected ? colors.primary : colors.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandChip extends StatelessWidget {
  const _BrandChip({
    required this.brand,
    required this.selected,
    required this.onTap,
  });

  final ShowcaseBrand brand;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    return Semantics(
      button: true,
      selected: selected,
      label: 'Brand ${brand.label}',
      child: InkWell(
        borderRadius: D3Radius.circularFull,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 6, 12, 6),
          decoration: BoxDecoration(
            borderRadius: D3Radius.circularFull,
            border: Border.all(
              color: selected ? colors.primary : colors.outline,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(radius: 7, backgroundColor: brand.swatch),
              const SizedBox(width: 6),
              Text(
                brand.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
