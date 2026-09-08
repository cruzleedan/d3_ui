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
  group('D3DropdownField (popup mode)', () {
    testWidgets('renders label and hint text when no value is selected', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          D3DropdownField<String, String>(
            label: 'Country',
            items: const ['USA', 'Canada'],
            itemLabel: (v) => v,
            itemValue: (v) => v,
            hintText: 'Select a country',
          ),
        ),
      );
      expect(find.text('Country'), findsOneWidget);
      expect(find.text('Select a country'), findsOneWidget);
    });

    testWidgets('renders the item matching initialValue as selected', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          D3DropdownField<String, String>(
            label: 'Country',
            items: const ['USA', 'Canada'],
            itemLabel: (v) => v,
            itemValue: (v) => v,
            initialValue: 'Canada',
          ),
        ),
      );
      expect(find.text('Canada'), findsOneWidget);
    });

    testWidgets('opens a popup menu on tap and calls onChanged on selection', (
      tester,
    ) async {
      String? selected;
      await tester.pumpWidget(
        _wrap(
          D3DropdownField<String, String>(
            label: 'Country',
            items: const ['USA', 'Canada'],
            itemLabel: (v) => v,
            itemValue: (v) => v,
            onChanged: (v) => selected = v,
          ),
        ),
      );

      await tester.tap(find.byType(D3DropdownField<String, String>));
      await tester.pumpAndSettle();

      expect(find.byType(PopupMenuItem<String>), findsNWidgets(2));

      await tester.tap(find.text('Canada').last);
      await tester.pumpAndSettle();

      expect(selected, 'Canada');
      expect(find.text('Canada'), findsOneWidget);
    });

    testWidgets('shows helperText when set and no error', (tester) async {
      await tester.pumpWidget(
        _wrap(
          D3DropdownField<String, String>(
            label: 'Country',
            items: const ['USA'],
            itemLabel: (v) => v,
            itemValue: (v) => v,
            helperText: 'Pick one',
          ),
        ),
      );
      expect(find.text('Pick one'), findsOneWidget);
    });

    testWidgets('shows errorText in place of helperText', (tester) async {
      await tester.pumpWidget(
        _wrap(
          D3DropdownField<String, String>(
            label: 'Country',
            items: const ['USA'],
            itemLabel: (v) => v,
            itemValue: (v) => v,
            helperText: 'Pick one',
            errorText: 'Required',
          ),
        ),
      );
      expect(find.text('Required'), findsOneWidget);
      expect(find.text('Pick one'), findsNothing);
    });

    testWidgets('shows required asterisk when isRequired is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          D3DropdownField<String, String>(
            label: 'Country',
            items: const ['USA'],
            itemLabel: (v) => v,
            itemValue: (v) => v,
            isRequired: true,
          ),
        ),
      );
      expect(find.text('*'), findsOneWidget);
    });

    testWidgets('shows prefixIcon when provided', (tester) async {
      await tester.pumpWidget(
        _wrap(
          D3DropdownField<String, String>(
            label: 'Country',
            items: const ['USA'],
            itemLabel: (v) => v,
            itemValue: (v) => v,
            prefixIcon: Icons.flag_outlined,
          ),
        ),
      );
      expect(find.byIcon(Icons.flag_outlined), findsOneWidget);
    });

    testWidgets('disabled field does not open the popup on tap', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          D3DropdownField<String, String>(
            label: 'Country',
            items: const ['USA'],
            itemLabel: (v) => v,
            itemValue: (v) => v,
            isEnabled: false,
          ),
        ),
      );

      await tester.tap(find.byType(D3DropdownField<String, String>));
      await tester.pumpAndSettle();

      expect(find.byType(PopupMenuItem<String>), findsNothing);
    });
  });
}
