import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// Empty, filled, 24-hour, 15-minute interval, error and disabled time fields.
class TimeFieldVariantsExample extends StatelessWidget {
  const TimeFieldVariantsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16,
      children: [
        const D3TimeField(label: 'Start time', hintText: 'Pick a time'),
        const D3TimeField(
          label: 'Reminder',
          initialValue: TimeOfDay(hour: 9, minute: 30),
          helperText: 'We will notify you then.',
        ),
        const D3TimeField(
          label: 'Departure (24-hour)',
          initialValue: TimeOfDay(hour: 17, minute: 5),
          use24h: true,
        ),
        const D3TimeField(
          label: 'Appointment',
          hintText: 'Every 15 minutes',
          minuteInterval: 15,
        ),
        const D3TimeField(
          label: 'End time',
          isRequired: true,
          errorText: 'End time is required',
        ),
        const D3TimeField(
          label: 'Locked',
          initialValue: TimeOfDay(hour: 12, minute: 0),
          isEnabled: false,
        ),
      ],
    );
  }
}
