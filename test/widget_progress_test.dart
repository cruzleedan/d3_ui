import 'package:d3_ui/d3_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Widget _wrap(
  Widget child, {
  bool dark = false,
  bool reduced = false,
  double scale = 1,
  double width = 300,
}) => MaterialApp(
  theme: dark ? D3AppTheme.dark() : D3AppTheme.light(),
  home: MediaQuery(
    data: MediaQueryData(
      disableAnimations: reduced,
      textScaler: TextScaler.linear(scale),
    ),
    child: Scaffold(
      body: Center(
        child: SizedBox(width: width, child: child),
      ),
    ),
  ),
);

dynamic _painter(WidgetTester tester, Type within) => tester
    .widgetList<CustomPaint>(
      find.descendant(
        of: find.byType(within),
        matching: find.byType(CustomPaint),
      ),
    )
    .map((c) => c.painter)
    .firstWhere((p) => p != null);

void main() {
  testWidgets('bar exposes its percentage and label to semantics', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _wrap(const D3ProgressBar(value: 0.42, label: 'Upload', showValue: true)),
    );
    await tester.pumpAndSettle();
    final node = tester.getSemantics(find.byType(D3ProgressBar));
    expect(node.value, '42%');
    expect(node.label, 'Upload');
    expect(find.text('42%'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('ring exposes its percentage; indeterminate has no value', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _wrap(const D3ProgressRing(value: 0.5, showValue: true, size: 80)),
    );
    await tester.pumpAndSettle();
    expect(tester.getSemantics(find.byType(D3ProgressRing)).value, '50%');
    await tester.pumpWidget(_wrap(const D3ProgressRing(value: null)));
    expect(tester.getSemantics(find.byType(D3ProgressRing)).value, '');
    handle.dispose();
  });

  testWidgets('determinate bar animates to a new value', (tester) async {
    await tester.pumpWidget(_wrap(const D3ProgressBar(value: 0)));
    await tester.pumpWidget(_wrap(const D3ProgressBar(value: 1)));
    await tester.pump(const Duration(milliseconds: 100));
    final mid = _painter(tester, D3ProgressBar).fraction as double;
    expect(mid, greaterThan(0));
    expect(mid, lessThan(1));
    await tester.pumpAndSettle();
    expect(_painter(tester, D3ProgressBar).fraction, 1.0);
  });

  testWidgets('reduced motion jumps straight to the value', (tester) async {
    await tester.pumpWidget(
      _wrap(const D3ProgressBar(value: 0), reduced: true),
    );
    await tester.pumpWidget(
      _wrap(const D3ProgressBar(value: 1), reduced: true),
    );
    await tester.pump();
    expect(_painter(tester, D3ProgressBar).fraction, 1.0);
  });

  testWidgets('indeterminate loops, and is static under reduced motion', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const D3ProgressBar(value: null)));
    final a = _painter(tester, D3ProgressBar).phase as double;
    await tester.pump(const Duration(milliseconds: 400));
    final b = _painter(tester, D3ProgressBar).phase as double;
    expect(b, isNot(a));
    expect(tester.hasRunningAnimations, isTrue);

    await tester.pumpWidget(
      _wrap(const D3ProgressBar(value: null), reduced: true),
    );
    await tester.pump(const Duration(milliseconds: 400));
    final c = _painter(tester, D3ProgressBar).phase;
    await tester.pump(const Duration(milliseconds: 400));
    expect(_painter(tester, D3ProgressBar).phase, c);
    await tester.pumpAndSettle();
  });

  testWidgets('ring rotates, and is static under reduced motion', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const D3ProgressRing(value: null)));
    final a = _painter(tester, D3ProgressRing).rotation as double;
    await tester.pump(const Duration(milliseconds: 300));
    expect(_painter(tester, D3ProgressRing).rotation, isNot(a));

    await tester.pumpWidget(
      _wrap(const D3ProgressRing(value: null), reduced: true),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(_painter(tester, D3ProgressRing).rotation, 0.0);
    await tester.pumpAndSettle();
  });

  testWidgets('text scale 1.5 does not overflow', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            D3ProgressBar(
              value: 0.3,
              label: 'A fairly long progress label that has to wrap',
              showValue: true,
            ),
            D3ProgressRing(value: 0.3, showValue: true, label: 'Ring label'),
          ],
        ),
        scale: 1.5,
        width: 200,
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  for (final dark in [false, true]) {
    for (final variant in D3ProgressVariant.values) {
      testWidgets('fill has 3:1 contrast (${dark ? 'dark' : 'light'}, '
          '${variant.name})', (tester) async {
        await tester.pumpWidget(
          _wrap(D3ProgressBar(value: 0.5, variant: variant), dark: dark),
        );
        await tester.pumpAndSettle();
        final p = _painter(tester, D3ProgressBar);
        final surface = tester
            .element(find.byType(D3ProgressBar))
            .d3Colors
            .surface;
        expect(
          d3ContrastRatio(p.fill as Color, surface),
          greaterThanOrEqualTo(3),
        );
        expect(
          d3ContrastRatio(p.fill as Color, p.track as Color),
          greaterThanOrEqualTo(3),
        );
      });
    }
  }
}
