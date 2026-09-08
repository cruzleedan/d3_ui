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
  group('D3DecimalField', () {
    testWidgets('renders label and hint text when no value is set', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const D3DecimalField(label: 'Amount', hintText: '0.00')),
      );
      expect(find.text('Amount'), findsOneWidget);
      expect(find.text('0.00'), findsOneWidget);
    });

    testWidgets('renders initialValue formatted to decimalPlaces', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const D3DecimalField(label: 'Amount', initialValue: 1234.5),
        ),
      );
      expect(find.text('1234.50'), findsOneWidget);
    });

    testWidgets('null/zero initialValue shows empty (hint visible instead)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const D3DecimalField(
            label: 'Amount',
            initialValue: 0.0,
            hintText: '0.00',
          ),
        ),
      );
      expect(find.text('0.00'), findsOneWidget);
    });

    testWidgets('calls onChanged with parsed double as the user types', (
      tester,
    ) async {
      double? value;
      await tester.pumpWidget(
        _wrap(D3DecimalField(label: 'Amount', onChanged: (v) => value = v)),
      );
      await tester.enterText(find.byType(TextField), '42.5');
      expect(value, 42.5);
    });

    testWidgets('shows helperText when set and no error', (tester) async {
      await tester.pumpWidget(
        _wrap(const D3DecimalField(label: 'Amount', helperText: 'USD')),
      );
      expect(find.text('USD'), findsOneWidget);
    });

    testWidgets('shows errorText in place of helperText', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const D3DecimalField(
            label: 'Amount',
            helperText: 'USD',
            errorText: 'Required',
          ),
        ),
      );
      expect(find.text('Required'), findsOneWidget);
      expect(find.text('USD'), findsNothing);
    });

    testWidgets('shows required asterisk when isRequired is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const D3DecimalField(label: 'Amount', isRequired: true)),
      );
      expect(find.text('*'), findsOneWidget);
    });

    testWidgets('shows prefixIcon and suffixText when provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const D3DecimalField(
            label: 'Amount',
            prefixIcon: Icons.attach_money,
            suffixText: 'USD',
          ),
        ),
      );
      expect(find.byIcon(Icons.attach_money), findsOneWidget);
      expect(find.text('USD'), findsOneWidget);
    });

    testWidgets('disabled field does not accept input', (tester) async {
      await tester.pumpWidget(
        _wrap(const D3DecimalField(label: 'Amount', isEnabled: false)),
      );
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);
    });

    testWidgets('respects maxValue by rejecting input over the limit', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const D3DecimalField(label: 'Amount', maxValue: 100)),
      );
      await tester.enterText(find.byType(TextField), '150');
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, isNot('150'));
    });
  });
}
