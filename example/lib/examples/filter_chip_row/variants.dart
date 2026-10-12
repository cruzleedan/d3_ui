import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// A scrolling row of filter chips, single select and multi select.
class FilterChipRowVariantsExample extends StatefulWidget {
  const FilterChipRowVariantsExample({super.key});

  @override
  State<FilterChipRowVariantsExample> createState() =>
      _FilterChipRowVariantsExampleState();
}

class _FilterChipRowVariantsExampleState
    extends State<FilterChipRowVariantsExample> {
  Set<String> _single = {'all'};
  Set<String> _multi = {'vegan'};

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        D3FilterChipRow<String>(
          padding: EdgeInsets.zero,
          options: const [
            D3FilterOption(value: 'all', label: 'All'),
            D3FilterOption(value: 'open', label: 'Open now'),
            D3FilterOption(value: 'nearby', label: 'Nearby'),
            D3FilterOption(value: 'top', label: 'Top rated'),
          ],
          selected: _single,
          onChanged: (v) => setState(() => _single = v),
        ),
        const SizedBox(height: 16),
        D3FilterChipRow<String>(
          padding: EdgeInsets.zero,
          multiSelect: true,
          options: const [
            D3FilterOption(
              value: 'vegan',
              label: 'Vegan',
              icon: Icons.eco_outlined,
            ),
            D3FilterOption(
              value: 'halal',
              label: 'Halal',
              icon: Icons.restaurant_outlined,
            ),
            D3FilterOption(
              value: 'gluten',
              label: 'Gluten free',
              icon: Icons.grain,
            ),
            D3FilterOption(
              value: 'cheap',
              label: 'Budget',
              icon: Icons.savings_outlined,
            ),
          ],
          selected: _multi,
          onChanged: (v) => setState(() => _multi = v),
        ),
      ],
    );
  }
}
