import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// Badges overlaid on an icon button, an avatar and a tab-like row.
class BadgeOnWidgetsExample extends StatelessWidget {
  const BadgeOnWidgetsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 24,
      runSpacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        D3Badge.on(
          badge: const D3Badge.count(3, semanticsLabel: '3 notifications'),
          child: IconButton(
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ),
        D3BadgeAnchor(
          alignment: Alignment.bottomRight,
          badge: const D3Badge.dot(
            variant: D3BadgeVariant.success,
            semanticsLabel: 'Online',
          ),
          child: const CircleAvatar(child: Text('AB')),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (label, count) in [
              ('Inbox', 12),
              ('Sent', 0),
              ('Spam', 120)
            ])
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(label),
                    const SizedBox(width: 6),
                    D3Badge.count(count, variant: D3BadgeVariant.neutral),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}
