import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// A toast with an action (such as undo) that stays until dismissed.
class ToastActionExample extends StatelessWidget {
  const ToastActionExample({super.key});

  @override
  Widget build(BuildContext context) {
    return D3Button(
      label: 'Delete item',
      variant: D3ButtonVariant.danger,
      leadingIcon: Icons.delete_outline,
      onPressed: () => D3Toast.show(
        context,
        title: 'Item deleted',
        action: D3ToastAction(
          label: 'Undo',
          onPressed: () => D3Toast.success(context, title: 'Restored'),
        ),
        duration: Duration.zero,
      ),
    );
  }
}
