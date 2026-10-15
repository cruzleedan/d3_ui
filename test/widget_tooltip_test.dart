import 'package:d3_ui/d3_ui.dart';
import 'package:d3_ui/src/components/feedback/d3_tooltip.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Widget _app(
  Widget body, {
  ThemeData? theme,
  Alignment align = Alignment.center,
}) {
  return MaterialApp(
    theme: theme ?? D3AppTheme.light(),
    home: Scaffold(
      body: Align(alignment: align, child: body),
    ),
  );
}

void main() {
  const msg = 'Add to favourites';
  const childKey = Key('child');

  Widget tip({VoidCallback? onTap, Duration? autoHide, String message = msg}) =>
      D3Tooltip(
        message: message,
        autoHide: autoHide,
        child: GestureDetector(
          onTap: onTap,
          child: const SizedBox(
            key: childKey,
            width: 60,
            height: 48,
            child: Icon(Icons.favorite),
          ),
        ),
      );

  testWidgets('long-press shows the message and it autohides', (tester) async {
    await tester.pumpWidget(_app(tip()));
    expect(find.text(msg), findsNothing);
    await tester.longPress(find.byKey(childKey));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(find.text(msg), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text(msg), findsNothing);
  });

  testWidgets('custom autoHide', (tester) async {
    await tester.pumpWidget(_app(tip(autoHide: const Duration(seconds: 1))));
    await tester.longPress(find.byKey(childKey));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1100));
    await tester.pumpAndSettle();
    expect(find.text(msg), findsNothing);
  });

  testWidgets('hover shows after the delay and hides on exit', (tester) async {
    await tester.pumpWidget(_app(tip()));
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    await mouse.moveTo(tester.getCenter(find.byKey(childKey)));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text(msg), findsNothing);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.text(msg), findsOneWidget);
    await mouse.moveTo(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.text(msg), findsNothing);
  });

  testWidgets('keyboard focus shows it, escape hides it', (tester) async {
    await tester.pumpWidget(
      _app(
        const D3Tooltip(
          message: msg,
          child: TextButton(onPressed: _noop, child: Text('Go')),
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    expect(find.text(msg), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text(msg), findsNothing);
  });

  testWidgets('message is in semantics', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_app(tip()));
    expect(tester.getSemantics(find.byKey(childKey)).tooltip, msg);
    handle.dispose();
  });

  testWidgets('child tap still works and long-press does not tap', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(_app(tip(onTap: () => taps++)));
    await tester.tap(find.byKey(childKey));
    await tester.pump();
    expect(taps, 1);
    await tester.longPress(find.byKey(childKey));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(taps, 1);
  });

  testWidgets('tap elsewhere dismisses', (tester) async {
    await tester.pumpWidget(_app(tip(autoHide: const Duration(minutes: 1))));
    await tester.longPress(find.byKey(childKey));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(find.text(msg), findsOneWidget);
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.text(msg), findsNothing);
  });

  testWidgets('scroll dismisses', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: D3AppTheme.light(),
        home: Scaffold(
          body: ListView(
            children: [
              tip(autoHide: const Duration(minutes: 1)),
              const SizedBox(height: 2000),
            ],
          ),
        ),
      ),
    );
    await tester.longPress(find.byKey(childKey));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(find.text(msg), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -100));
    await tester.pumpAndSettle();
    expect(find.text(msg), findsNothing);
  });

  testWidgets('bubble stays on screen at 320x568 corners and wraps', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final long = 'A rather long explanation. ' * 12;
    for (final a in [Alignment.topLeft, Alignment.bottomRight]) {
      await tester.pumpWidget(_app(tip(message: long), align: a));
      await tester.longPress(find.byKey(childKey));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      final rect = tester.getRect(find.text(long));
      expect(rect.left, greaterThanOrEqualTo(0));
      expect(rect.right, lessThanOrEqualTo(320));
      expect(rect.top, greaterThanOrEqualTo(0));
      expect(rect.bottom, lessThanOrEqualTo(568));
      expect(rect.width, lessThanOrEqualTo(280));
      await tester.tapAt(const Offset(160, 300));
      await tester.pumpAndSettle();
    }
  });

  testWidgets('bubble text contrast >= 4.5 in light and dark', (tester) async {
    for (final theme in [D3AppTheme.light(), D3AppTheme.dark()]) {
      await tester.pumpWidget(_app(tip(), theme: theme));
      await tester.longPress(find.byKey(childKey));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      final text = tester.widget<Text>(find.text(msg));
      final material = tester.widget<Material>(
        find
            .ancestor(of: find.text(msg), matching: find.byType(Material))
            .first,
      );
      expect(
        d3ContrastRatio(text.style!.color!, material.color!),
        greaterThanOrEqualTo(4.5),
      );
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
    }
  });

  group('D3InfoTip', () {
    testWidgets('toggles on tap and closes on outside tap', (tester) async {
      await tester.pumpWidget(
        _app(const D3InfoTip(title: 'Name', message: 'Shown to others.')),
      );
      expect(find.text('Shown to others.'), findsNothing);
      await tester.tap(find.byType(D3InfoTip));
      await tester.pumpAndSettle();
      expect(find.text('Shown to others.'), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);
      await tester.tap(find.byType(D3InfoTip));
      await tester.pumpAndSettle();
      expect(find.text('Shown to others.'), findsNothing);
      await tester.tap(find.byType(D3InfoTip));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(find.text('Shown to others.'), findsNothing);
    });

    testWidgets('48dp target and semantics', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_app(const D3InfoTip(message: 'Hello')));
      final size = tester.getSize(find.byType(InkResponse));
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
      expect(find.bySemanticsLabel('More information'), findsOneWidget);
      handle.dispose();
    });
  });
}

void _noop() {}
