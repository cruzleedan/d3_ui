import 'package:d3_ui/d3_ui.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

class _Host extends StatefulWidget {
  const _Host({
    this.initial = 1,
    this.min = 0,
    this.max,
    this.step = 1,
    this.enabled = true,
    this.compact = false,
  });

  final int initial, min, step;
  final int? max;
  final bool enabled, compact;
  final String label = 'Quantity';

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late int v = widget.initial;

  @override
  Widget build(BuildContext context) => D3QuantityStepper(
    value: v,
    min: widget.min,
    max: widget.max,
    step: widget.step,
    enabled: widget.enabled,
    compact: widget.compact,
    label: widget.label,
    onChanged: (x) => setState(() => v = x),
  );
}

Widget _wrap(
  Widget child, {
  bool dark = false,
  bool reduced = false,
  double scale = 1,
}) => MaterialApp(
  theme: dark ? D3AppTheme.dark() : D3AppTheme.light(),
  home: MediaQuery(
    data: MediaQueryData(
      disableAnimations: reduced,
      textScaler: TextScaler.linear(scale),
    ),
    child: Scaffold(body: Center(child: child)),
  ),
);

int _value(WidgetTester t) => t.state<_HostState>(find.byType(_Host)).v;
Finder get _minus => find.byIcon(Icons.remove_rounded);
Finder get _plus => find.byIcon(Icons.add_rounded);

Finder _hit(Finder icon) =>
    find.ancestor(of: icon, matching: find.byType(InkResponse)).first;

/// Pumps [total] in frame-sized steps so the parent rebuilds between ticks.
Future<void> _run(WidgetTester tester, Duration total) async {
  for (
    var t = Duration.zero;
    t < total;
    t += const Duration(milliseconds: 16)
  ) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

void main() {
  testWidgets('taps change the value by step', (tester) async {
    await tester.pumpWidget(_wrap(const _Host(initial: 5, step: 5)));
    await tester.tap(_plus);
    await tester.pumpAndSettle();
    expect(_value(tester), 10);
    await tester.tap(_minus);
    await tester.pump();
    await tester.tap(_minus);
    await tester.pumpAndSettle();
    expect(_value(tester), 0);
  });

  testWidgets('respects min and max, and dims the buttons', (tester) async {
    await tester.pumpWidget(_wrap(const _Host(initial: 1, min: 1, max: 2)));
    await tester.tap(_minus);
    await tester.pumpAndSettle();
    expect(_value(tester), 1);
    await tester.tap(_plus);
    await tester.pump();
    await tester.tap(_plus);
    await tester.pumpAndSettle();
    expect(_value(tester), 2);
    // Plus is now at the limit, so its icon is dimmed.
    final opacity = tester.widget<Opacity>(
      find.ancestor(of: _plus, matching: find.byType(Opacity)).first,
    );
    expect(opacity.opacity, lessThan(1));
  });

  testWidgets('step that overshoots max clamps to max', (tester) async {
    await tester.pumpWidget(_wrap(const _Host(initial: 8, max: 10, step: 5)));
    await tester.tap(_plus);
    await tester.pumpAndSettle();
    expect(_value(tester), 10);
  });

  testWidgets('press and hold repeats and stops at the limit', (tester) async {
    await tester.pumpWidget(_wrap(const _Host(initial: 0, max: 30)));
    final g = await tester.startGesture(tester.getCenter(_plus));
    await _run(tester, const Duration(milliseconds: 300));
    expect(_value(tester), 0); // before the hold delay
    await _run(tester, const Duration(milliseconds: 200));
    final early = _value(tester);
    expect(early, greaterThanOrEqualTo(1));
    await _run(tester, const Duration(milliseconds: 600));
    final later = _value(tester);
    expect(later, greaterThan(early + 1));
    await _run(tester, const Duration(seconds: 5));
    expect(_value(tester), 30);
    await g.up();
    await tester.pumpAndSettle();
    expect(_value(tester), 30); // release does not add an extra step
  });

  testWidgets('releasing a hold does not add a tap step', (tester) async {
    await tester.pumpWidget(_wrap(const _Host(initial: 0, max: 100)));
    final g = await tester.startGesture(tester.getCenter(_plus));
    await tester.pump(const Duration(milliseconds: 420));
    final held = _value(tester);
    await g.up();
    await tester.pumpAndSettle();
    expect(_value(tester), held);
    await tester.pump(const Duration(seconds: 2));
    expect(_value(tester), held); // timer stopped
  });

  testWidgets('each button hit area is at least 48x48', (tester) async {
    for (final compact in [false, true]) {
      await tester.pumpWidget(_wrap(_Host(compact: compact)));
      for (final icon in [_minus, _plus]) {
        final size = tester.getSize(_hit(icon));
        expect(size.width, greaterThanOrEqualTo(48));
        expect(size.height, greaterThanOrEqualTo(48));
      }
    }
  });

  testWidgets('buttons carry ink', (tester) async {
    await tester.pumpWidget(_wrap(const _Host()));
    expect(_hit(_plus), findsOneWidget);
    final g = await tester.startGesture(tester.getCenter(_plus));
    await tester.pump(const Duration(milliseconds: 100));
    await g.up();
    await tester.pumpAndSettle();
  });

  testWidgets('semantics: adjustable value with actions', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_wrap(const _Host(initial: 1, min: 1, max: 3)));
    final finder = find.semantics.byLabel('Quantity');
    var node = finder.evaluate().single;
    expect(node.label, 'Quantity');
    expect(node.value, '1');
    expect(node.increasedValue, '2');
    expect(
      node.getSemanticsData().hasAction(SemanticsAction.decrease),
      isFalse,
    );
    tester.semantics.increase(finder);
    await tester.pumpAndSettle();
    expect(_value(tester), 2);
    tester.semantics.decrease(finder);
    await tester.pumpAndSettle();
    expect(_value(tester), 1);
    // The dimmed minus button is still announced, as disabled.
    expect(find.semantics.byLabel('Decrease'), findsOneWidget);
    node = find.semantics.byLabel('Decrease').evaluate().single;
    expect(node, isSemantics(hasEnabledState: true, isEnabled: false));
    handle.dispose();
  });

  testWidgets('disabled ignores taps', (tester) async {
    await tester.pumpWidget(_wrap(const _Host(enabled: false)));
    await tester.tap(_plus, warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(_value(tester), 1);
  });

  testWidgets('value animates with a slide, and not under reduced motion', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const _Host()));
    await tester.tap(_plus);
    await tester.pump(const Duration(milliseconds: 60));
    expect(find.byType(SlideTransition), findsWidgets);
    expect(find.text('1'), findsOneWidget); // outgoing
    expect(find.text('2'), findsOneWidget); // incoming
    await tester.pumpAndSettle();

    await tester.pumpWidget(_wrap(const _Host(), reduced: true));
    await tester.tap(_plus);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));
    expect(find.text('1'), findsNothing);
  });

  testWidgets('text scale 1.5 does not overflow', (tester) async {
    await tester.pumpWidget(_wrap(const _Host(initial: 1234), scale: 1.5));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  for (final dark in [false, true]) {
    testWidgets('outline has 3:1 contrast (${dark ? 'dark' : 'light'})', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const _Host(), dark: dark));
      await tester.pumpAndSettle();
      final box = tester
          .widgetList<DecoratedBox>(
            find.descendant(
              of: find.byType(D3QuantityStepper),
              matching: find.byType(DecoratedBox),
            ),
          )
          .map((d) => d.decoration)
          .whereType<BoxDecoration>()
          .firstWhere((d) => d.border != null);
      final color = (box.border! as Border).top.color;
      final surface = tester
          .element(find.byType(D3QuantityStepper))
          .d3Colors
          .surface;
      expect(d3ContrastRatio(color, surface), greaterThanOrEqualTo(3));
    });
  }
}
