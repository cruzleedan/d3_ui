import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// A sort-order sheet with a title, a message and the current choice checked.
class ActionSheetSelectionExample extends StatefulWidget {
  const ActionSheetSelectionExample({super.key});

  @override
  State<ActionSheetSelectionExample> createState() =>
      _ActionSheetSelectionExampleState();
}

class _ActionSheetSelectionExampleState
    extends State<ActionSheetSelectionExample> {
  String _sort = 'Newest first';

  Future<void> _open() async {
    final result = await D3ActionSheet.show<String>(
      context,
      title: 'Sort by',
      message: 'Choose how to order the list.',
      actions: [
        for (final option in const [
          'Newest first',
          'Oldest first',
          'Name (A to Z)',
        ])
          D3ActionSheetAction(
            label: option,
            isSelected: option == _sort,
            onPressedWithContext: (ctx) => D3ActionSheet.pop(ctx, option),
          ),
      ],
    );
    if (result != null) setState(() => _sort = result);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        D3Button(
          label: 'Sort by',
          variant: D3ButtonVariant.outlined,
          leadingIcon: Icons.sort_rounded,
          onPressed: _open,
        ),
        const SizedBox(width: 12),
        Flexible(child: Text('Sorted: $_sort')),
      ],
    );
  }
}
