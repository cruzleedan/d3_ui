import 'package:d3_ui/d3_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('each nav item is centred in its equal share of the bar', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: D3AppTheme.light(),
        home: Scaffold(
          bottomNavigationBar: D3NavBar(
            selectedIndex: 0,
            onTabSelected: (_) {},
            items: const [
              D3NavItem(icon: Icons.explore, label: 'Explore'),
              D3NavItem(icon: Icons.favorite, label: 'Saved'),
              D3NavItem(icon: Icons.settings, label: 'Settings'),
            ],
          ),
        ),
      ),
    );
    final bar = tester.getRect(find.byType(D3NavBar));
    final third = bar.width / 3;
    for (var i = 0; i < 3; i++) {
      final label = ['Explore', 'Saved', 'Settings'][i];
      final centre = tester.getCenter(find.text(label)).dx;
      expect(
        centre,
        closeTo(bar.left + third * (i + 0.5), 1),
        reason: '$label should sit at the middle of cell $i',
      );
    }
  });

  testWidgets('an item is still tappable across its whole 48 dp cell', (
    tester,
  ) async {
    var tapped = -1;
    await tester.pumpWidget(
      MaterialApp(
        theme: D3AppTheme.light(),
        home: Scaffold(
          bottomNavigationBar: D3NavBar(
            selectedIndex: 0,
            onTabSelected: (i) => tapped = i,
            items: const [
              D3NavItem(icon: Icons.explore, label: 'Explore'),
              D3NavItem(icon: Icons.favorite, label: 'Saved'),
            ],
          ),
        ),
      ),
    );
    final cell = tester.getRect(find.byType(D3NavBar));
    // Far from the icon and label, still inside the second item's cell.
    await tester.tapAt(Offset(cell.left + cell.width * 0.95, cell.center.dy));
    expect(tapped, 1);
  });
}
