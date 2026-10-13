import 'dart:io';
import 'dart:math' show pow;

import 'package:d3_ui/d3_ui.dart';
import 'package:d3_ui_example/showcase/aurora_hero.dart';
import 'package:d3_ui_example/showcase/brands.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  late Map<String, BrandThemes> themes;
  D3ColorTokens night() =>
      themes['blue']!.dark.extension<D3TokensExtension>()!.colors;

  setUpAll(() async {
    themes = await loadBrandThemes(load: (a) => File(a).readAsString());
  });

  /// A grey with the given relative luminance.
  Color greyWithLuminance(double l) {
    final v = l <= 0.0031308 ? 12.92 * l : 1.055 * pow(l, 1 / 2.4) - 0.055;
    return Color.from(alpha: 1, red: v, green: v, blue: v);
  }

  group('contrast over the aurora', () {
    // The shader caps every pixel at auroraMaxLuminance, so the brightest
    // background any text can meet is a grey of that luminance.
    test('every brand\'s hero text keeps 4.5:1 against the brightest pixel',
        () {
      final brightest = greyWithLuminance(auroraMaxLuminance);
      for (final brand in showcaseBrands) {
        final night =
            themes[brand.id]!.dark.extension<D3TokensExtension>()!.colors;
        expect(
          d3ContrastRatio(night.onSurface, brightest),
          greaterThanOrEqualTo(4.5),
          reason: brand.id,
        );
      }
    });

    test('the palette is derived from the brand and differs between brands',
        () {
      final skies = <Color>{};
      for (final brand in showcaseBrands) {
        final night =
            themes[brand.id]!.dark.extension<D3TokensExtension>()!.colors;
        final p = auroraPalette(night);
        expect(p.curtains, hasLength(3));
        skies.add(p.sky);
      }
      expect(skies.length, showcaseBrands.length);
    });
  });

  setUp(AuroraHero.resetForTest);

  Widget app({bool reduceMotion = false}) => MaterialApp(
        theme: themes['blue']!.light,
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: reduceMotion),
          child: Scaffold(
            body: AuroraHero(
              night: night(),
              height: 200,
              child: const Center(child: Text('Hello')),
            ),
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
        home: Scaffold(
          body: AuroraHero(
            night: night(),
            height: 200,
            shaded: false,
            child: const Center(child: Text('Hello')),
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

  testWidgets('reacts to a hover and a touch without blocking the content', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: themes['blue']!.light,
        home: Scaffold(
          body: AuroraHero(
            night: night(),
            height: 200,
            child: Center(
              child: TextButton(
                onPressed: () => taps++,
                child: const Text('Go'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pump();

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.byType(AuroraHero)));
    await tester.pump(const Duration(milliseconds: 100));
    await mouse.moveTo(const Offset(-50, -50)); // leaves the hero
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('Go'));
    expect(taps, 1, reason: 'a button on top still works');
  });
}
