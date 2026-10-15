import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// An overflow menu with sections, a selected, a destructive and a disabled item.
class MenuBasicExample extends StatefulWidget {
  const MenuBasicExample({super.key});

  @override
  State<MenuBasicExample> createState() => _MenuBasicExampleState();
}

class _MenuBasicExampleState extends State<MenuBasicExample> {
  String _last = 'Nothing yet';
  bool _pinned = true;

  @override
  Widget build(BuildContext context) {
    void pick(String name) => setState(() => _last = name);

    return Row(
      children: [
        Expanded(child: Text('Last choice: $_last')),
        D3MenuButton(
          entries: [
            const D3MenuSection('Note'),
            D3MenuItem(
              label: 'Edit',
              icon: Icons.edit_outlined,
              shortcut: 'E',
              onPressed: () => pick('Edit'),
            ),
            D3MenuItem(
              label: 'Pinned',
              icon: Icons.push_pin_outlined,
              isSelected: _pinned,
              onPressed: () {
                setState(() => _pinned = !_pinned);
                pick('Pinned: ${!_pinned ? 'off' : 'on'}');
              },
            ),
            const D3MenuItem(
                label: 'Share (offline)', icon: Icons.share, enabled: false),
            const D3MenuDivider(),
            D3MenuItem(
              label: 'Delete',
              icon: Icons.delete_outline,
              isDestructive: true,
              onPressed: () => pick('Delete'),
            ),
          ],
        ),
      ],
    );
  }
}
