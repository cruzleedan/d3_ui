import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// A bottom nav bar with badges, plus one with a centre action.
class NavBarExample extends StatefulWidget {
  const NavBarExample({super.key});

  @override
  State<NavBarExample> createState() => _NavBarExampleState();
}

class _NavBarExampleState extends State<NavBarExample> {
  int _plain = 0;
  int _withAction = 0;
  String _added = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        _framed(
          context,
          D3NavBar(
            selectedIndex: _plain,
            onTabSelected: (i) => setState(() => _plain = i),
            items: const [
              D3NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Home',
              ),
              D3NavItem(icon: Icons.search_outlined, label: 'Explore'),
              D3NavItem(
                icon: Icons.notifications_outlined,
                label: 'Alerts',
                badgeCount: 3,
              ),
              D3NavItem(icon: Icons.person_outline, label: 'Profile'),
            ],
          ),
        ),
        _framed(
          context,
          D3NavBar(
            selectedIndex: _withAction,
            onTabSelected: (i) => setState(() => _withAction = i),
            centerAction: D3NavBarCenterAction(
              icon: Icons.add,
              semanticsLabel: 'New entry',
              onPressed: () => setState(() => _added = 'New entry tapped'),
            ),
            items: const [
              D3NavItem(icon: Icons.home_outlined, label: 'Home'),
              D3NavItem(icon: Icons.list_outlined, label: 'Activity'),
              D3NavItem(icon: Icons.settings_outlined, label: 'Settings'),
            ],
          ),
        ),
        if (_added.isNotEmpty) Text(_added),
      ],
    );
  }

  Widget _framed(BuildContext context, Widget bar) => Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          border: Border.all(color: context.d3Colors.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        child: bar,
      );
}
