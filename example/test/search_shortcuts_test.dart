import 'package:d3_ui_example/showcase/search/search_shortcuts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Future<({FocusNode outside, TextEditingController text, List<int> calls})>
    _pump(WidgetTester tester) async {
  final calls = <int>[];
  final outside = FocusNode();
  final text = TextEditingController();
  addTearDown(outside.dispose);
  addTearDown(text.dispose);
  await tester.pumpWidget(
    MaterialApp(
      home: SearchShortcuts(
        onSearch: () => calls.add(calls.length),
        child: Scaffold(
          body: Column(
            children: [
              Focus(
                focusNode: outside,
                child: const SizedBox(width: 50, height: 50),
              ),
              TextField(controller: text),
            ],
          ),
        ),
      ),
    ),
  );
  return (outside: outside, text: text, calls: calls);
}

void main() {
  testWidgets('Ctrl+K fires', (tester) async {
    final h = await _pump(tester);
    h.outside.requestFocus();
    await tester.pump();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    expect(h.calls, hasLength(1));
  });

  testWidgets('Cmd+K fires', (tester) async {
    final h = await _pump(tester);
    h.outside.requestFocus();
    await tester.pump();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
    expect(h.calls, hasLength(1));
  });

  testWidgets('Ctrl+K also fires inside a text field', (tester) async {
    final h = await _pump(tester);
    await tester.tap(find.byType(TextField));
    await tester.pump();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    expect(h.calls, hasLength(1));
  });

  testWidgets('"/" fires when focus is elsewhere', (tester) async {
    final h = await _pump(tester);
    h.outside.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.slash);
    expect(h.calls, hasLength(1));
  });

  testWidgets('"/" fires when nothing has focus', (tester) async {
    final h = await _pump(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.slash);
    expect(h.calls, hasLength(1));
  });

  testWidgets('"/" does not fire in a text field', (tester) async {
    final h = await _pump(tester);
    await tester.tap(find.byType(TextField));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.slash);
    expect(h.calls, isEmpty);
  });

  testWidgets('typing "/" in a text field still enters the character', (
    tester,
  ) async {
    final h = await _pump(tester);
    await tester.tap(find.byType(TextField));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'a/b');
    expect(h.text.text, 'a/b');
    expect(h.calls, isEmpty);
  });

  testWidgets('K alone does nothing', (tester) async {
    final h = await _pump(tester);
    h.outside.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
    expect(h.calls, isEmpty);
  });
}
