import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:d3_ui/d3_ui.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: D3AppTheme.light(),
    darkTheme: D3AppTheme.dark(),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('D3TextField', () {
    testWidgets('suffix buttons respond across their 48 dp tap targets', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const D3TextField(label: 'Password', obscureText: true)),
      );

      for (final offset in [
        const Offset(-22, -22),
        const Offset(22, -22),
        const Offset(-22, 22),
        const Offset(22, 22),
      ]) {
        await tester.enterText(find.byType(TextField), 'secret');
        await tester.pumpAndSettle();

        final clearButton = find
            .ancestor(
              of: find.byIcon(Icons.close_rounded),
              matching: find.byType(GestureDetector),
            )
            .first;
        final visibilityButton = find
            .ancestor(
              of: find.byIcon(Icons.visibility_outlined),
              matching: find.byType(GestureDetector),
            )
            .first;
        final clearRect = tester.getRect(clearButton);
        final visibilityRect = tester.getRect(visibilityButton);
        for (final rect in [clearRect, visibilityRect]) {
          expect(rect.width, greaterThanOrEqualTo(48));
          expect(rect.height, greaterThanOrEqualTo(48));
        }
        expect(clearRect.overlaps(visibilityRect), isFalse);

        await tester.tapAt(visibilityRect.center + offset);
        await tester.pump();
        expect(
          tester.widget<TextField>(find.byType(TextField)).obscureText,
          isFalse,
        );
        await tester.tapAt(visibilityRect.center + offset);
        await tester.pump();
        expect(
          tester.widget<TextField>(find.byType(TextField)).obscureText,
          isTrue,
        );

        await tester.tapAt(clearRect.center + offset);
        await tester.pump();
        final field = tester.widget<TextField>(find.byType(TextField));
        expect(field.controller!.text, isEmpty);
        expect(field.focusNode!.hasFocus, isTrue);
      }
    });

    testWidgets('renders label and hint text', (tester) async {
      await tester.pumpWidget(
        _wrap(const D3TextField(label: 'Email', hintText: 'you@example.com')),
      );
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('you@example.com'), findsOneWidget);
    });

    testWidgets('calls onChanged as the user types', (tester) async {
      String? lastValue;
      await tester.pumpWidget(
        _wrap(D3TextField(label: 'Name', onChanged: (v) => lastValue = v)),
      );
      await tester.enterText(find.byType(TextField), 'Dan');
      expect(lastValue, 'Dan');
    });

    testWidgets('shows clear button only when focused with text', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const D3TextField(label: 'Name')));

      // Idle, empty: no clear button.
      expect(find.byIcon(Icons.close_rounded), findsNothing);

      await tester.enterText(find.byType(TextField), 'Dan');
      await tester.tap(find.byType(TextField));
      await tester.pump();

      // Focused with text: clear button appears.
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, isEmpty);
    });

    testWidgets('does not call onChanged when the field merely gains focus', (
      tester,
    ) async {
      // TextEditingController notifies listeners on any TextEditingValue
      // change, including a selection-only update — and focusing a field
      // with existing text moves its cursor/selection without the user
      // typing anything. onChanged must only fire for an actual text edit.
      var callCount = 0;
      await tester.pumpWidget(
        _wrap(
          D3TextField(
            label: 'Name',
            controller: TextEditingController(text: 'Dan'),
            onChanged: (_) => callCount++,
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pump();

      expect(callCount, 0);
    });

    testWidgets('does not show clear button when read-only', (tester) async {
      await tester.pumpWidget(
        _wrap(
          D3TextField(
            label: 'Name',
            controller: TextEditingController(text: 'Dan'),
            isReadOnly: true,
          ),
        ),
      );
      await tester.tap(find.byType(TextField));
      await tester.pump();
      expect(find.byIcon(Icons.close_rounded), findsNothing);
    });

    testWidgets('runs validator on blur and shows error text', (tester) async {
      final focusNode = FocusNode();
      await tester.pumpWidget(
        _wrap(
          D3TextField(
            label: 'Email',
            focusNode: focusNode,
            validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
          ),
        ),
      );

      focusNode.requestFocus();
      await tester.pump();
      focusNode.unfocus();
      await tester.pump();

      expect(find.text('Required'), findsOneWidget);
    });

    testWidgets('validate() can be called imperatively via GlobalKey', (
      tester,
    ) async {
      final key = GlobalKey<D3TextFieldState>();
      await tester.pumpWidget(
        _wrap(
          D3TextField(
            key: key,
            label: 'Email',
            validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
          ),
        ),
      );

      final error = key.currentState!.validate();
      expect(error, 'Required');
      await tester.pump();
      expect(find.text('Required'), findsOneWidget);
    });

    testWidgets('disposes an owned controller but not an external one', (
      tester,
    ) async {
      final externalController = TextEditingController();
      await tester.pumpWidget(_wrap(const D3TextField(label: 'Owned')));
      // Remove the owned-controller field — should not throw.
      await tester.pumpWidget(_wrap(const SizedBox()));

      await tester.pumpWidget(
        _wrap(D3TextField(label: 'External', controller: externalController)),
      );
      await tester.pumpWidget(_wrap(const SizedBox()));

      // External controller must still be usable — it wasn't disposed by the field.
      expect(() => externalController.text, returnsNormally);
      externalController.dispose();
    });
  });
}
