import 'package:d3_ui/d3_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Widget _app(Widget child) => MaterialApp(
  theme: D3AppTheme.light(),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('D3InfoButton opens a sheet with the message', (t) async {
    await t.pumpWidget(
      _app(
        const D3InfoButton(title: 'Layouts', message: 'Pick what a PDF has.'),
      ),
    );
    expect(find.byTooltip('About Layouts'), findsOneWidget);
    expect(find.text('Pick what a PDF has.'), findsNothing);
    await t.tap(find.byTooltip('About Layouts'));
    await t.pumpAndSettle();
    expect(find.text('Pick what a PDF has.'), findsOneWidget);
    expect(find.text('Layouts'), findsOneWidget);
  });

  testWidgets('D3InfoButton keeps a 48 dp target', (t) async {
    await t.pumpWidget(
      _app(const D3InfoButton(title: 'Layouts', message: 'x')),
    );
    final size = t.getSize(find.byType(IconButton));
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));
  });

  testWidgets('D3Toast.undo shows Undo and calls back', (t) async {
    var undone = false;
    await t.pumpWidget(
      _app(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => D3Toast.undo(
              context,
              title: 'Visit deleted',
              onUndo: () => undone = true,
            ),
            child: const Text('go'),
          ),
        ),
      ),
    );
    await t.tap(find.text('go'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 400));
    expect(find.text('Visit deleted'), findsOneWidget);
    await t.tap(find.text('Undo'));
    expect(undone, isTrue);
  });
}
