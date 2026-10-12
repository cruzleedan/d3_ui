import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// Toggles that are off, on and disabled, with and without a label.
class ToggleStatesExample extends StatefulWidget {
  const ToggleStatesExample({super.key});

  @override
  State<ToggleStatesExample> createState() => _ToggleStatesExampleState();
}

class _ToggleStatesExampleState extends State<ToggleStatesExample> {
  bool _wifi = true;
  bool _bluetooth = false;
  bool _bare = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        D3Toggle(
          value: _wifi,
          label: 'Wi-Fi',
          onChanged: (v) => setState(() => _wifi = v),
        ),
        const SizedBox(height: 12),
        D3Toggle(
          value: _bluetooth,
          label: 'Bluetooth',
          onChanged: (v) => setState(() => _bluetooth = v),
        ),
        const SizedBox(height: 12),
        D3Toggle(
          value: _bare,
          semanticsLabel: 'Airplane mode',
          onChanged: (v) => setState(() => _bare = v),
        ),
        const SizedBox(height: 12),
        const D3Toggle(value: true, label: 'Disabled, on', onChanged: null),
        const SizedBox(height: 12),
        const D3Toggle(value: false, label: 'Disabled, off', onChanged: null),
      ],
    );
  }
}
