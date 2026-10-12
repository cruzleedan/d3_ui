import 'package:d3_ui/d3_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Future<void> _open(WidgetTester tester) async {
  tester.view.physicalSize = const Size(900, 1600);
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
              title: 'Sheet title',
              snapPoints: const [D3SnapPoint(0.6)],
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

/// Drags downwards from the title row with the given kind of pointer and
/// returns how far the title moved.
Future<double> _dragTitle(WidgetTester tester, PointerDeviceKind kind) async {
  await _open(tester);
  final before = tester.getTopLeft(find.text('Sheet title')).dy;
  final gesture = await tester.startGesture(
    tester.getCenter(find.text('Sheet title')),
    kind: kind,
  );
  await gesture.moveBy(const Offset(0, 40));
  await gesture.moveBy(const Offset(0, 60));
  await tester.pump();
  final during = tester.getTopLeft(find.text('Sheet title')).dy;
  await gesture.up();
  await tester.pumpAndSettle();
  return during - before;
}

void main() {
  testWidgets('a touch drag moves the sheet', (tester) async {
    expect(await _dragTitle(tester, PointerDeviceKind.touch), greaterThan(20));
  });

  testWidgets('a mouse drag moves the sheet too', (tester) async {
    expect(await _dragTitle(tester, PointerDeviceKind.mouse), greaterThan(20));
  });
}
