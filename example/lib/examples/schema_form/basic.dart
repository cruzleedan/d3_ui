import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// A form described by data: one FormSchema renders every field and validates on save.
class SchemaFormExample extends StatefulWidget {
  const SchemaFormExample({super.key});

  @override
  State<SchemaFormExample> createState() => _SchemaFormExampleState();
}

class _SchemaFormExampleState extends State<SchemaFormExample> {
  static const _schema = FormSchema(
    screenId: 'new-expense',
    version: 1,
    fields: [
      FieldSchema(
        key: 'title',
        type: FieldType.text,
        label: 'Title',
        required: true,
        validation: FieldValidation(maxLength: 40),
      ),
      FieldSchema(
        key: 'amount',
        type: FieldType.decimal,
        label: 'Amount',
        required: true,
        validation: FieldValidation(minValue: 0.01, maxValue: 10000),
      ),
      FieldSchema(key: 'date', type: FieldType.date, label: 'Date'),
      FieldSchema(
        key: 'category',
        type: FieldType.dropdown,
        label: 'Category',
        options: [
          FieldOption(value: 'food', label: 'Food'),
          FieldOption(value: 'travel', label: 'Travel'),
          FieldOption(value: 'home', label: 'Home'),
        ],
      ),
      FieldSchema(
        key: 'kind',
        type: FieldType.segmentedButton,
        label: 'Type',
        options: [
          FieldOption(value: 'expense', label: 'Expense'),
          FieldOption(value: 'income', label: 'Income'),
        ],
      ),
      FieldSchema(key: 'recurring', type: FieldType.toggle, label: 'Recurring'),
    ],
  );

  final Map<String, Object?> _values = {'kind': 'expense'};
  Map<String, String> _errors = {};
  bool _saved = false;

  void _save() {
    final errors = <String, String>{};
    for (final field in _schema.fields) {
      final message = validateFieldValue(field, _values[field.key]);
      if (message != null) errors[field.key] = message;
    }
    setState(() {
      _errors = errors;
      _saved = errors.isEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 520,
          child: SchemaForm(
            schema: _schema,
            values: _values,
            errors: _errors,
            onFieldChanged: (key, value) => setState(() {
              _values[key] = value;
              _errors = {..._errors}..remove(key);
              _saved = false;
            }),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          spacing: 12,
          children: [
            D3Button(label: 'Save', onPressed: _save),
            if (_saved) const Text('Saved'),
          ],
        ),
      ],
    );
  }
}
