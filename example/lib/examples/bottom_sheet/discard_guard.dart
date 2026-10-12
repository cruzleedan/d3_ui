import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// A sheet that asks before closing, so unsaved work is not lost by accident.
class BottomSheetDiscardGuardExample extends StatelessWidget {
  const BottomSheetDiscardGuardExample({super.key});

  Future<bool> _confirmDiscard(BuildContext context) async {
    final discard = await D3Dialog.show<bool>(
      context,
      title: 'Discard changes?',
      message: 'Your edits will be lost.',
      actions: [
        D3DialogAction(
          label: 'Keep editing',
          onPressedWithContext: (ctx) => D3Dialog.pop(ctx, false),
        ),
        D3DialogAction(
          label: 'Discard',
          isDestructive: true,
          onPressedWithContext: (ctx) => D3Dialog.pop(ctx, true),
        ),
      ],
    );
    return discard ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return D3Button(
      label: 'Open sheet with guard',
      variant: D3ButtonVariant.outlined,
      onPressed: () => D3BottomSheet.show<void>(
        context,
        title: 'Edit notes',
        onConfirmDiscard: () => _confirmDiscard(context),
        child: Builder(
          builder: (sheetContext) => Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Tap the close button or the dimmed area to see the prompt.',
                ),
                const SizedBox(height: 16),
                D3Button(
                  label: 'Save',
                  onPressed: () => D3BottomSheet.pop(sheetContext),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
