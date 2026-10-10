import 'package:d3_ui/d3_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Widget _host(D3SearchController controller) => MaterialApp(
  theme: D3AppTheme.light(),
  home: Scaffold(
    appBar: AppBar(title: const Text('PAGE HEADER')),
    body: Column(
      children: [
        const Text('PAGE BODY'),
        D3SearchAnchor<String, Never>.local(
          controller: controller,
          presentation: D3SearchPresentation.overlay,
          items: const ['Tonkotsu', 'Shoyu', 'Gyoza'],
          filterItems: (items, q, _) => [
            for (final i in items)
              if (i.toLowerCase().contains(q.toLowerCase())) i,
          ],
          resultBuilder: (context, results, q) => ListView(
            children: [for (final r in results) ListTile(title: Text(r))],
          ),
        ),
      ],
    ),
  ),
);

void main() {
  testWidgets('overlay: translucent mask until typing, then solid results; '
      'tapping the mask closes it', (tester) async {
    final controller = D3SearchController();
    await tester.pumpWidget(_host(controller));

    await tester.tap(find.byType(D3SearchBar));
    await tester.pumpAndSettle();

    // Active, nothing typed: the page behind is still in the tree and no
    // results are shown — only the mask.
    expect(find.text('PAGE BODY'), findsOneWidget);
    expect(find.byKey(const ValueKey('d3-search-mask')), findsOneWidget);
    expect(find.text('Tonkotsu'), findsNothing);

    await tester.enterText(find.byType(TextField).last, 'sho');
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('d3-search-mask')), findsNothing);
    expect(find.text('Shoyu'), findsOneWidget);
    expect(find.text('Tonkotsu'), findsNothing);

    // Clearing the text brings the mask back.
    await tester.enterText(find.byType(TextField).last, '');
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('d3-search-mask')), findsOneWidget);

    await tester.tapAt(const Offset(200, 500));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('d3-search-mask')), findsNothing);
    expect(find.text('PAGE BODY'), findsOneWidget);
  });

  testWidgets('overlay: the back arrow closes it and the controller can open '
      'it from elsewhere', (tester) async {
    final controller = D3SearchController();
    await tester.pumpWidget(_host(controller));

    controller.open();
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('d3-search-mask')), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('d3-search-mask')), findsNothing);
  });
}
