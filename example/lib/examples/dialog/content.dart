import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// A dialog with custom content between the message and the actions.
class DialogContentExample extends StatelessWidget {
  const DialogContentExample({super.key});

  @override
  Widget build(BuildContext context) {
    return D3Button(
      label: 'Rename list',
      variant: D3ButtonVariant.outlined,
      onPressed: () {
        final controller = TextEditingController(text: 'Weekend spots');
        D3Dialog.show<void>(
          context,
          title: 'Rename list',
          content: D3TextField(label: 'Name', controller: controller),
          actions: [
            D3DialogAction(
              label: 'Cancel',
              onPressedWithContext: (ctx) => D3Dialog.pop(ctx),
            ),
            D3DialogAction(
              label: 'Save',
              isDefault: true,
              onPressedWithContext: (ctx) => D3Dialog.pop(ctx),
            ),
          ],
        ).whenComplete(controller.dispose);
      },
    );
  }
}
