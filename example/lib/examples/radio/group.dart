import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// A radio group where one option is selected, plus a disabled option.
class RadioGroupExample extends StatefulWidget {
  const RadioGroupExample({super.key});

  @override
  State<RadioGroupExample> createState() => _RadioGroupExampleState();
}

class _RadioGroupExampleState extends State<RadioGroupExample> {
  String _plan = 'standard';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        D3Radio<String>(
          value: 'free',
          groupValue: _plan,
          label: 'Free',
          onChanged: (v) => setState(() => _plan = v),
        ),
        D3Radio<String>(
          value: 'standard',
          groupValue: _plan,
          label: 'Standard',
          onChanged: (v) => setState(() => _plan = v),
        ),
        D3Radio<String>(
          value: 'pro',
          groupValue: _plan,
          label: 'Pro',
          onChanged: (v) => setState(() => _plan = v),
        ),
        D3Radio<String>(
          value: 'enterprise',
          groupValue: _plan,
          label: 'Enterprise (unavailable)',
          onChanged: null,
        ),
      ],
    );
  }
}
