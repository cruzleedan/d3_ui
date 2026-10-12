import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// A main action with a menu of related ones.
class SplitButtonVariantsExample extends StatelessWidget {
  const SplitButtonVariantsExample({super.key});

  @override
  Widget build(BuildContext context) {
    List<D3SplitButtonItem> items() => [
          D3SplitButtonItem(
            label: 'Save as draft',
            icon: Icons.drafts_outlined,
            onPressed: () => D3Toast.info(context, title: 'Saved as draft'),
          ),
          D3SplitButtonItem(
            label: 'Schedule',
            icon: Icons.schedule_outlined,
            onPressed: () => D3Toast.info(context, title: 'Scheduled'),
          ),
          D3SplitButtonItem(
            label: 'Discard',
            icon: Icons.delete_outline,
            isDestructive: true,
            onPressed: () => D3Toast.warning(context, title: 'Discarded'),
          ),
        ];
    void publish() => D3Toast.success(context, title: 'Published');

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        D3SplitButton(
            label: 'Publish',
            icon: Icons.send_outlined,
            onPressed: publish,
            items: items()),
        D3SplitButton(
          label: 'Publish',
          variant: D3SplitButtonVariant.tonal,
          onPressed: publish,
          items: items(),
        ),
        D3SplitButton(
          label: 'Publish',
          variant: D3SplitButtonVariant.outlined,
          onPressed: publish,
          items: items(),
        ),
      ],
    );
  }
}
