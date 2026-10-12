import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// Rows that reveal actions when swiped left. Opening one closes the other.
class SlidableRowExample extends StatefulWidget {
  const SlidableRowExample({super.key});

  @override
  State<SlidableRowExample> createState() => _SlidableRowExampleState();
}

class _SlidableRowExampleState extends State<SlidableRowExample> {
  String _last = 'Swipe a row to the left.';

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        for (final name in ['Site visit, Monday', 'Site visit, Tuesday'])
          D3SlidableRow(
            groupTag: 'slidable-example',
            actions: [
              D3SwipeAction(
                icon: Icons.archive_outlined,
                label: 'Archive',
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                onPressed: () => setState(() => _last = 'Archived: $name'),
              ),
              D3SwipeAction(
                icon: Icons.delete_outline,
                label: 'Delete',
                onPressed: () => setState(() => _last = 'Deleted: $name'),
              ),
            ],
            child: D3ListTile(
              title: name,
              subtitle: '3 photos',
              trailing: const Icon(Icons.chevron_left_rounded),
            ),
          ),
        Text(_last),
      ],
    );
  }
}
