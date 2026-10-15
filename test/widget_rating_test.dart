import 'package:d3_ui/d3_ui.dart';
import 'package:d3_ui/src/components/inputs/d3_rating.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

class _Host extends StatefulWidget {
  const _Host({
    this.initial = 3,
    this.allowHalf = false,
    this.allowClear = false,
    this.readOnly = false,
  });

  final double initial;
  final bool allowHalf, allowClear, readOnly;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late double v = widget.initial;

  @override
  Widget build(BuildContext context) => D3Rating(
    value: v,
    label: 'Rating',
    allowHalf: widget.allowHalf,
    allowClear: widget.allowClear,
    onChanged: widget.readOnly
        ? null
        : (x) {
            setState(() => v = x);
          },
  );
}

Widget _wrap(Widget child, {bool dark = false}) => MaterialApp(
  theme: dark ? D3AppTheme.dark() : D3AppTheme.light(),
  home: Scaffold(body: Center(child: child)),
);

double _value(WidgetTester t) => t.state<_HostState>(find.byType(_Host)).v;

void main() {
  testWidgets('display renders full, half and empty stars', (tester) async {
    await tester.pumpWidget(_wrap(const D3Rating(value: 3.5)));
    expect(find.byIcon(Icons.star_rounded), findsNWidgets(3));
    expect(find.byIcon(Icons.star_half_rounded), findsOneWidget);
    expect(find.byIcon(Icons.star_outline_rounded), findsNWidgets(2));
  });

  testWidgets('tap sets the value', (tester) async {
    await tester.pumpWidget(_wrap(const _Host()));
    final stars = find.byIcon(Icons.star_rounded);
    await tester.tap(find.byIcon(Icons.star_outline_rounded).last);
    await tester.pumpAndSettle();
    expect(_value(tester), 5);
    await tester.tap(stars.first);
    await tester.pumpAndSettle();
    expect(_value(tester), 1);
  });

  testWidgets('allowHalf taps the left half', (tester) async {
    await tester.pumpWidget(_wrap(const _Host(allowHalf: true)));
    final c = tester.getCenter(find.byIcon(Icons.star_outline_rounded).first);
    await tester.tapAt(c - const Offset(10, 0));
    await tester.pumpAndSettle();
    expect(_value(tester), 3.5);
  });

  testWidgets('tapping the current value keeps it unless allowClear', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const _Host()));
    await tester.tap(find.byIcon(Icons.star_rounded).last);
    await tester.pumpAndSettle();
    expect(_value(tester), 3);
    await tester.pumpWidget(_wrap(const _Host(allowClear: true)));
    await tester.tap(find.byIcon(Icons.star_rounded).last);
    await tester.pumpAndSettle();
    expect(_value(tester), 0);
  });

  testWidgets('dragging across stars scrubs the value', (tester) async {
    await tester.pumpWidget(_wrap(const _Host(initial: 1)));
    final first = tester.getCenter(find.byIcon(Icons.star_rounded).first);
    await tester.dragFrom(first, const Offset(48 * 3, 0));
    await tester.pumpAndSettle();
    expect(_value(tester), 4);
  });

  testWidgets('read-only ignores input', (tester) async {
    await tester.pumpWidget(_wrap(const _Host(readOnly: true)));
    await tester.tap(find.byIcon(Icons.star_outline_rounded).last);
    await tester.pumpAndSettle();
    expect(_value(tester), 3);
  });

  testWidgets('arrow keys step the value', (tester) async {
    await tester.pumpWidget(_wrap(const _Host()));
    final focus = Focus.of(
      tester.element(find.byIcon(Icons.star_rounded).first),
    );
    focus.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(_value(tester), 4);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    expect(_value(tester), 2);
  });

  testWidgets('semantics expose value and increase/decrease', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_wrap(const _Host()));
    final finder = find.semantics.byLabel('Rating');
    var data = tester.getSemantics(find.byType(D3Rating)).getSemanticsData();
    expect(data.value, '3 of 5 stars');
    expect(data.hasAction(SemanticsAction.increase), isTrue);
    expect(data.hasAction(SemanticsAction.decrease), isTrue);
    tester.semantics.performAction(finder, SemanticsAction.increase);
    await tester.pump();
    expect(_value(tester), 4);
    tester.semantics.performAction(finder, SemanticsAction.decrease);
    await tester.pump();
    expect(_value(tester), 3);
    data = tester.getSemantics(find.byType(D3Rating)).getSemanticsData();
    expect(data.value, '3 of 5 stars');
    handle.dispose();
  });

  testWidgets('read-only has no adjust actions', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_wrap(const _Host(readOnly: true)));
    final data = tester.getSemantics(find.byType(D3Rating)).getSemanticsData();
    expect(data.hasAction(SemanticsAction.increase), isFalse);
    handle.dispose();
  });

  testWidgets('interactive stars are at least 48dp wide', (tester) async {
    await tester.pumpWidget(_wrap(const _Host()));
    final hits = find.ancestor(
      of: find.byIcon(Icons.star_rounded),
      matching: find.byType(InkResponse),
    );
    for (final e in hits.evaluate()) {
      final size = tester.getSize(find.byWidget(e.widget));
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
    }
    expect(tester.getSize(find.byType(D3Rating)).width, 240);
  });

  for (final dark in [false, true]) {
    testWidgets('filled star has 3:1 contrast (${dark ? 'dark' : 'light'})', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const D3Rating(value: 5), dark: dark));
      final icon = tester.widget<Icon>(find.byIcon(Icons.star_rounded).first);
      final surface = tester
          .element(find.byIcon(Icons.star_rounded).first)
          .d3Colors
          .surface;
      expect(d3ContrastRatio(icon.color!, surface), greaterThanOrEqualTo(3));
    });
  }
}
