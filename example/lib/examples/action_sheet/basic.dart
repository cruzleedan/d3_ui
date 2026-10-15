import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// A Share / Edit / Duplicate / Delete sheet that shows the chosen action.
class ActionSheetBasicExample extends StatefulWidget {
  const ActionSheetBasicExample({super.key});

  @override
  State<ActionSheetBasicExample> createState() =>
      _ActionSheetBasicExampleState();
}

class _ActionSheetBasicExampleState extends State<ActionSheetBasicExample> {
  String? _chosen;

  Future<void> _open() async {
    final result = await D3ActionSheet.show<String>(
      context,
      actions: [
        for (final item in const [
          ('Share', Icons.ios_share_rounded),
          ('Edit', Icons.edit_outlined),
          ('Duplicate', Icons.copy_rounded),
        ])
          D3ActionSheetAction(
            label: item.$1,
            icon: item.$2,
            onPressedWithContext: (ctx) => D3ActionSheet.pop(ctx, item.$1),
          ),
        D3ActionSheetAction(
          label: 'Delete',
          icon: Icons.delete_outline_rounded,
          isDestructive: true,
          onPressedWithContext: (ctx) => D3ActionSheet.pop(ctx, 'Delete'),
        ),
      ],
    );
    setState(() => _chosen = result);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        D3Button(
          label: 'Show actions',
          variant: D3ButtonVariant.outlined,
          onPressed: _open,
        ),
        const SizedBox(height: 12),
        Text('Chosen: ${_chosen ?? 'none'}'),
      ],
    );
  }
}
