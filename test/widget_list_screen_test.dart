import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:d3_ui/d3_ui.dart';

// Covers the sub-header row's show/hide contract from root
// context/work/0041: the select-all checkbox is selection-mode-only, and
// the row itself is omitted entirely when it would have nothing to show.

enum _Filter { all, archived }

Widget _wrap({
  List<D3FilterOption<_Filter>> filterOptions = const [],
  List<D3ListScreenAction> selectionActions = const [],
}) {
  final items = ['a', 'b', 'c'];
  return MaterialApp(
    theme: D3AppTheme.light(),
    home: D3ListScreen<String, _Filter>(
      title: 'Items',
      items: items,
      getItemId: (item) => item,
      filterOptions: filterOptions,
      activeFilters: const {},
      onFiltersChanged: filterOptions.isEmpty ? null : (_) {},
      selectionActions: selectionActions,
      itemBuilder:
          (
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

// The select-all checkbox; distinct from any checkbox a row might draw.
final _selectAllCheckbox = find.byIcon(Icons.check_box_outline_blank_rounded);

void main() {
  group('D3List separators', () {
    // A sectioned list used to skip separators entirely, so card rows
    // inside the same section sat flush against each other.
    Widget build({
      String? Function(String item)? sectionOf,
    }) => MaterialApp(
      theme: D3AppTheme.light(),
      home: Scaffold(
        body: D3List<String>(
          items: const ['a', 'b', 'c'],
          sectionBuilder: sectionOf == null
              ? null
              : (context, item, index) => sectionOf(item),
          separatorBuilder: (_, _) =>
              const SizedBox(key: ValueKey('sep'), height: 8),
          itemBuilder:
              (
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
      await tester.pumpWidget(
        _wrap(
          filterOptions: const [
            D3FilterOption(value: _Filter.all, label: 'All'),
            D3FilterOption(value: _Filter.archived, label: 'Archived'),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // The row survives for the filter pill's sake...
      expect(find.text('All'), findsOneWidget);
      // ...but the select-all control is still absent.
      expect(_selectAllCheckbox, findsNothing);
      expect(find.text('Select all'), findsNothing);
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
