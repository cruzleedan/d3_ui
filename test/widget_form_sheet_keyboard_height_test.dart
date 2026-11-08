import 'package:d3_ui/d3_ui.dart';
import 'package:flutter/widgets.dart' show FakeViewPadding;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

// Root WORK-0099: a form taller than the space left above the keyboard used to
// be pushed up until its header sat under the status bar, where taps do not
// reach it. The sheet must stay inside the safe area and keep Save tappable.

void main() {
  Future<void> open(
    WidgetTester tester, {
    required double keyboard,
    required double formHeight,
    required VoidCallback onSave,
  }) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 48);
    tester.view.viewInsets = FakeViewPadding(bottom: keyboard);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: D3AppTheme.light(),
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => D3FormSheet.show<void>(
                context,
                title: 'New Project',
                primaryAction: D3FormSheetAction(
                  label: 'Save',
                  onPressed: onSave,
                ),
                child: SizedBox(height: formHeight, child: const TextField()),
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

  testWidgets('a tall form with the keyboard open stays below the status bar', (
    tester,
  ) async {
    var saved = 0;
    await open(tester, keyboard: 360, formHeight: 1200, onSave: () => saved++);

    final header = tester.getRect(find.text('New Project'));
    expect(
      header.top,
      greaterThanOrEqualTo(48),
      reason: 'the header must not sit inside the 48 px top inset',
    );
    // The form's own field is inside the space above the keyboard.
    final field = tester.getRect(find.byType(TextField));
    expect(field.top, greaterThanOrEqualTo(48));
    expect(field.top, lessThan(900 - 360));

    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(saved, 1, reason: 'Save is reachable with the keyboard open');
  });

  testWidgets('a short form is unchanged by the cap', (tester) async {
    await open(tester, keyboard: 0, formHeight: 100, onSave: () {});
    // Sized to its content and resting at the bottom, not stretched to the top.
    expect(
      tester.getRect(find.text('New Project')).top,
      greaterThan(600),
      reason: 'a 100 px form leaves the sheet near the bottom',
    );
  });
}
