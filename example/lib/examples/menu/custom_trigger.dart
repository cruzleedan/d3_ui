import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// A menu opened by a D3Button, used to pick a sort order.
class MenuCustomTriggerExample extends StatefulWidget {
  const MenuCustomTriggerExample({super.key});

  @override
  State<MenuCustomTriggerExample> createState() =>
      _MenuCustomTriggerExampleState();
}

class _MenuCustomTriggerExampleState extends State<MenuCustomTriggerExample> {
  static const _orders = ['Newest first', 'Oldest first', 'Name A to Z'];
  String _order = _orders.first;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: D3Menu(
        alignment: Alignment.topLeft,
        triggerBuilder: (context, toggle) => D3Button(
          label: 'Sort: $_order',
          variant: D3ButtonVariant.outlined,
          leadingIcon: Icons.sort_rounded,
          onPressed: toggle,
        ),
        entries: [
          const D3MenuSection('Sort by'),
          for (final o in _orders)
            D3MenuItem(
              label: o,
              isSelected: o == _order,
              onPressed: () => setState(() => _order = o),
            ),
        ],
      ),
    );
  }
}
