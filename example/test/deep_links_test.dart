import 'dart:io';

import 'package:d3_ui_example/showcase/app.dart';
import 'package:d3_ui_example/showcase/brands.dart';
import 'package:d3_ui_example/showcase/params.dart';
import 'package:d3_ui_example/showcase/scope.dart';
import 'package:d3_ui_example/showcase/shell.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('showcaseLocation', () {
    test('a plain state is a plain address', () {
      expect(
        showcaseLocation(
          page: 'overview',
          themeMode: ThemeMode.system,
          brand: 'blue',
        ).toString(),
        '/',
      );
    }, skip: false);

    test('keeps only what differs from the defaults', () {
      final uri = showcaseLocation(
        page: 'button',
        themeMode: ThemeMode.dark,
        brand: 'terracotta',
      );
      expect(uri.path, '/');
      expect(uri.queryParameters, {
        'page': 'button',
        'theme': 'dark',
        'brand': 'terracotta',
      });
    });

    test('keeps embed, and round-trips through the parser', () {
      final uri = showcaseLocation(
        page: 'patterns',
        themeMode: ThemeMode.light,
        brand: 'green',
        embed: true,
      );
      final back = ShowcaseParams.fromUri(uri);
      expect(back.page, 'patterns');
      expect(back.themeMode, ThemeMode.light);
      expect(back.brand, 'green');
      expect(back.embed, isTrue);
    });
  });

  group('ShowcaseApp', () {
    late Map<String, BrandThemes> themes;

    setUpAll(() async {
      themes = await loadBrandThemes(load: (a) => File(a).readAsString());
    });

    Future<void> pumpApp(WidgetTester tester, ShowcaseParams params) async {
      tester.view.physicalSize = const Size(1300, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(ShowcaseApp(brandThemes: themes, params: params));
      await tester.pumpAndSettle();
    }

    testWidgets('opens the page the address names', (tester) async {
      await pumpApp(tester, const ShowcaseParams(page: 'toast'));
      expect(find.text('D3Toast'), findsWidgets);
    });

    testWidgets('an unknown page falls back to the overview', (tester) async {
      await pumpApp(tester, const ShowcaseParams(page: 'nope'));
      expect(find.text('d3_ui'), findsWidgets);
      expect(find.text('Try the components'), findsOneWidget);
    });

    testWidgets('browser back and forward change the page', (tester) async {
      await pumpApp(tester, const ShowcaseParams(page: 'toast'));
      // What the engine sends when the browser goes back or forward.
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/navigation',
        const JSONMethodCodec().encodeMethodCall(
          const MethodCall('pushRouteInformation', {
            'location': '/?page=chip&brand=green&theme=dark',
            'state': null,
          }),
        ),
        (_) {},
      );
      await tester.pump();
      final scope =
          ShowcaseScope.of(tester.element(find.byType(ShowcaseShell)));
      expect(scope.pageId, 'chip');
      expect(scope.brand.id, 'green');
      expect(scope.themeMode, ThemeMode.dark);
      // Let the deferred page's code arrive so the test ends cleanly.
      for (var i = 0; i < 5; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 100)),
        );
        await tester.pump(const Duration(milliseconds: 100));
      }
    });
  });
}
