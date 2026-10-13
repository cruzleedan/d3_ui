import 'dart:io';

import 'package:d3_ui_example/showcase/app.dart';
import 'package:d3_ui_example/showcase/brands.dart';
import 'package:d3_ui_example/showcase/params.dart';
import 'package:d3_ui_example/showcase/scope.dart';
import 'package:d3_ui_example/showcase/shell.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
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
    });

    test('the page is the path; only what differs is in the query', () {
      final uri = showcaseLocation(
        page: 'button',
        themeMode: ThemeMode.dark,
        brand: 'terracotta',
      );
      expect(uri.path, '/button');
      expect(uri.queryParameters, {'theme': 'dark', 'brand': 'terracotta'});
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

  group('older links', () {
    test('/?page=button&brand=green becomes /button?brand=green', () {
      expect(
        legacyLocation(Uri.parse('/?page=button&brand=green')).toString(),
        '/button?brand=green',
      );
    });

    test('a new-style address is not an old link', () {
      expect(legacyLocation(Uri.parse('/button?brand=green')), isNull);
      expect(legacyLocation(Uri.parse('/')), isNull);
    });

    test('the parser reads either form', () {
      expect(ShowcaseParams.fromUri(Uri.parse('/dialog')).page, 'dialog');
      expect(ShowcaseParams.fromUri(Uri.parse('/?page=dialog')).page, 'dialog');
    });
  });

  group('ShowcaseApp', () {
    late Map<String, BrandThemes> themes;

    setUpAll(() async {
      themes = await loadBrandThemes(load: (a) => File(a).readAsString());
    });

    Future<ShowcaseScope> open(WidgetTester tester, String address) async {
      tester.view.physicalSize = const Size(1300, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ShowcaseApp(brandThemes: themes, initialUri: Uri.parse(address)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      return ShowcaseScope.of(tester.element(find.byType(ShowcaseShell)));
    }

    // A deferred page's code arrives on the real event loop; let it, so the
    // test ends with nothing pending.
    Future<void> settle(WidgetTester tester) async {
      for (var i = 0; i < 4; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 100)),
        );
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    testWidgets('a path opens that page, with brand and theme', (tester) async {
      final scope = await open(tester, '/toast?brand=green&theme=dark');
      expect(scope.pageId, 'toast');
      expect(scope.brand.id, 'green');
      expect(scope.themeMode, ThemeMode.dark);
      await settle(tester);
      expect(find.text('D3Toast'), findsWidgets);
    });

    testWidgets('an old /?page= link still works', (tester) async {
      final scope = await open(tester, '/?page=chip&brand=terracotta');
      expect(scope.pageId, 'chip');
      expect(scope.brand.id, 'terracotta');
      await settle(tester);
    });

    testWidgets('an unknown page is the overview', (tester) async {
      final scope = await open(tester, '/nope');
      expect(scope.pageId, 'overview');
      expect(find.text('Try the components'), findsOneWidget);
    });

    testWidgets('choosing a page, a brand and a theme moves the address', (
      tester,
    ) async {
      var scope = await open(tester, '/');
      final router = GoRouter.of(tester.element(find.byType(ShowcaseShell)));

      scope.onPageChanged('chip');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(router.routeInformationProvider.value.uri.toString(), '/chip');

      scope = ShowcaseScope.of(tester.element(find.byType(ShowcaseShell)));
      scope.onBrandChanged(brandById('green'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      scope = ShowcaseScope.of(tester.element(find.byType(ShowcaseShell)));
      scope.onThemeModeChanged(ThemeMode.dark);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        router.routeInformationProvider.value.uri.toString(),
        '/chip?theme=dark&brand=green',
      );
      scope = ShowcaseScope.of(tester.element(find.byType(ShowcaseShell)));
      expect(scope.pageId, 'chip');
      expect(scope.brand.id, 'green');
      expect(scope.themeMode, ThemeMode.dark);
      await settle(tester);
    });
  });
}
