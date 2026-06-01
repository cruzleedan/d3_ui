import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:d3_ui/d3_ui.dart';

/// Wraps a widget with [D3AppTheme] so tokens are available.
Widget _wrap(Widget child) {
  return MaterialApp(
    theme: D3AppTheme.light(),
    darkTheme: D3AppTheme.dark(),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('D3Button', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(_wrap(
        D3Button(label: 'Hello', onPressed: () {}),
      ));
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        D3Button(label: 'Tap me', onPressed: () => tapped = true),
      ));
      await tester.tap(find.text('Tap me'));
      expect(tapped, isTrue);
    });

    testWidgets('does not call onPressed when null (disabled)', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        D3Button(label: 'Disabled', onPressed: null),
      ));
      await tester.tap(find.text('Disabled'), warnIfMissed: false);
      expect(tapped, isFalse);
    });

    testWidgets('shows loading label when in loading state', (tester) async {
      await tester.pumpWidget(_wrap(
        const D3Button(
          label: 'Save',
          loadingLabel: 'Saving…',
          buttonState: D3ButtonState.loading,
          onPressed: null,
        ),
      ));
      expect(find.text('Saving…'), findsOneWidget);
    });

    testWidgets('falls back to label when loadingLabel is null',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const D3Button(
          label: 'Save',
          buttonState: D3ButtonState.loading,
          onPressed: null,
        ),
      ));
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('icon-only variant renders without label', (tester) async {
      await tester.pumpWidget(_wrap(
        D3Button.icon(icon: Icons.add, onPressed: () {}),
      ));
      // Should render an Icon widget
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('isFullWidth stretches to available width', (tester) async {
      await tester.pumpWidget(_wrap(
        D3Button(
          label: 'Full',
          isFullWidth: true,
          onPressed: () {},
        ),
      ));
      final sizedBox = tester.widget<SizedBox>(
        find
            .ancestor(
              of: find.text('Full'),
              matching: find.byType(SizedBox),
            )
            .first,
      );
      expect(sizedBox.width, double.infinity);
    });

    testWidgets('leading icon is rendered', (tester) async {
      await tester.pumpWidget(_wrap(
        D3Button(
          label: 'Add',
          leadingIcon: Icons.add,
          onPressed: () {},
        ),
      ));
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('all variants render without error', (tester) async {
      for (final variant in D3ButtonVariant.values) {
        await tester.pumpWidget(_wrap(
          D3Button(label: variant.name, variant: variant, onPressed: () {}),
        ));
        expect(find.text(variant.name), findsOneWidget);
      }
    });

    testWidgets('all sizes render without error', (tester) async {
      for (final size in D3ButtonSize.values) {
        await tester.pumpWidget(_wrap(
          D3Button(label: size.name, size: size, onPressed: () {}),
        ));
        expect(find.text(size.name), findsOneWidget);
      }
    });

    testWidgets('semantics label is set', (tester) async {
      await tester.pumpWidget(_wrap(
        D3Button(
          label: 'Submit',
          semanticsLabel: 'Submit form',
          onPressed: () {},
        ),
      ));
      final semantics = tester.getSemantics(find.text('Submit'));
      expect(semantics.label, contains('Submit form'));
    });
  });
}
