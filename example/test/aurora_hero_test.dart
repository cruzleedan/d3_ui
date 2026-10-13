import 'dart:io';

import 'package:d3_ui/d3_ui.dart';
import 'package:d3_ui_example/showcase/aurora_hero.dart';
import 'package:d3_ui_example/showcase/brands.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  late Map<String, BrandThemes> themes;

  setUpAll(() async {
    themes = await loadBrandThemes(load: (a) => File(a).readAsString());
  });

  group('contrast over the aurora', () {
    // The shader blends the surface towards one tint by at most auroraStrength,
    // so the worst background is that blend for the palest tint.
    for (final dark in [false, true]) {
      test('text keeps 4.5:1 in every brand (${dark ? 'dark' : 'light'})', () {
        for (final brand in showcaseBrands) {
          final theme = dark ? themes[brand.id]!.dark : themes[brand.id]!.light;
          final c = theme.extension<D3TokensExtension>()!.colors;
          for (final tint in auroraColors(c)) {
            final worst = Color.alphaBlend(
              tint.withValues(alpha: auroraStrength),
              c.surfaceContainerLow,
            );
            expect(
              d3ContrastRatio(c.onSurface, worst),
              greaterThanOrEqualTo(4.5),
              reason: '${brand.id} ${dark ? 'dark' : 'light'} $tint',
            );
          }
        }
      });
    }
  });

  setUp(AuroraHero.resetForTest);

  Widget app({bool reduceMotion = false}) => MaterialApp(
        theme: themes['blue']!.light,
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: reduceMotion),
          child: const Scaffold(
            body: AuroraHero(height: 200, child: Center(child: Text('Hello'))),
          ),
        ),
      );

  testWidgets('shows its child, and is hidden from accessibility', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.pump();
    expect(find.text('Hello'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AuroraHero),
        matching: find.byType(ExcludeSemantics),
      ),
      findsWidgets,
    );
  });

  testWidgets('animates, but not with reduced motion', (tester) async {
    await tester.pumpWidget(app());
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pump();
    expect(
      SchedulerBinding.instance.transientCallbackCount,
      greaterThan(0),
      reason: 'the ticker runs once the shader is ready',
    );

    await tester.pumpWidget(app(reduceMotion: true));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pump();
    expect(SchedulerBinding.instance.transientCallbackCount, 0);
  });

  testWidgets('stops while the tab is hidden', (tester) async {
    await tester.pumpWidget(app());
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    await tester.pump();
    expect(SchedulerBinding.instance.transientCallbackCount, 0);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(SchedulerBinding.instance.transientCallbackCount, greaterThan(0));
  });

  testWidgets('with shaded: false no shader runs (embedded view)', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: themes['blue']!.light,
        home: const Scaffold(
          body: AuroraHero(
            height: 200,
            shaded: false,
            child: Center(child: Text('Hello')),
          ),
        ),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pump();
    expect(find.text('Hello'), findsOneWidget);
    expect(SchedulerBinding.instance.transientCallbackCount, 0);
  });
}
