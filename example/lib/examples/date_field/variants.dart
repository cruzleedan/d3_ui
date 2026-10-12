import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// Empty, filled, helper text, error and disabled date fields.
class DateFieldVariantsExample extends StatelessWidget {
  const DateFieldVariantsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16,
      children: [
        D3DateField(
            label: 'Start date', hintText: 'Pick a date', onChanged: (_) {}),
        D3DateField(
          label: 'Birthday',
          initialValue: DateTime(1990, 6, 15),
          helperText: 'Shown on your profile.',
          onChanged: (_) {},
        ),
        D3DateField(
          label: 'Due date',
          isRequired: true,
          errorText: 'Due date is required',
          onChanged: (_) {},
        ),
        D3DateField(
          label: 'Created',
          initialValue: DateTime(2024, 3, 2),
          isEnabled: false,
        ),
      ],
    );
  }
}
