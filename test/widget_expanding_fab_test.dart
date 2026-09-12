import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:d3_ui/d3_ui.dart';

// Root context/work/0045: only the icon circle was tappable, so pointing at
// an action's label did nothing.

Future<void> _openMenu(
  WidgetTester tester, {
  required List<D3FabAction> actions,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: D3AppTheme.light(),
      home: Scaffold(
        floatingActionButton: D3ExpandingFab(actions: actions),
      ),
    ),
  );
  await tester.pumpAndSettle();

  // Tap the FAB itself to expand the menu.
  await tester.tap(find.byIcon(Icons.add_rounded));
  await tester.pumpAndSettle();
}

void main() {
  group('D3ExpandingFab', () {
    testWidgets('tapping an action label triggers it, not just the icon', (
      tester,
    ) async {
      var pressed = 0;
      await _openMenu(
        tester,
        actions: [
          D3FabAction(
            icon: Icons.person_add_rounded,
            label: 'New Project',
            onPressed: () => pressed++,
          ),
        ],
      );

      expect(find.text('New Project'), findsOneWidget);

      await tester.tap(find.text('New Project'));
      await tester.pumpAndSettle();

      expect(pressed, 1, reason: 'the label is part of the tap target');
    });

    testWidgets('tapping the action icon still triggers it', (tester) async {
      var pressed = 0;
      await _openMenu(
        tester,
        actions: [
          D3FabAction(
            icon: Icons.person_add_rounded,
            label: 'New Project',
            onPressed: () => pressed++,
          ),
        ],
      );

      await tester.tap(find.byIcon(Icons.person_add_rounded));
      await tester.pumpAndSettle();

      expect(pressed, 1);
    });

    testWidgets('each action label triggers its own action', (tester) async {
      var projects = 0;
      var visits = 0;
      await _openMenu(
        tester,
        actions: [
          D3FabAction(
            icon: Icons.person_add_rounded,
            label: 'New Project',
            onPressed: () => projects++,
          ),
          D3FabAction(
            icon: Icons.assignment_rounded,
            label: 'New Visit',
            onPressed: () => visits++,
          ),
        ],
      );

      await tester.tap(find.text('New Visit'));
      await tester.pumpAndSettle();

      expect(visits, 1);
      expect(projects, 0, reason: 'labels must not be crossed-wired');
    });
  });
}
