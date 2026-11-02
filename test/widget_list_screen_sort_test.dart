import 'package:d3_ui/d3_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Widget _app({List<D3SortOption<String>> sort = const []}) => MaterialApp(
  theme: D3AppTheme.light(),
  home: D3ListScreen<String, int>(
    title: 'Items',
    items: const ['banana', 'apple', 'cherry'],
    getItemId: (i) => i,
    itemBuilder: (
      context,
      item,
      index, {
      isSelected = false,
      inSelectionMode = false,
      onAvatarTap,
    }) => Text(item, key: ValueKey(item)),
    sortOptions: sort,
  ),
);

double _y(WidgetTester t, String k) => t.getTopLeft(find.text(k)).dy;

void main() {
  final sort = [
    D3SortOption<String>(label: 'As entered', compare: (a, b) => 0),
    D3SortOption<String>(label: 'A to Z', compare: (a, b) => a.compareTo(b)),
  ];

  testWidgets('no sort action with fewer than two options', (t) async {
    await t.pumpWidget(_app());
    expect(find.bySemanticsLabel('Sort'), findsNothing);
  });

  testWidgets('choosing a sort reorders the rows', (t) async {
    await t.pumpWidget(_app(sort: sort));
    expect(_y(t, 'banana') < _y(t, 'apple'), isTrue);
    await t.tap(find.bySemanticsLabel('Sort'));
    await t.pumpAndSettle();
    await t.tap(find.text('A to Z'));
    await t.pumpAndSettle();
    expect(_y(t, 'apple') < _y(t, 'banana'), isTrue);
    expect(_y(t, 'banana') < _y(t, 'cherry'), isTrue);
  });
}
