import 'package:d3_ui/d3_ui.dart';
import 'package:d3_ui_example/patterns/places_app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Future<void> _pumpAt(WidgetTester tester, double width) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(theme: D3AppTheme.light(), home: const PlacesApp()),
  );
  // The list shows a skeleton for a moment; let it finish.
  await tester.pump(const Duration(seconds: 1));
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  testWidgets('compact: bottom bar, one pane, no rail', (tester) async {
    await _pumpAt(tester, 390);
    expect(find.byType(D3NavBar), findsOneWidget);
    expect(find.byType(D3NavRail), findsNothing);
    expect(find.text('Select a place'), findsNothing);
    expect(find.text('Bao House'), findsOneWidget);
  });

  testWidgets('medium: a rail and one pane', (tester) async {
    await _pumpAt(tester, 700);
    expect(find.byType(D3NavRail), findsOneWidget);
    expect(find.byType(D3NavBar), findsNothing);
    expect(find.text('Save place'), findsNothing, reason: 'no detail pane');
  });

  testWidgets('expanded: a rail, and the list beside the detail pane', (
    tester,
  ) async {
    await _pumpAt(tester, 1100);
    expect(find.byType(D3NavRail), findsOneWidget);
    expect(find.byType(D3NavBar), findsNothing);
    // 'Bao House' is in the list and, as the heading, in the detail pane.
    expect(find.text('Bao House'), findsNWidgets(2));
    expect(find.text('Saved'), findsWidgets);
  });

  testWidgets('expanded: choosing a place changes the detail pane', (
    tester,
  ) async {
    await _pumpAt(tester, 1100);
    await tester.tap(find.text('Casa Verde'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Casa Verde'), findsNWidgets(2));
    expect(find.text('Bao House'), findsOneWidget);
  });

  testWidgets('the search is an anchor', (tester) async {
    await _pumpAt(tester, 390);
    expect(
      find.byWidgetPredicate(
        (w) => w.runtimeType.toString().startsWith('D3SearchAnchor'),
      ),
      findsOneWidget,
    );
    expect(find.text('Search places'), findsOneWidget);
  });

  testWidgets('it follows the width it is given, not the window', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: D3AppTheme.light(),
        home: const Center(
          child: SizedBox(width: 420, height: 800, child: PlacesApp()),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    expect(find.byType(D3NavBar), findsOneWidget);
    expect(find.byType(D3NavRail), findsNothing);
  });
}
