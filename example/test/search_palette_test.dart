import 'dart:ui' show Tristate;

import 'package:d3_ui/d3_ui.dart';
import 'package:d3_ui_example/showcase/registry.dart';
import 'package:d3_ui_example/showcase/search/search_index.dart';
import 'package:d3_ui_example/showcase/search/search_palette.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Opens the palette from a button and records what it returned.
class _Harness {
  String? result;
  bool closed = false;

  Future<void> open(
    WidgetTester tester, {
    Size size = const Size(1280, 800),
    List<String> recentIds = const [],
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: D3AppTheme.light(),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await showShowcaseSearch(
                  context,
                  recentIds: recentIds,
                );
                closed = true;
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }
}

final _rows = find.byWidgetPredicate(
  (w) => w.runtimeType.toString() == '_ResultRow',
);

Future<void> _type(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField), text);
  await tester.pumpAndSettle();
}

Future<void> _press(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyEvent(key);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('typing filters the pages', (tester) async {
    await _Harness().open(tester);
    await _type(tester, 'toast');
    expect(find.text('Toast'), findsOneWidget);
    expect(find.text('Button'), findsNothing);
    expect(_rows, findsNWidgets(searchPages('toast', showcasePages).length));
  });

  testWidgets('the field has the hint and focus', (tester) async {
    await _Harness().open(tester);
    expect(find.text('Search components'), findsWidgets);
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.focusNode!.hasFocus, isTrue);
  });

  testWidgets('results are grouped under non-interactive headers', (
    tester,
  ) async {
    await _Harness().open(tester);
    await _type(tester, 'field');
    // The group name is a header and also the label at the right of each row.
    expect(find.text('Inputs'), findsWidgets);
    final rowCount = tester.widgetList(_rows).length;
    expect(rowCount, greaterThan(3));
    // Headers are not rows, and tapping one does nothing.
    await tester.tap(find.text('Inputs').first);
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('Down, Up and Enter choose a row, wrapping at the ends', (
    tester,
  ) async {
    final h = _Harness();
    await h.open(tester);
    await _type(tester, 'field');
    // 'field' ranks alphabetically: Date field, Decimal field, ...
    await _press(tester, LogicalKeyboardKey.arrowDown);
    await _press(tester, LogicalKeyboardKey.arrowDown);
    await _press(tester, LogicalKeyboardKey.arrowUp);
    await _press(tester, LogicalKeyboardKey.enter);
    expect(h.closed, isTrue);
    expect(h.result, 'decimal-field');
  });

  testWidgets('Up from the first row wraps to the last', (tester) async {
    final h = _Harness();
    await h.open(tester);
    await _type(tester, 'field');
    await _press(tester, LogicalKeyboardKey.arrowUp);
    await _press(tester, LogicalKeyboardKey.enter);
    expect(h.result, searchPages('field', showcasePages).last.page.id);
  });

  testWidgets('Down from the last row wraps to the first', (tester) async {
    final h = _Harness();
    await h.open(tester);
    await _type(tester, 'field');
    final count = tester.widgetList(_rows).length;
    for (var i = 0; i < count; i++) {
      await _press(tester, LogicalKeyboardKey.arrowDown);
    }
    await _press(tester, LogicalKeyboardKey.enter);
    expect(h.result, 'date-field');
  });

  testWidgets('Enter opens the first row by default', (tester) async {
    final h = _Harness();
    await h.open(tester);
    await _type(tester, 'toggle');
    await _press(tester, LogicalKeyboardKey.enter);
    expect(h.result, 'toggle');
  });

  testWidgets('hovering moves the highlight', (tester) async {
    final h = _Harness();
    await h.open(tester);
    await _type(tester, 'field');
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    await mouse.moveTo(tester.getCenter(find.text('Text field')));
    await tester.pump();
    await _press(tester, LogicalKeyboardKey.enter);
    expect(h.result, 'text-field');
  });

  testWidgets('tapping a row chooses it', (tester) async {
    final h = _Harness();
    await h.open(tester);
    await _type(tester, 'toast');
    await tester.tap(find.text('Toast'));
    await tester.pumpAndSettle();
    expect(h.result, 'toast');
  });

  testWidgets('typing keeps focus in the field', (tester) async {
    await _Harness().open(tester);
    await _type(tester, 'tab');
    await _press(tester, LogicalKeyboardKey.arrowDown);
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.focusNode!.hasFocus, isTrue);
    await tester.enterText(find.byType(TextField), 'tabs');
    expect(field.controller!.text, 'tabs');
  });

  testWidgets('Escape closes with null', (tester) async {
    final h = _Harness();
    await h.open(tester);
    await _type(tester, 'toast');
    await _press(tester, LogicalKeyboardKey.escape);
    expect(h.closed, isTrue);
    expect(h.result, isNull);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('an empty query shows the recent pages first', (tester) async {
    await _Harness().open(tester, recentIds: ['toggle', 'nope', 'badge']);
    expect(find.text('Recent'), findsOneWidget);
    expect(find.text('Popular'), findsNothing);
    expect(_rows, findsNWidgets(2));
    final toggle = tester.getTopLeft(find.text('Toggle')).dy;
    final badge = tester.getTopLeft(find.text('Badge')).dy;
    expect(toggle, lessThan(badge));
  });

  testWidgets('recent shows at most six', (tester) async {
    await _Harness().open(
      tester,
      recentIds: [
        for (final p in showcasePages.skip(1).take(9)) p.id,
      ],
    );
    expect(_rows, findsNWidgets(6));
  });

  testWidgets('without recents it shows the popular pages', (tester) async {
    final h = _Harness();
    await h.open(tester);
    expect(find.text('Popular'), findsOneWidget);
    expect(find.text('Recent'), findsNothing);
    expect(find.text('Button'), findsOneWidget);
    expect(find.text('Dialog'), findsOneWidget);
    await _press(tester, LogicalKeyboardKey.enter);
    expect(h.result, 'button');
  });

  testWidgets('no results shows a message', (tester) async {
    await _Harness().open(tester);
    await _type(tester, 'qqqzzz');
    expect(find.text('No components match "qqqzzz"'), findsOneWidget);
    expect(
      find.text('Try a shorter word, or a name like toast or toggle'),
      findsOneWidget,
    );
    expect(_rows, findsNothing);
    // Enter with nothing to open does not close it.
    await _press(tester, LogicalKeyboardKey.enter);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('rows are at least 56dp tall', (tester) async {
    await _Harness().open(tester);
    await _type(tester, 'field');
    for (final row in tester.widgetList(_rows)) {
      expect(
        tester.getSize(find.byWidget(row)).height,
        greaterThanOrEqualTo(56),
      );
    }
  });

  testWidgets('wide screens get a centred palette over a barrier', (
    tester,
  ) async {
    await _Harness().open(tester);
    await _type(tester, 'toast');
    final bar = tester.getRect(find.byType(D3SearchBar));
    expect(bar.width, lessThanOrEqualTo(600));
    expect(bar.center.dx, closeTo(640, 1));
    expect(bar.top, greaterThan(800 * 0.12));
    // The group is also written at the right of the row.
    expect(find.text('Feedback'), findsNWidgets(2));
    // Tapping the barrier closes it.
    await tester.tapAt(const Offset(20, 780));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('narrow screens get a full-screen route with a back arrow', (
    tester,
  ) async {
    final h = _Harness();
    await h.open(tester, size: const Size(390, 800));
    await _type(tester, 'toast');
    expect(find.text('Feedback'), findsOneWidget); // header only
    expect(tester.getSize(find.byType(Scaffold).last), const Size(390, 800));
    expect(find.byTooltip('Close search'), findsOneWidget);
    await tester.tap(find.byTooltip('Close search'));
    await tester.pumpAndSettle();
    expect(h.closed, isTrue);
    expect(h.result, isNull);
  });

  testWidgets('narrow: a row can be chosen', (tester) async {
    final h = _Harness();
    await h.open(tester, size: const Size(390, 800));
    await _type(tester, 'toast');
    await tester.tap(find.text('Toast'));
    await tester.pumpAndSettle();
    expect(h.result, 'toast');
  });

  testWidgets('announces the number of results and the selected row', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _Harness().open(tester);
    await _type(tester, 'toast');
    final n = searchPages('toast', showcasePages).length;
    expect(find.bySemanticsLabel('$n results'), findsOneWidget);

    await _type(tester, 'qqqzzz');
    expect(find.bySemanticsLabel('No results'), findsOneWidget);

    await _type(tester, 'field');
    final first = tester.getSemantics(find.text('Date field'));
    expect(first.flagsCollection.isButton, isTrue);
    expect(first.flagsCollection.isSelected, Tristate.isTrue);
    final second = tester.getSemantics(find.text('Decimal field'));
    expect(second.flagsCollection.isButton, isTrue);
    expect(second.flagsCollection.isSelected, Tristate.isFalse);
    semantics.dispose();
  });

  testWidgets('with reduced motion it opens without animating', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: D3AppTheme.light(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showShowcaseSearch(context),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pump();
    expect(find.byType(TextField), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(ScaleTransition),
        matching: find.byType(D3SearchBar),
      ),
      findsNothing,
    );
  });
}
