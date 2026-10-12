import 'package:d3_ui/d3_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _items = [
  D3NavItem(icon: Icons.explore_outlined, label: 'Explore'),
  D3NavItem(icon: Icons.favorite_border, label: 'Saved', badgeCount: 3),
  D3NavItem(icon: Icons.settings_outlined, label: 'Settings'),
];

Future<void> _pump(
  WidgetTester tester, {
  int selected = 0,
  bool extended = false,
  ValueChanged<int>? onSelected,
}) => tester.pumpWidget(
  MaterialApp(
    theme: D3AppTheme.light(),
    home: Scaffold(
      body: Row(
        children: [
          D3NavRail(
            items: _items,
            selectedIndex: selected,
            extended: extended,
            onDestinationSelected: onSelected ?? (_) {},
            leading: const Icon(Icons.menu, key: Key('lead')),
          ),
          const Expanded(child: Text('body')),
        ],
      ),
    ),
  ),
);

void main() {
  group('D3WindowSizeClass', () {
    test('uses the Material 3 breakpoints', () {
      expect(D3WindowSizeClass.fromWidth(0), D3WindowSizeClass.compact);
      expect(D3WindowSizeClass.fromWidth(599.9), D3WindowSizeClass.compact);
      expect(D3WindowSizeClass.fromWidth(600), D3WindowSizeClass.medium);
      expect(D3WindowSizeClass.fromWidth(839.9), D3WindowSizeClass.medium);
      expect(D3WindowSizeClass.fromWidth(840), D3WindowSizeClass.expanded);
      expect(D3WindowSizeClass.fromWidth(2000).isExpanded, isTrue);
    });

    testWidgets('the builder follows the width it is given, not the window', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1400, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      D3WindowSizeClass? seen;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(size: Size(1400, 800)),
            child: Center(
              child: SizedBox(
                width: 500,
                child: D3WindowSizeBuilder(
                  builder: (context, c) {
                    seen = c;
                    return const SizedBox();
                  },
                ),
              ),
            ),
          ),
        ),
      );
      expect(seen, D3WindowSizeClass.compact);
    });
  });

  group('D3NavRail', () {
    testWidgets('shows every destination and the leading widget', (
      tester,
    ) async {
      await _pump(tester);
      for (final label in ['Explore', 'Saved', 'Settings']) {
        expect(find.text(label), findsOneWidget);
      }
      expect(find.byKey(const Key('lead')), findsOneWidget);
      expect(find.text('3'), findsOneWidget, reason: 'badge');
    });

    testWidgets('tapping a destination reports its index', (tester) async {
      int? picked;
      await _pump(tester, onSelected: (i) => picked = i);
      await tester.tap(find.text('Settings'));
      expect(picked, 2);
    });

    testWidgets('has a ripple (an ink well per destination)', (tester) async {
      await _pump(tester);
      expect(find.byType(InkWell), findsNWidgets(_items.length));
    });

    testWidgets('marks the selected destination for screen readers', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, selected: 1);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Saved').first),
        matchesSemantics(
          label: 'Saved',
          isSelected: true,
          isButton: true,
          hasSelectedState: true,
          hasTapAction: true,
          hasEnabledState: false,
          isEnabled: false,
        ),
      );
      handle.dispose();
    });

    testWidgets('extended is wider and keeps the labels', (tester) async {
      await _pump(tester);
      final narrow = tester.getSize(find.byType(D3NavRail)).width;
      await _pump(tester, extended: true);
      final wide = tester.getSize(find.byType(D3NavRail)).width;
      expect(narrow, D3NavRail.collapsedWidth);
      expect(wide, D3NavRail.extendedWidth);
      expect(find.text('Explore'), findsOneWidget);
    });
  });
}
