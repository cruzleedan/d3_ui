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
  group('D3DateField', () {
    testWidgets('renders label and hint text when no value is set', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const D3DateField(label: 'Due date', hintText: 'Pick a date')),
      );
      expect(find.text('Due date'), findsOneWidget);
      expect(find.text('Pick a date'), findsOneWidget);
    });

    testWidgets('renders initialValue as ISO date by default', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          D3DateField(label: 'Due date', initialValue: DateTime(2026, 9, 4)),
        ),
      );
      expect(find.text('2026-09-04'), findsOneWidget);
    });

    testWidgets('displayFormat overrides the default ISO rendering', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          D3DateField(
            label: 'Due date',
            initialValue: DateTime(2026, 9, 4),
            displayFormat: (dt) => 'custom-${dt.year}',
          ),
        ),
      );
      expect(find.text('custom-2026'), findsOneWidget);
      expect(find.text('2026-09-04'), findsNothing);
    });

    testWidgets('shows helperText when set and no error', (tester) async {
      await tester.pumpWidget(
        _wrap(const D3DateField(label: 'Due date', helperText: 'Optional')),
      );
      expect(find.text('Optional'), findsOneWidget);
    });

    testWidgets('shows errorText in place of helperText', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const D3DateField(
            label: 'Due date',
            helperText: 'Optional',
            errorText: 'Required',
          ),
        ),
      );
      expect(find.text('Required'), findsOneWidget);
      expect(find.text('Optional'), findsNothing);
    });

    testWidgets('shows required asterisk when isRequired is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const D3DateField(label: 'Due date', isRequired: true)),
      );
      expect(find.text('*'), findsOneWidget);
    });

    testWidgets('opens the stock date picker on tap and calls onChanged', (
      tester,
    ) async {
      DateTime? picked;
      await tester.pumpWidget(
        _wrap(
          D3DateField(
            label: 'Due date',
            initialValue: DateTime(2026, 9, 4),
            onChanged: (dt) => picked = dt,
          ),
        ),
      );

      await tester.tap(find.byType(D3DateField));
      await tester.pumpAndSettle();

      // Stock Material date picker dialog is showing.
      expect(find.byType(DatePickerDialog), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(picked, DateTime(2026, 9, 4));
      expect(find.text('2026-09-04'), findsOneWidget);
    });

    testWidgets('does not open the picker when disabled', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const D3DateField(
            label: 'Due date',
            isEnabled: false,
          ),
        ),
      );

      await tester.tap(find.byType(D3DateField));
      await tester.pumpAndSettle();

      expect(find.byType(DatePickerDialog), findsNothing);
    });

    testWidgets('does not open the picker when read-only', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const D3DateField(
            label: 'Due date',
            isReadOnly: true,
          ),
        ),
      );

      await tester.tap(find.byType(D3DateField));
      await tester.pumpAndSettle();

      expect(find.byType(DatePickerDialog), findsNothing);
    });

    testWidgets('opens showD3CalendarPicker when useD3CalendarPicker is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          D3DateField(
            label: 'Due date',
            initialValue: DateTime(2026, 9, 4),
            useD3CalendarPicker: true,
          ),
        ),
      );

      await tester.tap(find.byType(D3DateField));
      await tester.pumpAndSettle();

      expect(find.byType(DatePickerDialog), findsNothing);
      expect(find.text('September 2026'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    });
  });
}
