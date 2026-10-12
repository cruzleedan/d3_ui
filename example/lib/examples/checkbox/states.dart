import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// Checkbox states: unchecked, checked, indeterminate and disabled.
class CheckboxStatesExample extends StatefulWidget {
  const CheckboxStatesExample({super.key});

  @override
  State<CheckboxStatesExample> createState() => _CheckboxStatesExampleState();
}

class _CheckboxStatesExampleState extends State<CheckboxStatesExample> {
  bool _newsletter = false;
  bool _terms = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        D3Checkbox(
          value: _newsletter,
          label: 'Send me the newsletter',
          onChanged: (v) => setState(() => _newsletter = v),
        ),
        D3Checkbox(
          value: _terms,
          label: 'I accept the terms',
          onChanged: (v) => setState(() => _terms = v),
        ),
        const D3Checkbox(
          value: null,
          label: 'Indeterminate',
          onChanged: null,
        ),
        const D3Checkbox(
          value: false,
          label: 'Disabled, unchecked',
          onChanged: null,
        ),
        const D3Checkbox(
          value: true,
          label: 'Disabled, checked',
          onChanged: null,
        ),
      ],
    );
  }
}
