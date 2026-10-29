import 'package:d3_ui/d3_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Widget host(bool value, ValueChanged<bool> onChanged, {double scale = 1}) =>
      MaterialApp(
        theme: D3AppTheme.light(),
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(scale)),
          child: Scaffold(
            body: Center(
              child: D3SegmentSwitch<bool>(
                semanticsLabel: 'Snore at 8:14 PM',
                first: const D3Segment(value: true, label: 'Snore'),
                second: const D3Segment(value: false, label: 'Not snore'),
                value: value,
                onChanged: onChanged,
              ),
            ),
          ),
        ),
      );

  testWidgets('shows both labels and reports the other option', (t) async {
    bool? got;
    await t.pumpWidget(host(true, (v) => got = v));
    expect(find.text('Snore'), findsOneWidget);
    expect(find.text('Not snore'), findsOneWidget);
    await t.tap(find.text('Not snore'));
    expect(got, isFalse);
  });

  testWidgets('tapping the chosen option does nothing', (t) async {
    var calls = 0;
    await t.pumpWidget(host(true, (_) => calls++));
    await t.tap(find.text('Snore'));
    expect(calls, 0);
  });

  testWidgets('each half is a 48 dp touch target', (t) async {
    await t.pumpWidget(host(true, (_) {}));
    for (final label in ['Snore', 'Not snore']) {
      final box = find
          .ancestor(of: find.text(label), matching: find.byType(GestureDetector))
          .first;
      final size = t.getSize(box);
      expect(size.height, greaterThanOrEqualTo(48), reason: label);
      expect(size.width, greaterThanOrEqualTo(48), reason: label);
    }
  });

  testWidgets('screen readers get a selected button per option', (t) async {
    final handle = t.ensureSemantics();
    await t.pumpWidget(host(false, (_) {}));
    expect(
      t.getSemantics(find.bySemanticsLabel('Not snore')),
      matchesSemantics(
        label: 'Not snore',
        isButton: true,
        isSelected: true,
        isInMutuallyExclusiveGroup: true,
        hasTapAction: false,
        hasSelectedState: true,
        hasEnabledState: false,
        isFocusable: false,
      ),
    );
    expect(find.bySemanticsLabel('Snore'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('holds at text scale 2.0 without overflow', (t) async {
    await t.pumpWidget(host(true, (_) {}, scale: 2));
    expect(t.takeException(), isNull);
  });
}
