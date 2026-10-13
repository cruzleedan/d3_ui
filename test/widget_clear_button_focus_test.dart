import 'package:d3_ui/d3_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// On desktop and the web, a pointer press outside the text unfocuses the
/// field. The clear button is inside the field's box but outside the editable
/// text, so without a TextFieldTapRegion it unfocused the field on press, the
/// button (shown only while focused) disappeared, and the release hit nothing.
void main() {
  for (final platform in [TargetPlatform.android, TargetPlatform.macOS]) {
    for (final kind in [PointerDeviceKind.touch, PointerDeviceKind.mouse]) {
      testWidgets('clear empties the field and keeps focus '
          '($platform, ${kind.name})', (tester) async {
        debugDefaultTargetPlatformOverride = platform;
        final controller = TextEditingController(text: 'hello');
        addTearDown(controller.dispose);
        await tester.pumpWidget(
          MaterialApp(
            theme: D3AppTheme.light(),
            home: Scaffold(
              body: Center(
                child: D3TextField(label: 'Name', controller: controller),
              ),
            ),
          ),
        );
        await tester.tap(find.byType(TextField));
        await tester.pumpAndSettle();

        final clear = find.byIcon(Icons.close_rounded);
        expect(clear, findsOneWidget);
        final gesture = await tester.startGesture(
          tester.getCenter(clear),
          kind: kind,
        );
        await tester.pump();
        await gesture.up();
        await tester.pumpAndSettle();

        final field = tester.widget<EditableText>(find.byType(EditableText));
        final text = controller.text;
        final focused = field.focusNode.hasFocus;
        debugDefaultTargetPlatformOverride = null;
        expect(text, isEmpty);
        expect(focused, isTrue);
      });
    }
  }

  testWidgets('the search bar clear button keeps the field focused', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    final controller = TextEditingController(text: 'hello');
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: D3AppTheme.light(),
        home: Scaffold(body: D3SearchBar(controller: controller)),
      ),
    );
    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    final gesture = await tester.startGesture(
      tester.getCenter(find.byIcon(Icons.close_rounded)),
      kind: PointerDeviceKind.mouse,
    );
    await tester.pump();
    final stillFocused = tester
        .widget<EditableText>(find.byType(EditableText))
        .focusNode
        .hasFocus;
    await gesture.up();
    await tester.pumpAndSettle();
    final text = controller.text;
    final focused = tester
        .widget<EditableText>(find.byType(EditableText))
        .focusNode
        .hasFocus;
    debugDefaultTargetPlatformOverride = null;
    expect(stillFocused, isTrue, reason: 'focus kept while pressing');
    expect(text, isEmpty);
    expect(focused, isTrue);
  });
}
