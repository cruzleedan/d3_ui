import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

class ChipVariantsExample extends StatelessWidget {
  const ChipVariantsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        const D3Chip(label: 'Outlined', variant: D3ChipVariant.outlined),
        const D3Chip(label: 'Tonal', variant: D3ChipVariant.tonal),
        const D3Chip(label: 'Filled', variant: D3ChipVariant.filled),
        D3Chip(
          label: 'With icon',
          variant: D3ChipVariant.tonal,
          leadingIcon: Icons.star_outline_rounded,
          onTap: () {},
        ),
        D3Chip(
          label: 'Dismissible',
          trailingIcon: Icons.close_rounded,
          onTap: () {},
        ),
        const D3Chip(label: 'Disabled', enabled: false),
      ],
    );
  }
}
