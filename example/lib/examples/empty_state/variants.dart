import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// What to show when there is nothing to show: say why, and offer a next step.
class EmptyStateExample extends StatelessWidget {
  const EmptyStateExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        D3EmptyState(
          icon: Icons.inbox_outlined,
          title: 'No saved places yet',
          message: 'Tap the heart on a place to keep it here.',
          action: D3Button(label: 'Explore places', onPressed: () {}),
          secondaryAction: D3Button(
            label: 'Learn more',
            variant: D3ButtonVariant.ghost,
            onPressed: () {},
          ),
        ),
        const Divider(height: 32),
        const D3EmptyState(
          icon: Icons.search_off_rounded,
          title: 'No results',
          message: 'Try a different search.',
          compact: true,
        ),
        const Divider(height: 32),
        D3EmptyState(
          icon: Icons.cloud_off_rounded,
          iconColor: context.d3Colors.error,
          title: 'Could not load',
          message: 'Check your connection and try again.',
          compact: true,
        ),
      ],
    );
  }
}
