import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// A search anchor that filters a local list, with match highlighting and filter chips.
class SearchAnchorExample extends StatefulWidget {
  const SearchAnchorExample({super.key});

  @override
  State<SearchAnchorExample> createState() => _SearchAnchorExampleState();
}

class _SearchAnchorExampleState extends State<SearchAnchorExample> {
  static const _people = [
    ('Alice Brown', 'Designer'),
    ('Amanda Chen', 'Engineer'),
    ('Bob Carter', 'Manager'),
    ('Clara Davis', 'Designer'),
    ('Dan Lee', 'Engineer'),
    ('Eva Morales', 'Product'),
    ('Frank Nguyen', 'Engineer'),
    ('Grace Park', 'Designer'),
  ];

  final _controller = D3SearchController();
  Set<String> _filters = {'all'};

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<(String, String)> _filter(
    List<(String, String)> items,
    String query,
    Set<String> filters,
  ) {
    final q = query.toLowerCase();
    return items
        .where((p) => filters.contains('all') || filters.contains(p.$2))
        .where((p) => p.$1.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    return D3SearchAnchor<(String, String), String>.local(
      controller: _controller,
      hint: 'Search people',
      padding: EdgeInsets.zero,
      items: _people,
      filterItems: _filter,
      filterOptions: const [
        D3FilterOption(value: 'all', label: 'All'),
        D3FilterOption(value: 'Designer', label: 'Designers'),
        D3FilterOption(value: 'Engineer', label: 'Engineers'),
      ],
      activeFilters: _filters,
      onFiltersChanged: (f) => setState(() => _filters = f),
      emptyState: D3EmptyState(
        icon: Icons.search_off_rounded,
        iconColor: colors.onSurfaceVariant,
        title: 'No people found',
        message: 'Try a different name.',
        compact: true,
      ),
      resultBuilder: (context, results, query) => D3List<(String, String)>(
        items: results,
        itemBuilder: (context, person, _,
                {isSelected = false, inSelectionMode = false, onAvatarTap}) =>
            D3ListTile(
          leading: D3Avatar(name: person.$1, size: D3AvatarSize.sm),
          titleWidget: RichText(
            text: D3SearchAnchor.highlight(
              text: person.$1,
              query: query,
              style: TextStyle(fontSize: 14, color: colors.onSurface),
              highlightColor: colors.primary,
            ),
          ),
          subtitle: person.$2,
          onTap: () => _controller.close(),
        ),
      ),
    );
  }
}
