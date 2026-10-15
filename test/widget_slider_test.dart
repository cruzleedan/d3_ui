import 'package:d3_ui/d3_ui.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

class _Host extends StatefulWidget {
  const _Host({
    this.initial = 0.5,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.enabled = true,
    this.onEnd,
    this.onChange,
    this.label,
    this.showValue = false,
  });

  final double initial, min, max;
  final int? divisions;
  final bool enabled, showValue;
  final String? label;
  final ValueChanged<double>? onEnd, onChange;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late double v = widget.initial;

  @override
  Widget build(BuildContext context) => D3Slider(
    value: v,
    min: widget.min,
    max: widget.max,
    divisions: widget.divisions,
    enabled: widget.enabled,
    label: widget.label,
    showValue: widget.showValue,
    onChanged: (x) {
      widget.onChange?.call(x);
      setState(() => v = x);
    },
    onChangeEnd: widget.onEnd,
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
    child: Scaffold(
      body: Center(child: SizedBox(width: 348, child: child)),
    ),
  ),
);

// Track runs from x+24 to x+324 for a 348dp wide slider.
double _valueOf(WidgetTester tester) =>
    tester.state<_HostState>(find.byType(_Host)).v;

void main() {
  testWidgets('drag area is at least 48dp tall and spans the width', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const _Host()));
    final size = tester.getSize(
      find
          .descendant(
            of: find.byType(D3Slider),
            matching: find.byType(GestureDetector),
          )
          .first,
    );
    expect(size.height, greaterThanOrEqualTo(48));
    expect(size.width, 348);
  });

  testWidgets('dragging sets the right fraction and ends with onChangeEnd', (
    tester,
  ) async {
    double? ended;
    await tester.pumpWidget(_wrap(_Host(initial: 0, onEnd: (v) => ended = v)));
    final left = tester.getTopLeft(find.byType(D3Slider)).dx;
    // Thumb centre at left+24; drag to 75% of the 300dp track.
    await tester.dragFrom(Offset(left + 24, 300), const Offset(225, 0));
    await tester.pumpAndSettle();
    expect(_valueOf(tester), closeTo(0.75, 0.02));
    expect(ended, closeTo(0.75, 0.02));
  });

  testWidgets('tapping the track jumps there', (tester) async {
    double? ended;
    await tester.pumpWidget(_wrap(_Host(onEnd: (v) => ended = v)));
    final c = tester.getCenter(find.byType(D3Slider));
    await tester.tapAt(Offset(c.dx + 75, c.dy));
    await tester.pumpAndSettle();
    expect(_valueOf(tester), closeTo(0.75, 0.01));
    expect(ended, isNotNull);
  });

  testWidgets('values stay within min and max when dragged past the ends', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const _Host(min: 10, max: 20, initial: 15)));
    await tester.drag(find.byType(D3Slider), const Offset(2000, 0));
    await tester.pumpAndSettle();
    expect(_valueOf(tester), 20);
    await tester.drag(find.byType(D3Slider), const Offset(-4000, 0));
    await tester.pumpAndSettle();
    expect(_valueOf(tester), 10);
  });

  testWidgets('divisions snap and tick', (tester) async {
    final ticks = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'HapticFeedback.vibrate') ticks.add(call);
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    final seen = <double>[];
    await tester.pumpWidget(
      _wrap(_Host(initial: 0, divisions: 4, onChange: seen.add)),
    );
    final left = tester.getTopLeft(find.byType(D3Slider)).dx;
    // 60% of the track is nearest the 0.5 division.
    await tester.dragFrom(Offset(left + 24, 300), const Offset(180, 0));
    await tester.pumpAndSettle();
    expect(_valueOf(tester), 0.5);
    expect(seen.every((v) => [0, .25, .5, .75, 1].contains(v)), isTrue);
    expect(ticks, isNotEmpty);
  });

  testWidgets('semantics increase and decrease', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _wrap(
        const _Host(
          initial: 2,
          min: 0,
          max: 4,
          divisions: 4,
          label: 'Size',
          showValue: true,
        ),
      ),
    );
    final finder = find.semantics.byLabel('Size');
    final node = finder.evaluate().single;
    expect(node.label, 'Size');
    expect(node.value, '2');
    expect(node.increasedValue, '3');
    expect(node.decreasedValue, '1');
    expect(
      node,
      matchesSemantics(
        hasIncreaseAction: true,
        hasDecreaseAction: true,
        isSlider: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        label: 'Size',
        value: '2',
        increasedValue: '3',
        decreasedValue: '1',
      ),
    );

    tester.semantics.increase(finder);
    await tester.pumpAndSettle();
    expect(_valueOf(tester), 3);
    tester.semantics.decrease(finder);
    await tester.pump();
    tester.semantics.decrease(finder);
    await tester.pumpAndSettle();
    expect(_valueOf(tester), 1);
    handle.dispose();
  });

  testWidgets('arrow keys, Home and End', (tester) async {
    await tester.pumpWidget(
      _wrap(const _Host(initial: 2, max: 4, divisions: 4)),
    );
    await tester.tap(find.byType(D3Slider)); // focuses; centre is 2
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(_valueOf(tester), 3);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    expect(_valueOf(tester), 1);
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pumpAndSettle();
    expect(_valueOf(tester), 4);
    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pumpAndSettle();
    expect(_valueOf(tester), 0);
  });

  testWidgets('disabled ignores drag, keys and semantics actions', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_wrap(const _Host(enabled: false, label: 'Vol')));
    await tester.drag(
      find.byType(D3Slider),
      const Offset(100, 0),
      warnIfMissed: false,
    );
    await tester.tap(find.byType(D3Slider), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(_valueOf(tester), 0.5);
    final node = tester.getSemantics(find.byType(D3Slider));
    expect(
      node.getSemanticsData().hasAction(SemanticsAction.increase),
      isFalse,
    );
    expect(
      node.getSemanticsData().hasAction(SemanticsAction.decrease),
      isFalse,
    );
    handle.dispose();
  });

  testWidgets('bubble shows while dragging, but not under reduced motion', (
    tester,
  ) async {
    Future<double> bubbleOpacity({required bool reduced}) async {
      await tester.pumpWidget(_wrap(const _Host(), reduced: reduced));
      final g = await tester.startGesture(
        tester.getCenter(find.byType(D3Slider)),
      );
      await g.moveBy(const Offset(30, 0));
      await tester.pump(const Duration(milliseconds: 300));
      final o = tester.widgetList<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      final r = o.isEmpty ? -1.0 : o.first.opacity;
      await g.up();
      await tester.pumpAndSettle();
      return r;
    }

    expect(await bubbleOpacity(reduced: false), 1.0);
    expect(await bubbleOpacity(reduced: true), -1.0);
  });

  testWidgets('text scale 1.5 does not overflow', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const _Host(
          label: 'A long slider label that must wrap on a narrow screen',
          showValue: true,
          divisions: 10,
        ),
        scale: 1.5,
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  for (final dark in [false, true]) {
    testWidgets(
      'thumb and track have 3:1 contrast (${dark ? 'dark' : 'light'})',
      (tester) async {
        await tester.pumpWidget(_wrap(const _Host(divisions: 5), dark: dark));
        await tester.pumpAndSettle();
        final p =
            tester
                    .widgetList<CustomPaint>(
                      find.descendant(
                        of: find.byType(D3Slider),
                        matching: find.byType(CustomPaint),
                      ),
                    )
                    .map((c) => c.painter)
                    .firstWhere((p) => p is D3SliderPainter)
                as D3SliderPainter;
        expect(d3ContrastRatio(p.fill, p.surface), greaterThanOrEqualTo(3));
        expect(d3ContrastRatio(p.inactive, p.surface), greaterThanOrEqualTo(3));
      },
    );
  }
}
