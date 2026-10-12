import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// A date field that opens the themed calendar, with marked days and a range limit.
class DateFieldCalendarExample extends StatelessWidget {
  const DateFieldCalendarExample({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Column(
      spacing: 16,
      children: [
        D3DateField(
          label: 'Appointment',
          useD3CalendarPicker: true,
          firstDate: DateTime(now.year, now.month, now.day),
          lastDate: DateTime(now.year + 1),
          markedDates: {
            DateTime(now.year, now.month, now.day + 3),
            DateTime(now.year, now.month, now.day + 10),
          },
          helperText: 'Dots mark days that already have bookings.',
          onChanged: (_) {},
        ),
        D3DateField(
          label: 'Report date',
          useD3CalendarPicker: true,
          displayFormat: (d) => '${d.day}/${d.month}/${d.year}',
          onChanged: (_) {},
        ),
      ],
    );
  }
}
