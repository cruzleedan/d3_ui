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
            validationMode: D3ValidationMode.onBlur,
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

    testWidgets('onBlurThenChange does not validate an untouched field', (
      tester,
    ) async {
      final focusNode = FocusNode();
      await tester.pumpWidget(
        _wrap(
          D3TextField(
            label: 'Password',
            focusNode: focusNode,
            validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
          ),
        ),
      );

      focusNode.requestFocus();
      await tester.pump();
      focusNode.unfocus();
      await tester.pump();

      expect(find.text('Required'), findsNothing);
    });

    testWidgets('controller updates do not count as user edits', (
      tester,
    ) async {
      final focusNode = FocusNode();
      final controller = TextEditingController();
      var validatorCalls = 0;
      await tester.pumpWidget(
        _wrap(
          D3TextField(
            label: 'Email',
            focusNode: focusNode,
            controller: controller,
            validator: (v) {
              validatorCalls++;
              return (v == null || !v.contains('@')) ? 'Invalid' : null;
            },
          ),
        ),
      );

      controller.text = 'programmatic value';
      focusNode.requestFocus();
      await tester.pump();
      focusNode.unfocus();
      await tester.pump();

      expect(validatorCalls, 0);
      expect(find.text('Invalid'), findsNothing);
      controller.dispose();
    });

    testWidgets('onBlurThenChange validates edited fields and clears live', (
      tester,
    ) async {
      final focusNode = FocusNode();
      await tester.pumpWidget(
        _wrap(
          D3TextField(
            label: 'Email',
            focusNode: focusNode,
            validator: (v) => (v == null || !v.contains('@'))
                ? 'Enter a valid email'
                : null,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'invalid');
      await tester.pump();
      focusNode.unfocus();
      await tester.pump();
      expect(find.text('Enter a valid email'), findsOneWidget);

      focusNode.requestFocus();
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'valid@example.com');
      await tester.pump();
      expect(find.text('Enter a valid email'), findsNothing);
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

  // WORK-0088: a parent that loads data after the first build passes it as
  // a new initialValue.
  group('D3TextField initialValue updates', () {
    Widget field(String? value, {ValueChanged<String>? onChanged}) => _wrap(
      D3TextField(
        label: 'Description',
        initialValue: value,
        onChanged: onChanged,
      ),
    );

    testWidgets('shows a new initialValue when the field is not focused', (
      tester,
    ) async {
      final changes = <String>[];
      await tester.pumpWidget(field('', onChanged: changes.add));
      expect(find.text('Bluebird Cafe lunch'), findsNothing);

      await tester.pumpWidget(
        field('Bluebird Cafe lunch', onChanged: changes.add),
      );
      await tester.pump();

      expect(find.text('Bluebird Cafe lunch'), findsOneWidget);
      // The caller's own value is not an edit, so it isn't echoed back.
      expect(changes, isEmpty);
    });

    testWidgets('keeps what the user typed while the field has focus', (
      tester,
    ) async {
      await tester.pumpWidget(field('Draft'));
      await tester.enterText(find.byType(TextField), 'Typed by user');
      await tester.pump();

      await tester.pumpWidget(field('Reloaded from server'));
      await tester.pump();

      expect(find.text('Typed by user'), findsOneWidget);
      expect(find.text('Reloaded from server'), findsNothing);
    });

    testWidgets('a theme change does not reset typed text', (tester) async {
      Widget themed(Brightness b) => MaterialApp(
        theme: b == Brightness.light ? D3AppTheme.light() : D3AppTheme.dark(),
        home: const Scaffold(
          body: Center(
            child: D3TextField(label: 'Description', initialValue: 'Draft'),
          ),
        ),
      );
      await tester.pumpWidget(themed(Brightness.light));
      await tester.enterText(find.byType(TextField), 'Typed by user');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump();

      await tester.pumpWidget(themed(Brightness.dark));
      await tester.pumpAndSettle();

      expect(find.text('Typed by user'), findsOneWidget);
    });
  });
}
