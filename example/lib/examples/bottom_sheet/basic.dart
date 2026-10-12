import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// A picker sheet that returns the chosen value when it closes.
class BottomSheetBasicExample extends StatefulWidget {
  const BottomSheetBasicExample({super.key});

  @override
  State<BottomSheetBasicExample> createState() =>
      _BottomSheetBasicExampleState();
}

class _BottomSheetBasicExampleState extends State<BottomSheetBasicExample> {
  String _sort = 'Newest';

  Future<void> _open() async {
    final result = await D3BottomSheet.show<String>(
      context,
      title: 'Sort by',
      subtitle: 'Choose how to order the list',
      snapPoints: const [D3SnapPoint(0.4)],
      child: Builder(
        builder: (sheetContext) => Column(
          children: [
            for (final option in const ['Newest', 'Oldest', 'Name'])
              ListTile(
                title: Text(option),
                trailing: option == _sort ? const Icon(Icons.check) : null,
                onTap: () => D3BottomSheet.pop(sheetContext, option),
              ),
          ],
        ),
      ),
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
        Text('Selected: $_sort'),
      ],
    );
  }
}
