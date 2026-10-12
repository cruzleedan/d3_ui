import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// Tiles with icon badges, trailing text, destructive and disabled states, grouped.
class ListTileExample extends StatelessWidget {
  const ListTileExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16,
      children: [
        D3ListTileGroup(
          children: [
            D3ListTile(
              leading: D3ListTileIcon(
                icon: Icons.person_outline,
                color: context.d3Colors.primary,
              ),
              title: 'Account',
              subtitle: 'Name, email and password',
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {},
            ),
            D3ListTile(
              leading: const Icon(Icons.language_outlined),
              title: 'Language',
              trailing: const Text('English'),
              onTap: () {},
            ),
            const D3ListTile(
              leading: Icon(Icons.lock_outline),
              title: 'Privacy',
              subtitle: 'Disabled tile',
              enabled: false,
            ),
            D3ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: context.d3Colors.error,
              ),
              title: 'Delete account',
              isDestructive: true,
              onTap: () {},
            ),
          ],
        ),
        const D3ListTile(title: 'A single tile, not interactive'),
      ],
    );
  }
}
