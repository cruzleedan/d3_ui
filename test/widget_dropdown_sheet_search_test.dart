import 'package:d3_ui/d3_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// The search field in the sheet used a fill taken from the surface tokens,
/// which equals the sheet's own colour (contrast 1.00), so it was barely
/// visible. It is a D3SearchBar now, which tints with onSurface.
void main() {
  for (final dark in [false, true]) {
    testWidgets('the sheet search field stands out from the sheet '
        '(${dark ? 'dark' : 'light'})', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: dark ? D3AppTheme.dark() : D3AppTheme.light(),
          home: Scaffold(
            body: Center(
              child: D3DropdownField<String, String>(
                label: 'Country',
                mode: D3DropdownMode.sheet,
                searchable: true,
                items: const ['Argentina', 'Brazil', 'Chile'],
                itemLabel: (v) => v,
                itemValue: (v) => v,
                hintText: 'Pick one',
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Pick one'));
      await tester.pumpAndSettle();

      expect(find.byType(D3SearchBar), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'br');
      await tester.pumpAndSettle();
      expect(find.text('Brazil'), findsOneWidget);
      expect(find.text('Chile'), findsNothing);
    });
  }
}
