import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// A button that opens the time picker sheet and shows the chosen time.
class TimePickerSheetExample extends StatefulWidget {
  const TimePickerSheetExample({super.key});

  @override
  State<TimePickerSheetExample> createState() => _TimePickerSheetExampleState();
}

class _TimePickerSheetExampleState extends State<TimePickerSheetExample> {
  TimeOfDay? _time;

  Future<void> _open() async {
    final picked = await showD3TimePicker(
      context,
      initialTime: _time ?? const TimeOfDay(hour: 9, minute: 30),
      minuteInterval: 5,
    );
    if (picked != null) setState(() => _time = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 12,
      children: [
        FilledButton(onPressed: _open, child: const Text('Pick a time')),
        Text(
          _time == null ? 'No time chosen' : 'Chosen: ${d3FormatTime(_time!)}',
        ),
      ],
    );
  }
}
