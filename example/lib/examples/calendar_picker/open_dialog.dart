import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// Opens showD3CalendarPicker from a button and shows the chosen date.
class CalendarPickerExample extends StatefulWidget {
  const CalendarPickerExample({super.key});

  @override
  State<CalendarPickerExample> createState() => _CalendarPickerExampleState();
}

class _CalendarPickerExampleState extends State<CalendarPickerExample> {
  DateTime? _picked;

  Future<void> _open({Set<DateTime>? markedDates, DateTime? firstDate}) async {
    final date = await showD3CalendarPicker(
      context: context,
      initialDate: _picked,
      firstDate: firstDate,
      markedDates: markedDates,
    );
    if (date != null) setState(() => _picked = date);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = _picked;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            D3Button(
              label: 'Pick a date',
              leadingIcon: Icons.calendar_today_rounded,
              onPressed: _open,
            ),
            D3Button(
              label: 'Marked days, future only',
              variant: D3ButtonVariant.outlined,
              onPressed: () => _open(
                firstDate: today,
                markedDates: {
                  today.add(const Duration(days: 2)),
                  today.add(const Duration(days: 9)),
                  today.add(const Duration(days: 16)),
                },
              ),
            ),
          ],
        ),
        Text(
          picked == null
              ? 'No date picked yet'
              : 'Picked ${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}',
        ),
      ],
    );
  }
}
