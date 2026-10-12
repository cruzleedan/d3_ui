import 'package:d3_ui/d3_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Future<double> _searchPageWidth(
  WidgetTester tester, {
  required bool useRootNavigator,
}) async {
  tester.view.physicalSize = const Size(1000, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: D3AppTheme.light(),
      home: Center(
        // An app nested in a frame, as the showcase embeds its Places preview.
        child: SizedBox(
          width: 300,
          height: 600,
          child: MaterialApp(
            theme: D3AppTheme.light(),
            home: Scaffold(
              body: D3SearchAnchor<String, String>.local(
                hint: 'Search things',
                useRootNavigator: useRootNavigator,
                items: const ['a', 'b'],
                filterItems: (items, query, filters) => items,
                resultBuilder: (context, results, query) =>
                    const Text('results'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Search things'));
  await tester.pumpAndSettle();
  return tester.getSize(find.byType(TextField)).width;
}

void main() {
  testWidgets('the search page stays inside a nested app when asked', (
    tester,
  ) async {
    expect(
      await _searchPageWidth(tester, useRootNavigator: false),
      lessThan(300),
    );
  });

  testWidgets('by default it covers the whole root app', (tester) async {
    expect(
      await _searchPageWidth(tester, useRootNavigator: true),
      greaterThan(300),
    );
  });
}
