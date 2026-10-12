import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// A label with an optional count and a trailing action.
class SectionHeaderExample extends StatelessWidget {
  const SectionHeaderExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const D3SectionHeader.label(label: 'Nearby'),
        const D3SectionHeader(label: 'Favourites', count: 12),
        D3SectionHeader(
          label: 'Recently viewed',
          count: 3,
          trailingIcon: Icons.delete_sweep_outlined,
          trailingSemanticsLabel: 'Clear history',
          onTrailingTap: () => D3Toast.info(context, title: 'History cleared'),
        ),
      ],
    );
  }
}
