import 'package:d3_ui/d3_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Widget host(ValueChanged<int> onSelected, {int value = 1}) => MaterialApp(
    theme: D3AppTheme.light(),
    home: Scaffold(
      body: Center(
        child: D3MenuPill<int>(
          semanticsLabel: 'Sort',
          options: const [
            D3FilterOption(value: 1, label: 'Newest first'),
            D3FilterOption(value: 2, label: 'Oldest first'),
          ],
          value: value,
          onSelected: onSelected,
        ),
      ),
    ),
  );

  testWidgets('shows the current choice and reports another', (t) async {
    int? picked;
    await t.pumpWidget(host((v) => picked = v));
    expect(find.text('Newest first'), findsOneWidget);
    await t.tap(find.text('Newest first'));
    await t.pumpAndSettle();
    await t.tap(find.text('Oldest first'));
    await t.pumpAndSettle();
    expect(picked, 2);
  });

  testWidgets('is read with its purpose and current choice', (t) async {
    await t.pumpWidget(host((_) {}));
    expect(find.bySemanticsLabel('Sort: Newest first'), findsOneWidget);
  });

  testWidgets('keeps a 48 dp touch height', (t) async {
    await t.pumpWidget(host((_) {}));
    final box = t.getSize(find.byType(GestureDetector).first);
    expect(box.height, greaterThanOrEqualTo(48));
  });
}
