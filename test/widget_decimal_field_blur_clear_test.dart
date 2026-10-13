import 'package:d3_ui/d3_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Widget _app(Widget field, {Widget? below}) => MaterialApp(
  theme: D3AppTheme.light(),
  home: Scaffold(
    body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        field,
        below ?? const TextField(key: Key('other')),
      ],
    ),
  ),
);

String _text(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField).first).controller!.text;

void main() {
  group('D3DecimalField on blur', () {
    Future<void> typeThenBlur(
      WidgetTester tester,
      String typed, {
      int places = 2,
    }) async {
      await tester.pumpWidget(
        _app(D3DecimalField(label: 'Price', decimalPlaces: places)),
      );
      await tester.tap(find.byType(TextField).first);
      await tester.pump();
      await tester.enterText(find.byType(TextField).first, typed);
      await tester.pump();
      await tester.tap(find.byKey(const Key('other')));
      await tester.pumpAndSettle();
    }

    testWidgets('pads to decimalPlaces', (tester) async {
      await typeThenBlur(tester, '5');
      expect(_text(tester), '5.00');
    });

    testWidgets('pads a part-typed fraction', (tester) async {
      await typeThenBlur(tester, '5.1');
      expect(_text(tester), '5.10');
    });

    testWidgets('a trailing dot becomes the fixed form', (tester) async {
      await typeThenBlur(tester, '5.');
      expect(_text(tester), '5.00');
    });

    testWidgets('follows decimalPlaces: 3 and 0', (tester) async {
      await typeThenBlur(tester, '2.5', places: 3);
      expect(_text(tester), '2.500');
      await typeThenBlur(tester, '7', places: 0);
      expect(_text(tester), '7');
    });

    testWidgets('a lone dot is cleared', (tester) async {
      await typeThenBlur(tester, '.');
      expect(_text(tester), isEmpty);
    });

    testWidgets('reports the number once, like typing does', (tester) async {
      final seen = <double>[];
      await tester.pumpWidget(
        _app(D3DecimalField(label: 'Price', onChanged: seen.add)),
      );
      await tester.tap(find.byType(TextField).first);
      await tester.pump();
      await tester.enterText(find.byType(TextField).first, '5');
      await tester.tap(find.byKey(const Key('other')));
      await tester.pumpAndSettle();
      expect(seen.last, 5.0);
    });

    testWidgets('leaves an already formatted value alone', (tester) async {
      await typeThenBlur(tester, '12.34');
      expect(_text(tester), '12.34');
    });
  });

  group('D3DecimalField clear button', () {
    testWidgets('shows while focused with text, not otherwise', (tester) async {
      await tester.pumpWidget(
        _app(const D3DecimalField(label: 'Price', initialValue: 4.5)),
      );
      expect(find.byIcon(Icons.close_rounded), findsNothing, reason: 'blurred');
      await tester.tap(find.byType(TextField).first);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    });

    testWidgets('is absent for an empty field and when turned off', (
      tester,
    ) async {
      await tester.pumpWidget(_app(const D3DecimalField(label: 'Price')));
      await tester.tap(find.byType(TextField).first);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.close_rounded), findsNothing);

      await tester.pumpWidget(
        _app(
          const D3DecimalField(
            label: 'Price',
            initialValue: 4.5,
            showClearButton: false,
          ),
        ),
      );
      await tester.tap(find.byType(TextField).first);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.close_rounded), findsNothing);
    });

    for (final kind in [PointerDeviceKind.touch, PointerDeviceKind.mouse]) {
      testWidgets(
        'clears, reports 0.0 and keeps focus (${kind.name}, desktop)',
        (tester) async {
          debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
          final seen = <double>[];
          await tester.pumpWidget(
            _app(
              D3DecimalField(
                label: 'Price',
                initialValue: 4.5,
                onChanged: seen.add,
              ),
            ),
          );
          await tester.tap(find.byType(TextField).first);
          await tester.pumpAndSettle();
          final gesture = await tester.startGesture(
            tester.getCenter(find.byIcon(Icons.close_rounded)),
            kind: kind,
          );
          await tester.pump();
          await gesture.up();
          await tester.pumpAndSettle();
          final text = _text(tester);
          final focused = tester
              .widget<EditableText>(find.byType(EditableText).first)
              .focusNode
              .hasFocus;
          debugDefaultTargetPlatformOverride = null;
          expect(text, isEmpty);
          expect(focused, isTrue);
          expect(seen, [0.0]);
        },
      );
    }

    testWidgets('sits beside a custom suffix', (tester) async {
      await tester.pumpWidget(
        _app(
          const D3DecimalField(
            label: 'Price',
            initialValue: 4.5,
            suffixText: 'USD',
          ),
        ),
      );
      await tester.tap(find.byType(TextField).first);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      expect(find.text('USD'), findsOneWidget);
    });
  });
}
