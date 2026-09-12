import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:d3_ui/d3_ui.dart';

// Covers D3SelectionLeading's contract from root context/work/0042: the
// selection indicator replaces the row's existing leading widget in place,
// at the same size, so entering selection mode never resizes the row.

Widget _wrap({
  required bool inSelectionMode,
  bool isSelected = false,
  VoidCallback? onToggle,
  double size = 40,
}) {
  return MaterialApp(
    theme: D3AppTheme.light(),
    home: Scaffold(
      body: Center(
        child: D3SelectionLeading(
          inSelectionMode: inSelectionMode,
          isSelected: isSelected,
          onToggle: onToggle,
          size: size,
          child: const Icon(Icons.person, key: ValueKey('avatar')),
        ),
      ),
    ),
  );
}

void main() {
  group('D3SelectionLeading', () {
    testWidgets('shows the row\'s own leading widget when not selecting', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(inSelectionMode: false));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('avatar')), findsOneWidget);
      expect(find.byType(D3SelectCircle), findsNothing);
    });

    testWidgets('swaps in the select circle in selection mode', (tester) async {
      await tester.pumpWidget(_wrap(inSelectionMode: true));
      await tester.pumpAndSettle();

      expect(find.byType(D3SelectCircle), findsOneWidget);
      expect(find.byKey(const ValueKey('avatar')), findsNothing);
    });

    testWidgets('occupies the same size in both modes', (tester) async {
      await tester.pumpWidget(_wrap(inSelectionMode: false));
      await tester.pumpAndSettle();
      final unselectedSize = tester.getSize(
        find.byType(D3SelectionLeading),
      );

      await tester.pumpWidget(_wrap(inSelectionMode: true));
      await tester.pumpAndSettle();
      final selectingSize = tester.getSize(find.byType(D3SelectionLeading));

      // The whole point of the widget: no layout change on mode switch.
      expect(selectingSize, unselectedSize);
      expect(selectingSize, const Size(40, 40));
    });

    testWidgets('the circle matches the requested size, not the 32dp default', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(inSelectionMode: true, size: 52));
      await tester.pumpAndSettle();

      expect(tester.getSize(find.byType(D3SelectCircle)), const Size(52, 52));
    });

    testWidgets('tapping the indicator calls onToggle', (tester) async {
      var toggles = 0;
      await tester.pumpWidget(
        _wrap(inSelectionMode: true, onToggle: () => toggles++),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(D3SelectCircle));
      await tester.pumpAndSettle();

      expect(toggles, 1);
    });

    testWidgets('tapping a row body keeps the selection and opens the row', (
      tester,
    ) async {
      // Root context/work/0043: selecting an item then tapping that same
      // card used to deselect it — one toggle doing exactly what a toggle
      // does. Selection now changes only via the indicator or a long-press,
      // so the card's own tap handler keeps working during selection.
      var selected = <String>{};
      var cardTaps = 0;

      Widget build() => MaterialApp(
        theme: D3AppTheme.light(),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => D3List<String>(
              items: const ['a', 'b'],
              selectable: true,
              getItemId: (item) => item,
              selectedIds: selected,
              onSelectionChanged: (next) => setState(() => selected = next),
              itemBuilder:
                  (
                    context,
                    item,
                    index, {
                    bool isSelected = false,
                    bool inSelectionMode = false,
                    VoidCallback? onAvatarTap,
                  }) => D3Card(
                    title: 'Item $item',
                    onTap: () => cardTaps++,
                  ),
            ),
          ),
        ),
      );

      await tester.pumpWidget(build());
      await tester.pumpAndSettle();

      await tester.longPress(find.text('Item a'));
      await tester.pumpAndSettle();
      expect(selected, {'a'}, reason: 'long-press selects');

      // The reported scenario: select, then tap that same card.
      await tester.tap(find.text('Item a'));
      await tester.pumpAndSettle();
      expect(
        selected,
        {'a'},
        reason: 'tapping the card must not drop the selection',
      );
      expect(cardTaps, 1, reason: "the card's own onTap still runs");

      // Another row's body likewise opens it rather than selecting it.
      await tester.tap(find.text('Item b'));
      await tester.pumpAndSettle();
      expect(selected, {'a'}, reason: 'body taps never change selection');
      expect(cardTaps, 2);
    });

    testWidgets('the indicator is how a row gets unselected', (tester) async {
      // The counterpart to the test above: body taps no longer toggle, so
      // D3SelectionLeading's own tap target is the user's way out of a
      // selection. End-to-end through a real D3List, not a stub.
      var selected = <String>{};

      await tester.pumpWidget(
        MaterialApp(
          theme: D3AppTheme.light(),
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => D3List<String>(
                items: const ['a', 'b'],
                selectable: true,
                getItemId: (item) => item,
                selectedIds: selected,
                onSelectionChanged: (next) => setState(() => selected = next),
                itemBuilder:
                    (
                      context,
                      item,
                      index, {
                      bool isSelected = false,
                      bool inSelectionMode = false,
                      VoidCallback? onAvatarTap,
                    }) => D3Card(
                      onTap: () {},
                      content: Row(
                        children: [
                          D3SelectionLeading(
                            inSelectionMode: inSelectionMode,
                            isSelected: isSelected,
                            onToggle: onAvatarTap,
                            size: 40,
                            child: const Icon(Icons.person),
                          ),
                          const SizedBox(width: 12),
                          Text('Item $item'),
                        ],
                      ),
                    ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.longPress(find.text('Item a'));
      await tester.pumpAndSettle();
      expect(selected, {'a'});
      expect(find.byType(D3SelectCircle), findsNWidgets(2));

      // Tap the indicator on the *other* row to add it.
      await tester.tap(find.byType(D3SelectCircle).last);
      await tester.pumpAndSettle();
      expect(selected, {'a', 'b'});

      // And tap the first row's indicator to remove it again.
      await tester.tap(find.byType(D3SelectCircle).first);
      await tester.pumpAndSettle();
      expect(selected, {'b'});
    });

    testWidgets('long-press adds more rows to the selection', (tester) async {
      var selected = <String>{};

      await tester.pumpWidget(
        MaterialApp(
          theme: D3AppTheme.light(),
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => D3List<String>(
                items: const ['a', 'b'],
                selectable: true,
                getItemId: (item) => item,
                selectedIds: selected,
                onSelectionChanged: (next) => setState(() => selected = next),
                itemBuilder:
                    (
                      context,
                      item,
                      index, {
                      bool isSelected = false,
                      bool inSelectionMode = false,
                      VoidCallback? onAvatarTap,
                    }) => D3Card(title: 'Item $item', onTap: () {}),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.longPress(find.text('Item a'));
      await tester.pumpAndSettle();
      await tester.longPress(find.text('Item b'));
      await tester.pumpAndSettle();

      expect(selected, {'a', 'b'});
    });

    testWidgets('selected state fills the circle', (tester) async {
      await tester.pumpWidget(
        _wrap(inSelectionMode: true, isSelected: true),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_rounded), findsOneWidget);

      await tester.pumpWidget(_wrap(inSelectionMode: true));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_rounded), findsNothing);
    });
  });
}
