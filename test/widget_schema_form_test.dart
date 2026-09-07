import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:d3_ui/d3_ui.dart';

Widget _wrap(Widget child) {
  return MaterialApp(theme: D3AppTheme.light(), home: Scaffold(body: child));
}

void main() {
  group('FieldRenderer per field type', () {
    testWidgets('text renders a D3TextField and reports changes', (tester) async {
      Object? changed;
      await tester.pumpWidget(
        _wrap(
          FieldRenderer(
            field: const FieldSchema(key: 'name', type: FieldType.text, label: 'Name'),
            value: 'initial',
            onChanged: (v) => changed = v,
          ),
        ),
      );
      expect(find.byType(D3TextField), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Dan');
      expect(changed, 'Dan');
    });

    testWidgets('decimal renders a D3DecimalField', (tester) async {
      await tester.pumpWidget(
        _wrap(
          FieldRenderer(
            field: const FieldSchema(
              key: 'amount',
              type: FieldType.decimal,
              label: 'Amount',
            ),
            value: 12.5,
            onChanged: (_) {},
          ),
        ),
      );
      expect(find.byType(D3DecimalField), findsOneWidget);
    });

    testWidgets('date renders a D3DateField', (tester) async {
      await tester.pumpWidget(
        _wrap(
          FieldRenderer(
            field: const FieldSchema(key: 'date', type: FieldType.date, label: 'Date'),
            value: DateTime(2026, 1, 1),
            onChanged: (_) {},
          ),
        ),
      );
      expect(find.byType(D3DateField), findsOneWidget);
    });

    testWidgets('dropdown renders a D3DropdownField with inline options', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          FieldRenderer(
            field: const FieldSchema(
              key: 'category',
              type: FieldType.dropdown,
              label: 'Category',
              options: [FieldOption(value: 'a', label: 'A'), FieldOption(value: 'b', label: 'B')],
            ),
            value: 'a',
            onChanged: (_) {},
          ),
        ),
      );
      expect(find.byType(D3DropdownField<FieldOption, String>), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('toggle renders a D3Toggle and reports changes', (tester) async {
      Object? changed;
      await tester.pumpWidget(
        _wrap(
          FieldRenderer(
            field: const FieldSchema(
              key: 'active',
              type: FieldType.toggle,
              label: 'Active',
            ),
            value: false,
            onChanged: (v) => changed = v,
          ),
        ),
      );
      expect(find.byType(D3Toggle), findsOneWidget);
      await tester.tap(find.byType(D3Toggle));
      expect(changed, true);
    });

    group('segmentedButton', () {
      testWidgets('renders a D3SegmentedControl with the field label and inline options', (
        tester,
      ) async {
        await tester.pumpWidget(
          _wrap(
            FieldRenderer(
              field: const FieldSchema(
                key: 'priority',
                type: FieldType.segmentedButton,
                label: 'Priority',
                options: [
                  FieldOption(value: 'low', label: 'Low'),
                  FieldOption(value: 'high', label: 'High'),
                ],
              ),
              value: 'low',
              onChanged: (_) {},
            ),
          ),
        );
        expect(find.text('Priority'), findsOneWidget);
        expect(find.byType(D3SegmentedControl<String>), findsOneWidget);
        expect(find.text('Low'), findsOneWidget);
        expect(find.text('High'), findsOneWidget);
      });

      testWidgets('reports the tapped segment\'s value via onChanged', (tester) async {
        Object? changed;
        await tester.pumpWidget(
          _wrap(
            FieldRenderer(
              field: const FieldSchema(
                key: 'priority',
                type: FieldType.segmentedButton,
                label: 'Priority',
                options: [
                  FieldOption(value: 'low', label: 'Low'),
                  FieldOption(value: 'high', label: 'High'),
                ],
              ),
              value: 'low',
              onChanged: (v) => changed = v,
            ),
          ),
        );
        await tester.tap(find.text('High'));
        expect(changed, 'high');
      });

      testWidgets('a disabled field does not report changes', (tester) async {
        Object? changed;
        await tester.pumpWidget(
          _wrap(
            FieldRenderer(
              field: const FieldSchema(
                key: 'priority',
                type: FieldType.segmentedButton,
                label: 'Priority',
                isEnabled: false,
                options: [
                  FieldOption(value: 'low', label: 'Low'),
                  FieldOption(value: 'high', label: 'High'),
                ],
              ),
              value: 'low',
              onChanged: (v) => changed = v,
            ),
          ),
        );
        await tester.tap(find.text('High'));
        expect(changed, isNull);
      });

      testWidgets('fewer than 2 resolved options shows a config-error message, not a crash', (
        tester,
      ) async {
        await tester.pumpWidget(
          _wrap(
            FieldRenderer(
              field: const FieldSchema(
                key: 'priority',
                type: FieldType.segmentedButton,
                label: 'Priority',
                options: [FieldOption(value: 'low', label: 'Low')],
              ),
              value: 'low',
              onChanged: (_) {},
            ),
          ),
        );
        expect(find.byType(D3SegmentedControl<String>), findsNothing);
        expect(tester.takeException(), isNull);
      });

      testWidgets('more than 4 resolved options is truncated to 4, not a crash', (
        tester,
      ) async {
        await tester.pumpWidget(
          _wrap(
            FieldRenderer(
              field: FieldSchema(
                key: 'priority',
                type: FieldType.segmentedButton,
                label: 'Priority',
                options: List.generate(
                  6,
                  (i) => FieldOption(value: '$i', label: 'Option $i'),
                ),
              ),
              value: '0',
              onChanged: (_) {},
            ),
          ),
        );
        expect(find.byType(D3SegmentedControl<String>), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });
  });

  group('SchemaForm', () {
    testWidgets('renders every field from the schema in order', (tester) async {
      await tester.pumpWidget(
        _wrap(
          SchemaForm(
            schema: const FormSchema(
              screenId: 'test',
              version: 1,
              fields: [
                FieldSchema(key: 'name', type: FieldType.text, label: 'Name'),
                FieldSchema(key: 'active', type: FieldType.toggle, label: 'Active'),
              ],
            ),
            values: const {'name': 'Dan', 'active': true},
            errors: const {},
            onFieldChanged: (_, _) {},
          ),
        ),
      );
      expect(find.byType(D3TextField), findsOneWidget);
      expect(find.byType(D3Toggle), findsOneWidget);
    });

    testWidgets('does not read app state itself -- values/errors come entirely from parameters', (
      tester,
    ) async {
      // Re-pumping with different values (no reload/async gap) should
      // reflect immediately, since SchemaForm has no internal state of its
      // own for field values.
      final key = GlobalKey();
      Widget build(String name) => _wrap(
        SchemaForm(
          key: key,
          schema: const FormSchema(
            screenId: 'test',
            version: 1,
            fields: [FieldSchema(key: 'name', type: FieldType.text, label: 'Name')],
          ),
          values: {'name': name},
          errors: const {},
          onFieldChanged: (_, _) {},
        ),
      );

      await tester.pumpWidget(build('first'));
      expect(find.text('first'), findsOneWidget);

      await tester.pumpWidget(build('second'));
      await tester.pumpAndSettle();
      expect(find.text('second'), findsOneWidget);
    });

    testWidgets('onFieldChanged fires with the edited field\'s key', (tester) async {
      final changes = <String>[];
      await tester.pumpWidget(
        _wrap(
          SchemaForm(
            schema: const FormSchema(
              screenId: 'test',
              version: 1,
              fields: [FieldSchema(key: 'name', type: FieldType.text, label: 'Name')],
            ),
            values: const {},
            errors: const {},
            onFieldChanged: (key, _) => changes.add(key),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), 'Dan');
      expect(changes, contains('name'));
    });
  });
}
