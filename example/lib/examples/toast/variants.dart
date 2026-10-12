import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// Short messages at the bottom of the screen, one per kind.
class ToastVariantsExample extends StatelessWidget {
  const ToastVariantsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        D3Button(
          label: 'Success',
          variant: D3ButtonVariant.outlined,
          onPressed: () => D3Toast.success(context, title: 'Changes saved'),
        ),
        D3Button(
          label: 'Info',
          variant: D3ButtonVariant.outlined,
          onPressed: () => D3Toast.info(context,
              title: 'Tip', message: 'Swipe a row to delete it.'),
        ),
        D3Button(
          label: 'Warning',
          variant: D3ButtonVariant.outlined,
          onPressed: () => D3Toast.warning(context, title: 'Low storage'),
        ),
        D3Button(
          label: 'Error',
          variant: D3ButtonVariant.outlined,
          onPressed: () => D3Toast.error(
            context,
            title: 'Upload failed',
            message: 'Check your connection and try again.',
          ),
        ),
        D3Button(
          label: 'Neutral',
          variant: D3ButtonVariant.outlined,
          onPressed: () => D3Toast.show(context, title: 'Copied to clipboard'),
        ),
      ],
    );
  }
}
