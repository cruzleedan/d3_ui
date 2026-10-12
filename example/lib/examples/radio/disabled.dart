import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// Disabled radios, selected and not selected.
class RadioDisabledExample extends StatelessWidget {
  const RadioDisabledExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        D3Radio<int>(
          value: 1,
          groupValue: 1,
          label: 'Disabled, selected',
          onChanged: null,
        ),
        D3Radio<int>(
          value: 2,
          groupValue: 1,
          label: 'Disabled, not selected',
          onChanged: null,
        ),
      ],
    );
  }
}
