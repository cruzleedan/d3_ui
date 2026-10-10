import 'package:d3_ui/d3_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Future<void> _open(
  WidgetTester tester, {
  D3BottomSheetStyle style = const D3BottomSheetStyle(),
  String? title = 'Sheet title',
}) async {
  tester.view.physicalSize = const Size(900, 2000);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: D3AppTheme.light(),
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => D3BottomSheet.show<void>(
              context,
              title: title,
              style: style,
              child: const Text('SHEET BODY'),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

/// The 36×4 drag-handle pill, header or floating.
Finder _handle() => find.byWidgetPredicate(
  (w) =>
      w is Container &&
      w.constraints?.maxWidth == 36 &&
      w.constraints?.maxHeight == 4,
);

void main() {
  testWidgets('default style: title header, close button, handle', (
    tester,
  ) async {
    await _open(tester);

    expect(find.text('Sheet title'), findsOneWidget);
    expect(find.text('SHEET BODY'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(_handle(), findsOneWidget);
  });

  testWidgets('showHeader: false drops the title bar; a floating close button '
      'closes the sheet', (tester) async {
    await _open(
      tester,
      style: const D3BottomSheetStyle(
        showHeader: false,
        floatingCloseButton: true,
      ),
    );

    expect(find.text('Sheet title'), findsNothing);
    expect(find.text('SHEET BODY'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Close'));
    await tester.pumpAndSettle();
    expect(find.text('SHEET BODY'), findsNothing);
  });

  testWidgets('showHeader: false with no close button shows neither', (
    tester,
  ) async {
    await _open(tester, style: const D3BottomSheetStyle(showHeader: false));

    expect(find.bySemanticsLabel('Close'), findsNothing);
    expect(find.text('SHEET BODY'), findsOneWidget);
  });

  testWidgets('backgroundColor and borderRadius are applied', (tester) async {
    const color = Color(0xFF123456);
    await _open(
      tester,
      style: const D3BottomSheetStyle(
        backgroundColor: color,
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
      ),
    );

    final material = tester
        .widgetList<Material>(find.byType(Material))
        .where((m) => m.color == color);
    expect(material, isNotEmpty);
    final clip = tester.widget<ClipRRect>(
      find
          .ancestor(
            of: find.byType(CustomScrollView),
            matching: find.byType(ClipRRect),
          )
          .first,
    );
    expect(
      clip.borderRadius,
      const BorderRadius.vertical(top: Radius.circular(4)),
    );
  });

  testWidgets('showDragHandle: false removes the handle', (tester) async {
    await _open(tester, style: const D3BottomSheetStyle(showDragHandle: false));
    expect(_handle(), findsNothing);
  });

  testWidgets('a headerless sheet still shows a floating handle', (
    tester,
  ) async {
    await _open(tester, style: const D3BottomSheetStyle(showHeader: false));
    expect(_handle(), findsOneWidget);
  });
}
