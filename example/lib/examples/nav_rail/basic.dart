import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// A navigation rail, collapsed or extended, with a leading action and a badge.
class NavRailExample extends StatefulWidget {
  const NavRailExample({super.key});

  @override
  State<NavRailExample> createState() => _NavRailExampleState();
}

class _NavRailExampleState extends State<NavRailExample> {
  int _selected = 0;
  bool _extended = false;

  static const _items = [
    D3NavItem(
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore_rounded,
      label: 'Explore',
    ),
    D3NavItem(
      icon: Icons.favorite_border_rounded,
      activeIcon: Icons.favorite_rounded,
      label: 'Saved',
      badgeCount: 2,
    ),
    D3NavItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        D3Toggle(
          value: _extended,
          label: 'Extended',
          onChanged: (v) => setState(() => _extended = v),
        ),
        Container(
          height: 300,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            border: Border.all(color: context.d3Colors.outline),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              D3NavRail(
                items: _items,
                selectedIndex: _selected,
                extended: _extended,
                onDestinationSelected: (i) => setState(() => _selected = i),
                leading: D3ScrimIconButton(
                  icon: Icons.menu_rounded,
                  semanticsLabel: 'Menu',
                  iconColor: context.d3Colors.onSurface,
                  scrimColor: context.d3Colors.surface,
                  onTap: () => setState(() => _extended = !_extended),
                ),
              ),
              Expanded(
                child: Center(child: Text('${_items[_selected].label} page')),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
