import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// A select-all checkbox that shows the indeterminate state for a partial choice.
class CheckboxSelectAllExample extends StatefulWidget {
  const CheckboxSelectAllExample({super.key});

  @override
  State<CheckboxSelectAllExample> createState() =>
      _CheckboxSelectAllExampleState();
}

class _CheckboxSelectAllExampleState extends State<CheckboxSelectAllExample> {
  final Map<String, bool> _items = {
    'Email': true,
    'Push': false,
    'SMS': false,
  };

  bool? get _all {
    final count = _items.values.where((v) => v).length;
    if (count == 0) return false;
    if (count == _items.length) return true;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        D3Checkbox(
          value: _all,
          label: 'All notifications',
          onChanged: (_) => setState(() {
            final next = _all != true;
            for (final key in _items.keys) {
              _items[key] = next;
            }
          }),
        ),
        for (final entry in _items.entries)
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: D3Checkbox(
              value: entry.value,
              label: entry.key,
              onChanged: (v) => setState(() => _items[entry.key] = v),
            ),
          ),
      ],
    );
  }
}
