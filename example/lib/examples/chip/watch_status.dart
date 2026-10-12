import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// D3StatusChip: tap the last chip to cycle through the statuses.
class ChipWatchStatusExample extends StatefulWidget {
  const ChipWatchStatusExample({super.key});

  @override
  State<ChipWatchStatusExample> createState() => _ChipWatchStatusExampleState();
}

class _ChipWatchStatusExampleState extends State<ChipWatchStatusExample> {
  D3WatchStatus _status = D3WatchStatus.watching;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final s in D3WatchStatus.values) D3StatusChip(status: s),
          ],
        ),
        const SizedBox(height: 14),
        D3StatusChip(
          status: _status,
          onTap: () => setState(() {
            final next = (_status.index + 1) % D3WatchStatus.values.length;
            _status = D3WatchStatus.values[next];
          }),
        ),
      ],
    );
  }
}
