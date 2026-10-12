import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

enum _Cuisine { all, asian, pizza }

/// A list screen with search, filter chips and long-press multi-select.
class ListScreenExample extends StatelessWidget {
  const ListScreenExample({super.key});

  static const _places = [
    ('Bao House', _Cuisine.asian),
    ('Casa Verde', _Cuisine.all),
    ('Dough Brothers', _Cuisine.pizza),
    ('Ember Grill', _Cuisine.all),
    ('Green Bowl', _Cuisine.all),
    ('Noodle Bar', _Cuisine.asian),
    ('Slice Society', _Cuisine.pizza),
    ('Tokyo Ramen', _Cuisine.asian),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 420,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        border: Border.all(color: context.d3Colors.outline),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Navigator(
        onGenerateRoute: (_) => MaterialPageRoute<void>(
          builder: (_) => D3ListScreen<(String, _Cuisine), _Cuisine>(
            title: 'Restaurants',
            items: _places,
            getItemId: (item) => item.$1,
            itemBuilder: (context, item, index,
                {bool isSelected = false,
                bool inSelectionMode = false,
                VoidCallback? onAvatarTap}) {
              return D3ListTile(
                leading: const Icon(Icons.restaurant_outlined),
                title: item.$1,
                subtitle: item.$2.name,
              );
            },
            filterOptions: const [
              D3FilterOption(value: _Cuisine.asian, label: 'Asian'),
              D3FilterOption(value: _Cuisine.pizza, label: 'Pizza'),
            ],
            filterItems: (items, query, active) => [
              for (final item in items)
                if (active.isEmpty || active.contains(item.$2))
                  if (query.isEmpty ||
                      item.$1.toLowerCase().contains(query.toLowerCase()))
                    item,
            ],
            selectionActions: [
              D3ListScreenAction(
                icon: Icons.favorite_border_rounded,
                label: 'Save',
                onPressed: (ids, clear) => clear(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
