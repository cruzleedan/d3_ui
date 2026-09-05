import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:d3_ui/d3_ui.dart';

Widget _wrap(Widget navBar) {
  return MaterialApp(
    theme: D3AppTheme.light(),
    home: Scaffold(bottomNavigationBar: navBar),
  );
}

/// Screen width used by the default test surface (800x600).
const _screenWidth = 800.0;

double _centerXOf(WidgetTester tester, Finder finder) {
  final rect = tester.getRect(finder);
  return rect.left + rect.width / 2;
}

void main() {
  group('D3NavBar without centerAction', () {
    testWidgets('renders all items and calls onTabSelected', (tester) async {
      var selected = -1;
      await tester.pumpWidget(
        _wrap(
          D3NavBar(
            selectedIndex: 0,
            onTabSelected: (i) => selected = i,
            items: const [
              D3NavItem(icon: Icons.home_outlined, label: 'Home'),
              D3NavItem(icon: Icons.search_outlined, label: 'Search'),
              D3NavItem(icon: Icons.settings_outlined, label: 'Settings'),
            ],
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);

      await tester.tap(find.text('Search'));
      expect(selected, 1);
    });
  });

  group('D3NavBar with centerAction — true centering', () {
    testWidgets('center action sits at the bar\'s true horizontal center '
        'with an odd (3) item count', (tester) async {
      await tester.pumpWidget(
        _wrap(
          D3NavBar(
            selectedIndex: 0,
            onTabSelected: (_) {},
            items: const [
              D3NavItem(icon: Icons.home_outlined, label: 'Home'),
              D3NavItem(icon: Icons.list_outlined, label: 'Activity'),
              D3NavItem(icon: Icons.settings_outlined, label: 'Settings'),
            ],
            centerAction: D3NavBarCenterAction(
              icon: Icons.add,
              onPressed: () {},
              semanticsLabel: 'New entry',
            ),
          ),
        ),
      );

      final actionCenterX = _centerXOf(
        tester,
        find.bySemanticsLabel('New entry'),
      );
      expect(actionCenterX, closeTo(_screenWidth / 2, 1.0));
    });

    testWidgets('center action sits at the bar\'s true horizontal center '
        'with an even (4) item count', (tester) async {
      await tester.pumpWidget(
        _wrap(
          D3NavBar(
            selectedIndex: 0,
            onTabSelected: (_) {},
            items: const [
              D3NavItem(icon: Icons.home_outlined, label: 'Home'),
              D3NavItem(icon: Icons.search_outlined, label: 'Search'),
              D3NavItem(icon: Icons.notifications_outlined, label: 'Alerts'),
              D3NavItem(icon: Icons.person_outlined, label: 'Profile'),
            ],
            centerAction: D3NavBarCenterAction(
              icon: Icons.add,
              onPressed: () {},
              semanticsLabel: 'New entry',
            ),
          ),
        ),
      );

      final actionCenterX = _centerXOf(
        tester,
        find.bySemanticsLabel('New entry'),
      );
      expect(actionCenterX, closeTo(_screenWidth / 2, 1.0));
    });

    testWidgets('2 left items + 1 right item still centers with a 3-item split', (
      tester,
    ) async {
      // Regression check for the original bug: splitIndex=2 for 3 items
      // put 2 on the left and 1 on the right — verify the action is still
      // pixel-centered despite that asymmetric item count on each side.
      await tester.pumpWidget(
        _wrap(
          D3NavBar(
            selectedIndex: 0,
            onTabSelected: (_) {},
            items: const [
              D3NavItem(icon: Icons.apartment_outlined, label: 'Projects'),
              D3NavItem(icon: Icons.fact_check_outlined, label: 'Visits'),
              D3NavItem(icon: Icons.settings_outlined, label: 'Settings'),
            ],
            centerAction: D3NavBarCenterAction(
              icon: Icons.add,
              onPressed: () {},
              semanticsLabel: 'New Visit',
            ),
          ),
        ),
      );

      final actionCenterX = _centerXOf(
        tester,
        find.bySemanticsLabel('New Visit'),
      );
      expect(actionCenterX, closeTo(_screenWidth / 2, 1.0));
    });

    testWidgets('selectedIndex/onTabSelected still map correctly across '
        'the split for items on both sides of the action', (tester) async {
      var selected = -1;
      await tester.pumpWidget(
        _wrap(
          D3NavBar(
            selectedIndex: 2,
            onTabSelected: (i) => selected = i,
            items: const [
              D3NavItem(icon: Icons.apartment_outlined, label: 'Projects'),
              D3NavItem(icon: Icons.fact_check_outlined, label: 'Visits'),
              D3NavItem(icon: Icons.settings_outlined, label: 'Settings'),
            ],
            centerAction: D3NavBarCenterAction(
              icon: Icons.add,
              onPressed: () {},
              semanticsLabel: 'New Visit',
            ),
          ),
        ),
      );

      // index 2 ("Settings") is in the right-hand group after the split —
      // confirm it's still shown as selected despite being re-indexed
      // within its own Row.
      expect(find.text('Settings'), findsOneWidget);

      await tester.tap(find.text('Projects'));
      expect(selected, 0);

      await tester.tap(find.text('Visits'));
      expect(selected, 1);

      await tester.tap(find.text('Settings'));
      expect(selected, 2);
    });

    testWidgets('center action tap calls onPressed, not onTabSelected', (
      tester,
    ) async {
      var actionPressed = false;
      var tabSelected = -1;
      await tester.pumpWidget(
        _wrap(
          D3NavBar(
            selectedIndex: 0,
            onTabSelected: (i) => tabSelected = i,
            items: const [
              D3NavItem(icon: Icons.home_outlined, label: 'Home'),
              D3NavItem(icon: Icons.settings_outlined, label: 'Settings'),
            ],
            centerAction: D3NavBarCenterAction(
              icon: Icons.add,
              onPressed: () => actionPressed = true,
              semanticsLabel: 'New entry',
            ),
          ),
        ),
      );

      await tester.tap(find.bySemanticsLabel('New entry'));
      expect(actionPressed, isTrue);
      expect(tabSelected, -1);
    });
  });
}
