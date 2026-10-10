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

  testWidgets('sizeToContent opens at the content height, not the snap point', (
    tester,
  ) async {
    final fixed = await _sheetHeight(
      tester,
      style: const D3BottomSheetStyle(),
      contentHeight: 120,
    );
    await tester.pumpWidget(const SizedBox());
    final fitted = await _sheetHeight(
      tester,
      style: const D3BottomSheetStyle(sizeToContent: true),
      contentHeight: 120,
    );

    // 1000 logical px tall (half of 1000dp-high test screen) vs ~ content
    // plus the 68dp header.
    expect(fitted, lessThan(fixed));
    expect(fitted, closeTo(120 + 68, 12));
  });

  testWidgets('sizeToContent never exceeds the largest snap point', (
    tester,
  ) async {
    final fitted = await _sheetHeight(
      tester,
      style: const D3BottomSheetStyle(sizeToContent: true),
      contentHeight: 5000,
      snapPoints: const [D3SnapPoint.half, D3SnapPoint(0.8)],
    );
    expect(fitted, closeTo(1000 * 0.8, 12));
  });
}

Future<double> _sheetHeight(
  WidgetTester tester, {
  required D3BottomSheetStyle style,
  required double contentHeight,
  List<D3SnapPoint> snapPoints = const [D3SnapPoint.half, D3SnapPoint.expanded],
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
              title: 'T',
              style: style,
              snapPoints: snapPoints,
              child: SingleChildScrollView(
                child: SizedBox(height: contentHeight, child: const Text('X')),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return tester.getSize(find.byType(DraggableScrollableSheet)).height;
}
