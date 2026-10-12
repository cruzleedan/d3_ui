import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// Dialogs: destructive confirmation, informational alert and plain message.
class DialogVariantsExample extends StatefulWidget {
  const DialogVariantsExample({super.key});

  @override
  State<DialogVariantsExample> createState() => _DialogVariantsExampleState();
}

class _DialogVariantsExampleState extends State<DialogVariantsExample> {
  String? _result;

  Future<void> _confirmDelete() async {
    final confirmed = await D3Dialog.show<bool>(
      context,
      icon: Icons.delete_outline_rounded,
      iconColor: context.d3Colors.error,
      title: 'Delete account',
      message: 'This removes your data and cannot be undone.',
      actions: [
        D3DialogAction(
          label: 'Cancel',
          onPressedWithContext: (ctx) => D3Dialog.pop(ctx, false),
        ),
        D3DialogAction(
          label: 'Delete',
          isDestructive: true,
          onPressedWithContext: (ctx) => D3Dialog.pop(ctx, true),
        ),
      ],
    );
    setState(() => _result = confirmed == true ? 'Deleted' : 'Cancelled');
  }

  Future<void> _showAlert() async {
    await D3Dialog.show<void>(
      context,
      icon: Icons.wifi_off_rounded,
      iconPlacement: D3DialogIconPlacement.leading,
      title: 'Connection lost',
      message: 'Check your internet connection and try again.',
      actions: [
        D3DialogAction(
          label: 'OK',
          isDefault: true,
          onPressedWithContext: (ctx) => D3Dialog.pop(ctx),
        ),
      ],
    );
  }

  Future<void> _showPlain() async {
    final leave = await D3Dialog.show<bool>(
      context,
      title: 'Leave this page?',
      message: 'Your draft is saved automatically.',
      actions: [
        D3DialogAction(
          label: 'Stay',
          onPressedWithContext: (ctx) => D3Dialog.pop(ctx, false),
        ),
        D3DialogAction(
          label: 'Leave',
          isDefault: true,
          onPressedWithContext: (ctx) => D3Dialog.pop(ctx, true),
        ),
      ],
    );
    setState(() => _result = leave == true ? 'Left' : 'Stayed');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            D3Button(
              label: 'Confirm delete',
              variant: D3ButtonVariant.danger,
              onPressed: _confirmDelete,
            ),
            D3Button(
              label: 'Alert',
              variant: D3ButtonVariant.outlined,
              onPressed: _showAlert,
            ),
            D3Button(
              label: 'Plain',
              variant: D3ButtonVariant.outlined,
              onPressed: _showPlain,
            ),
          ],
        ),
        if (_result != null) ...[
          const SizedBox(height: 12),
          Text('Last result: $_result'),
        ],
      ],
    );
  }
}
