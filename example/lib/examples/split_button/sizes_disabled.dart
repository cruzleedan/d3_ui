import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// Sizes, and the disabled state.
class SplitButtonSizesExample extends StatelessWidget {
  const SplitButtonSizesExample({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      D3SplitButtonItem(label: 'Export as PDF', onPressed: () {}),
      D3SplitButtonItem(label: 'Export as CSV', onPressed: () {}),
    ];
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        D3SplitButton(
            label: 'Small',
            size: D3ButtonSize.sm,
            onPressed: () {},
            items: items),
        D3SplitButton(label: 'Medium', onPressed: () {}, items: items),
        D3SplitButton(
            label: 'Large',
            size: D3ButtonSize.lg,
            onPressed: () {},
            items: items),
        D3SplitButton(
            label: 'Disabled', enabled: false, onPressed: () {}, items: items),
      ],
    );
  }
}
