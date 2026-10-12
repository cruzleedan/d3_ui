import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// A scrolling list with sections. Long-press a row to start selecting.
class ListExample extends StatefulWidget {
  const ListExample({super.key});

  @override
  State<ListExample> createState() => _ListExampleState();
}

class _ListExampleState extends State<ListExample> {
  static const _places = [
    ('Bao House', 'Asian'),
    ('Casa Verde', 'Mexican'),
    ('Dough Brothers', 'Pizza'),
    ('Ember Grill', 'Steak'),
    ('Green Bowl', 'Salads'),
    ('Harbour Fish', 'Seafood'),
    ('Ivy Cafe', 'Brunch'),
  ];

  Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 340,
      child: D3List<(String, String)>(
        items: _places,
        selectable: true,
        getItemId: (p) => p.$1,
        selectedIds: _selected,
        onSelectionChanged: (ids) => setState(() => _selected = ids),
        sectionBuilder: (context, p, index) => p.$1[0],
        itemBuilder: (
          context,
          p,
          index, {
          isSelected = false,
          inSelectionMode = false,
          onAvatarTap,
        }) =>
            D3ListTile(
          title: p.$1,
          subtitle: p.$2,
          leading: D3SelectionLeading(
            inSelectionMode: inSelectionMode,
            isSelected: isSelected,
            onToggle: onAvatarTap,
            size: 40,
            child: D3Avatar(name: p.$1, size: D3AvatarSize.sm),
          ),
        ),
      ),
    );
  }
}
