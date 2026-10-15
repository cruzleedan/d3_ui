import 'package:material_ui/material_ui.dart';

import '../../examples/time_field/picker_sheet.dart';
import '../../examples/time_field/variants.dart';
import '../example_card.dart';
import 'page_helpers.dart';

class TimeFieldPage extends StatelessWidget {
  const TimeFieldPage({super.key});

  @override
  Widget build(BuildContext context) => ExamplePage(
        title: 'D3TimeField',
        summary:
            'A field that opens a wheel time picker sheet when tapped. Use it when the user must choose a time of day.',
        examples: [
          exampleCard('Variants', 'time_field/variants.dart',
              const TimeFieldVariantsExample(),
              description:
                  'Supports 12 and 24-hour display and a minute interval.'),
          exampleCard('Picker sheet', 'time_field/picker_sheet.dart',
              const TimePickerSheetExample(),
              description:
                  'Call showD3TimePicker directly; it returns null when dismissed.'),
        ],
      );
}
