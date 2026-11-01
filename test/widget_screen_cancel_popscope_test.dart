import 'package:d3_ui/d3_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Future<void> open(WidgetTester t, {required bool canPop}) async {
    await t.pumpWidget(
      MaterialApp(
        theme: D3AppTheme.light(),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => PopScope(
                  canPop: canPop,
                  child: D3Screen(
                    title: 'Edit',
                    leading: D3ScreenLeading.cancel,
                    body: const SizedBox(),
                  ),
                ),
              ),
            ),
            child: const Text('go'),
          ),
        ),
      ),
    );
    await t.tap(find.text('go'));
    await t.pumpAndSettle();
  }

  testWidgets('Cancel closes an unguarded screen', (t) async {
    await open(t, canPop: true);
    await t.tap(find.text('Cancel'));
    await t.pumpAndSettle();
    expect(find.text('Edit'), findsNothing);
  });

  testWidgets('Cancel respects a PopScope that blocks the pop', (t) async {
    await open(t, canPop: false);
    await t.tap(find.text('Cancel'));
    await t.pumpAndSettle();
    expect(find.text('Edit'), findsOneWidget);
  });
}
