import 'dart:ui' show Tristate;

import 'package:d3_ui/d3_ui.dart';
import 'package:d3_ui/src/components/actions/d3_menu.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Widget _app(
  Widget body, {
  ThemeData? theme,
  double textScale = 1.0,
  Alignment align = Alignment.topLeft,
  bool disableAnimations = false,
}) {
  return MaterialApp(
    theme: theme ?? D3AppTheme.light(),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(textScale),
        disableAnimations: disableAnimations,
      ),
      child: child!,
    ),
    home: Scaffold(
      body: Align(alignment: align, child: body),
    ),
  );
}

void main() {
  const triggerKey = Key('trigger');

  Widget menu(
    List<D3MenuEntry> entries, {
    Alignment alignment = Alignment.topRight,
  }) => D3Menu(
    alignment: alignment,
    triggerBuilder: (context, toggle) => IconButton(
      key: triggerKey,
      icon: const Icon(Icons.more_vert),
      onPressed: toggle,
    ),
    entries: entries,
  );

  Future<void> open(WidgetTester tester) async {
    await tester.tap(find.byKey(triggerKey));
    await tester.pumpAndSettle();
  }

  testWidgets('opens on tap and shows entries', (tester) async {
    await tester.pumpWidget(
      _app(
        menu([
          const D3MenuSection('Group'),
          const D3MenuItem(label: 'One'),
          const D3MenuDivider(),
          const D3MenuItem(label: 'Two', shortcut: 'T'),
        ]),
      ),
    );
    expect(find.text('One'), findsNothing);
    await open(tester);
    expect(find.text('Group'), findsOneWidget);
    expect(find.text('One'), findsOneWidget);
    expect(find.text('Two'), findsOneWidget);
    expect(find.text('T'), findsOneWidget);
  });

  testWidgets('selecting runs the callback once and closes', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      _app(menu([D3MenuItem(label: 'One', onPressed: () => calls++)])),
    );
    await open(tester);
    await tester.tap(find.text('One'));
    await tester.pumpAndSettle();
    expect(calls, 1);
    expect(find.text('One'), findsNothing);
  });

  testWidgets('outside tap closes without selecting', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      _app(menu([D3MenuItem(label: 'One', onPressed: () => calls++)])),
    );
    await open(tester);
    await tester.tapAt(const Offset(700, 500));
    await tester.pumpAndSettle();
    expect(find.text('One'), findsNothing);
    expect(calls, 0);
  });

  testWidgets('escape closes', (tester) async {
    await tester.pumpWidget(_app(menu([const D3MenuItem(label: 'One')])));
    await open(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('One'), findsNothing);
  });

  testWidgets('arrows move focus, skipping disabled; enter selects', (
    tester,
  ) async {
    final picked = <String>[];
    await tester.pumpWidget(
      _app(
        menu([
          D3MenuItem(label: 'One', onPressed: () => picked.add('One')),
          D3MenuItem(
            label: 'Off',
            enabled: false,
            onPressed: () => picked.add('Off'),
          ),
          D3MenuItem(label: 'Three', onPressed: () => picked.add('Three')),
        ]),
      ),
    );
    await open(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(picked, ['Three']);
  });

  testWidgets('enter selects the first enabled item on open', (tester) async {
    final picked = <String>[];
    await tester.pumpWidget(
      _app(
        menu([
          const D3MenuItem(label: 'Off', enabled: false),
          D3MenuItem(label: 'One', onPressed: () => picked.add('One')),
        ]),
      ),
    );
    await open(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(picked, ['One']);
  });

  testWidgets('disabled items cannot be chosen', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      _app(
        menu([
          D3MenuItem(label: 'Off', enabled: false, onPressed: () => calls++),
        ]),
      ),
    );
    await open(tester);
    await tester.tap(find.text('Off'));
    await tester.pumpAndSettle();
    expect(calls, 0);
    expect(find.text('Off'), findsOneWidget);
  });

  testWidgets('rows are at least 48dp tall', (tester) async {
    await tester.pumpWidget(_app(menu([const D3MenuItem(label: 'One')])));
    await open(tester);
    final row = find.ancestor(
      of: find.text('One'),
      matching: find.byType(InkWell),
    );
    expect(tester.getSize(row).height, greaterThanOrEqualTo(48));
  });

  testWidgets('stays on screen at the right and bottom edges (320x568)', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final entries = [
      for (var i = 0; i < 6; i++) D3MenuItem(label: 'Item number $i'),
    ];
    await tester.pumpWidget(_app(menu(entries), align: Alignment.bottomRight));
    await open(tester);
    final panel = tester.getRect(
      find
          .ancestor(
            of: find.text('Item number 0'),
            matching: find.byType(Material),
          )
          .first,
    );
    expect(panel.left, greaterThanOrEqualTo(0));
    expect(panel.right, lessThanOrEqualTo(320));
    expect(panel.top, greaterThanOrEqualTo(0));
    expect(panel.bottom, lessThanOrEqualTo(568));
    // Flipped above the trigger.
    expect(
      panel.bottom,
      lessThanOrEqualTo(tester.getRect(find.byKey(triggerKey)).top + 1),
    );
  });

  testWidgets('start aligned menu at the right edge shifts onto screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      _app(
        menu([const D3MenuItem(label: 'One')], alignment: Alignment.topLeft),
        align: Alignment.topRight,
      ),
    );
    await open(tester);
    final panel = tester.getRect(
      find
          .ancestor(of: find.text('One'), matching: find.byType(Material))
          .first,
    );
    expect(panel.right, lessThanOrEqualTo(320));
    expect(panel.left, greaterThanOrEqualTo(0));
  });

  testWidgets('semantics: menu items, destructive hint, selected', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _app(
        menu([
          const D3MenuItem(label: 'Delete', isDestructive: true),
          const D3MenuItem(label: 'Name', isSelected: true),
        ]),
      ),
    );
    await open(tester);
    final del = tester.getSemantics(find.text('Delete'));
    expect(del.label, contains('Delete'));
    expect(del.hint, contains('destructive'));
    expect(del.flagsCollection.isButton, isTrue);
    final sel = tester.getSemantics(find.text('Name'));
    expect(sel.flagsCollection.isSelected, isNot(Tristate.none));
    expect(sel.flagsCollection.isSelected, Tristate.isTrue);
    handle.dispose();
  });

  testWidgets('destructive label has 4.5:1 contrast in light and dark', (
    tester,
  ) async {
    for (final theme in [D3AppTheme.light(), D3AppTheme.dark()]) {
      await tester.pumpWidget(
        _app(
          menu([const D3MenuItem(label: 'Delete', isDestructive: true)]),
          theme: theme,
        ),
      );
      await open(tester);
      final text = tester.widget<Text>(find.text('Delete'));
      final colors = tester.element(find.text('Delete')).d3Colors;
      expect(
        d3ContrastRatio(text.style!.color!, colors.surfaceContainerHigh),
        greaterThanOrEqualTo(4.5),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
    }
  });

  testWidgets('text scale 1.5 does not overflow', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      _app(
        textScale: 1.5,
        menu([
          const D3MenuSection('A fairly long section heading'),
          const D3MenuItem(
            label: 'A very long label that has to wrap onto lines',
            icon: Icons.edit,
            shortcut: 'Ctrl+Shift+E',
            isSelected: true,
          ),
        ]),
      ),
    );
    await open(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduced motion opens without animation', (tester) async {
    await tester.pumpWidget(
      _app(menu([const D3MenuItem(label: 'One')]), disableAnimations: true),
    );
    await tester.tap(find.byKey(triggerKey));
    await tester.pump();
    expect(find.text('One'), findsOneWidget);
    final fade = tester.widget<FadeTransition>(
      find
          .ancestor(of: find.text('One'), matching: find.byType(FadeTransition))
          .first,
    );
    expect(fade.opacity.value, 1.0);
  });

  testWidgets('D3MenuButton is 48dp and labelled', (tester) async {
    await tester.pumpWidget(
      _app(const D3MenuButton(entries: [D3MenuItem(label: 'One')])),
    );
    final size = tester.getSize(find.byType(IconButton));
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));
    // Named for screen readers (a label, not only a tooltip).
    expect(find.bySemanticsLabel('More options'), findsWidgets);
    // And hinted by a D3Tooltip.
    expect(
      find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.tooltip == 'More options',
      ),
      findsWidgets,
    );
  });
}
