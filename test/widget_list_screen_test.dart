import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:d3_ui/d3_ui.dart';

// Covers the sub-header row's show/hide contract from root
// context/work/0041: the select-all checkbox is selection-mode-only, and
// the row itself is omitted entirely when it would have nothing to show.

enum _Filter { all, archived }

Widget _wrap({
  List<String> items = const ['a', 'b', 'c'],
  List<D3FilterOption<_Filter>> filterOptions = const [],
  Set<_Filter> activeFilters = const {},
  Set<_Filter>? defaultFilters,
  ValueChanged<Set<_Filter>>? onFiltersChanged,
  List<String> Function(
    List<String> items,
    String query,
    Set<_Filter> activeFilters,
  )?
  filterItems,
  ValueChanged<String>? onSearchChanged,
  List<D3ListScreenAction> selectionActions = const [],
}) {
  return MaterialApp(
    theme: D3AppTheme.light(),
    home: D3ListScreen<String, _Filter>(
      title: 'Items',
      items: items,
      getItemId: (item) => item,
      filterOptions: filterOptions,
      activeFilters: activeFilters,
      defaultFilters: defaultFilters,
      onFiltersChanged: onFiltersChanged,
      filterItems: filterItems,
      onSearchChanged: onSearchChanged,
      selectionActions: selectionActions,
      itemBuilder: (
        context,
        item,
        index, {
        bool isSelected = false,
        bool inSelectionMode = false,
        VoidCallback? onAvatarTap,
      }) => ListTile(key: ValueKey(item), title: Text('Item $item')),
    ),
  );
}

const _filterOptions = [
  D3FilterOption(value: _Filter.all, label: 'All'),
  D3FilterOption(value: _Filter.archived, label: 'Archived'),
];

List<String> _filterStrings(
  List<String> items,
  String query,
  Set<_Filter> activeFilters,
) {
  final filter = activeFilters.isEmpty ? _Filter.all : activeFilters.first;
  final normalizedQuery = query.trim().toLowerCase();
  return items.where((item) {
    final matchesFilter = filter == _Filter.all || item.startsWith('archived');
    return matchesFilter && item.toLowerCase().contains(normalizedQuery);
  }).toList();
}

// The select-all checkbox; distinct from any checkbox a row might draw.
final _selectAllCheckbox = find.byIcon(Icons.check_box_outline_blank_rounded);

void main() {
  group('D3List separators', () {
    // A sectioned list used to skip separators entirely, so card rows
    // inside the same section sat flush against each other.
    Widget build({String? Function(String item)? sectionOf}) => MaterialApp(
      theme: D3AppTheme.light(),
      home: Scaffold(
        body: D3List<String>(
          items: const ['a', 'b', 'c'],
          sectionBuilder: sectionOf == null
              ? null
              : (context, item, index) => sectionOf(item),
          separatorBuilder: (_, _) =>
              const SizedBox(key: ValueKey('sep'), height: 8),
          itemBuilder: (
            context,
            item,
            index, {
            bool isSelected = false,
            bool inSelectionMode = false,
            VoidCallback? onAvatarTap,
          }) => Text('Item $item'),
        ),
      ),
    );

    testWidgets('separates rows in an unsectioned list', (tester) async {
      await tester.pumpWidget(build());
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('sep')), findsNWidgets(2));
    });

    testWidgets('separates rows within a section', (tester) async {
      // All three rows in one section → two separators, no header break.
      await tester.pumpWidget(build(sectionOf: (_) => 'Today'));
      await tester.pumpAndSettle();

      expect(find.text('Today'), findsOneWidget);
      expect(find.byKey(const ValueKey('sep')), findsNWidgets(2));
    });

    testWidgets('omits the separator directly under a section header', (
      tester,
    ) async {
      // a | b, c → headers before 'a' and 'b'; only b→c gets a separator.
      await tester.pumpWidget(
        build(sectionOf: (item) => item == 'a' ? 'Today' : 'Older'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Older'), findsOneWidget);
      expect(find.byKey(const ValueKey('sep')), findsOneWidget);
    });
  });

  group('D3ListScreen sub-header', () {
    testWidgets(
      'no filters and nothing selected → no select-all checkbox is shown',
      (tester) async {
        await tester.pumpWidget(_wrap());
        await tester.pumpAndSettle();

        expect(find.text('Item a'), findsOneWidget);
        expect(_selectAllCheckbox, findsNothing);
        expect(find.text('Select all'), findsNothing);
      },
    );

    testWidgets('filter pill still renders outside selection mode', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(filterOptions: _filterOptions));
      await tester.pumpAndSettle();

      // The row survives for the filter pill's sake...
      expect(find.text('All'), findsOneWidget);
      // ...but the select-all control is still absent.
      expect(_selectAllCheckbox, findsNothing);
      expect(find.text('Select all'), findsNothing);
    });

    testWidgets('local filter menu works without a callback', (tester) async {
      await tester.pumpWidget(
        _wrap(
          items: const ['active', 'archived'],
          filterOptions: _filterOptions,
          defaultFilters: const {_Filter.all},
          filterItems: _filterStrings,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();

      expect(find.byType(PopupMenuItem<_Filter>), findsNWidgets(2));
      expect(find.text('Archived'), findsOneWidget);

      await tester.tap(find.text('Archived'));
      await tester.pumpAndSettle();

      expect(find.text('Archived'), findsOneWidget);
      expect(find.text('Item active'), findsNothing);
      expect(find.text('Item archived'), findsOneWidget);

      // A provider refresh rebuilds the caller without resetting its local
      // selection, and newly loaded rows use that same selection.
      await tester.pumpWidget(
        _wrap(
          items: const ['active', 'archived', 'archived-new'],
          filterOptions: _filterOptions,
          defaultFilters: const {_Filter.all},
          filterItems: _filterStrings,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Item active'), findsNothing);
      expect(find.text('Item archived-new'), findsOneWidget);
      await tester.tap(find.text('Archived'));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.widgetWithText(PopupMenuItem<_Filter>, 'Archived'),
          matching: find.byIcon(Icons.check_rounded),
        ),
        findsOneWidget,
      );
      await tester.tap(find.widgetWithText(PopupMenuItem<_Filter>, 'All'));
      await tester.pumpAndSettle();
      expect(find.text('Item active'), findsOneWidget);
    });

    testWidgets('local filter changes notify an optional callback', (
      tester,
    ) async {
      Set<_Filter>? notifiedFilters;
      await tester.pumpWidget(
        _wrap(
          items: const ['active', 'archived'],
          filterOptions: _filterOptions,
          defaultFilters: const {_Filter.all},
          filterItems: _filterStrings,
          onFiltersChanged: (filters) => notifiedFilters = filters,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Archived'));
      await tester.pumpAndSettle();

      expect(notifiedFilters, const {_Filter.archived});
    });

    testWidgets('caller changes to active filters update the local list', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          items: const ['active', 'archived'],
          filterOptions: _filterOptions,
          activeFilters: const {_Filter.all},
          defaultFilters: const {_Filter.all},
          filterItems: _filterStrings,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Item active'), findsOneWidget);

      await tester.pumpWidget(
        _wrap(
          items: const ['active', 'archived'],
          filterOptions: _filterOptions,
          activeFilters: const {_Filter.archived},
          defaultFilters: const {_Filter.all},
          filterItems: _filterStrings,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Archived'), findsOneWidget);
      expect(find.text('Item active'), findsNothing);
      expect(find.text('Item archived'), findsOneWidget);
    });

    testWidgets('an explicit empty update does not restore default filters', (
      tester,
    ) async {
      Widget build(Set<_Filter> activeFilters) => _wrap(
        items: const ['active', 'archived'],
        filterOptions: _filterOptions,
        activeFilters: activeFilters,
        defaultFilters: const {_Filter.archived},
        filterItems: _filterStrings,
      );
      await tester.pumpWidget(build(const {_Filter.archived}));
      await tester.pumpAndSettle();
      expect(find.text('Item active'), findsNothing);
      await tester.pumpWidget(build(const {}));
      await tester.pumpAndSettle();
      expect(find.text('Item active'), findsOneWidget);
      expect(find.text('Item archived'), findsOneWidget);
    });

    testWidgets('search can switch filters over the full source list', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          items: const ['active', 'archived'],
          filterOptions: _filterOptions,
          defaultFilters: const {_Filter.all},
          filterItems: _filterStrings,
          onSearchChanged: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Archived'));
      await tester.pumpAndSettle();
      expect(find.text('Item active'), findsNothing);

      await tester.tap(find.byIcon(Icons.search_rounded).first);
      await tester.pumpAndSettle();
      expect(find.text('Item active'), findsNothing);
      expect(find.text('Item archived'), findsOneWidget);
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();

      expect(find.text('Item active'), findsOneWidget);
      expect(find.text('Item archived'), findsOneWidget);
    });

    testWidgets('select-all only selects rows visible through the filter', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          items: const ['active', 'archived-a', 'archived-b'],
          filterOptions: _filterOptions,
          defaultFilters: const {_Filter.all},
          filterItems: _filterStrings,
          selectionActions: [
            D3ListScreenAction(
              icon: Icons.delete_outline_rounded,
              label: 'Delete',
              onPressed: (_, _) {},
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Archived'));
      await tester.pumpAndSettle();
      await tester.longPress(find.text('Item archived-a'));
      await tester.pumpAndSettle();
      expect(find.text('1 selected'), findsOneWidget);

      await tester.tap(_selectAllCheckbox);
      await tester.pumpAndSettle();

      expect(find.text('2 selected'), findsOneWidget);
    });

    testWidgets('long-press enters selection mode and reveals select-all', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          selectionActions: [
            D3ListScreenAction(
              icon: Icons.delete_outline_rounded,
              label: 'Delete',
              onPressed: (_, _) {},
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(_selectAllCheckbox, findsNothing);

      await tester.longPress(find.text('Item a'));
      await tester.pumpAndSettle();

      expect(_selectAllCheckbox, findsOneWidget);
      expect(find.text('Select all'), findsOneWidget);
    });

    testWidgets('leaving selection mode hides select-all again', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          selectionActions: [
            D3ListScreenAction(
              icon: Icons.delete_outline_rounded,
              label: 'Delete',
              onPressed: (_, _) {},
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await tester.longPress(find.text('Item a'));
      await tester.pumpAndSettle();
      expect(find.text('Select all'), findsOneWidget);

      // The CAB's close button clears the selection. (A tap on the row
      // body deliberately does not — see root context/work/0043.)
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(_selectAllCheckbox, findsNothing);
      expect(find.text('Select all'), findsNothing);
    });
  });
}
