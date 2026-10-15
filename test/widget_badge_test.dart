import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:d3_ui/d3_ui.dart';
import 'package:d3_ui/src/components/display/d3_badge.dart';

Widget _wrap(Widget child, {bool dark = false, double scale = 1}) =>
    MaterialApp(
      theme: dark ? D3AppTheme.dark() : D3AppTheme.light(),
      builder: (context, c) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(scale)),
        child: c!,
      ),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  testWidgets('count formatting', (tester) async {
    await tester.pumpWidget(_wrap(const D3Badge.count(5)));
    expect(find.text('5'), findsOneWidget);
    await tester.pumpWidget(_wrap(const D3Badge.count(100)));
    expect(find.text('99+'), findsOneWidget);
    await tester.pumpWidget(_wrap(const D3Badge.count(99)));
    expect(find.text('99'), findsOneWidget);
    await tester.pumpWidget(_wrap(const D3Badge.count(12, max: 9)));
    expect(find.text('9+'), findsOneWidget);
  });

  testWidgets('zero hidden unless showZero', (tester) async {
    await tester.pumpWidget(_wrap(const D3Badge.count(0)));
    expect(find.text('0'), findsNothing);
    await tester.pumpWidget(_wrap(const D3Badge.count(0, showZero: true)));
    expect(find.text('0'), findsOneWidget);
  });

  testWidgets('label renders for each variant and scale 1.5 is fine', (
    tester,
  ) async {
    for (final v in D3BadgeVariant.values) {
      await tester.pumpWidget(
        _wrap(D3Badge.label('Tag ${v.name}', variant: v), scale: 1.5),
      );
      expect(find.text('Tag ${v.name}'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('semantics labels', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _wrap(
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            D3Badge.count(3, semanticsLabel: '3 notifications'),
            D3Badge.dot(semanticsLabel: 'Unread'),
          ],
        ),
      ),
    );
    expect(find.bySemanticsLabel('3 notifications'), findsOneWidget);
    expect(find.bySemanticsLabel('Unread'), findsOneWidget);
    handle.dispose();
  });

  testWidgets(
    'a badge does not change its child size and child stays tappable',
    (tester) async {
      var taps = 0;
      final button = IconButton(
        icon: const Icon(Icons.mail),
        onPressed: () => taps++,
      );
      await tester.pumpWidget(_wrap(button));
      final before = tester.getSize(find.byType(IconButton));
      await tester.pumpWidget(
        _wrap(D3Badge.on(badge: const D3Badge.count(120), child: button)),
      );
      expect(tester.getSize(find.byType(IconButton)), before);
      expect(tester.getSize(find.byType(D3BadgeAnchor)), before);
      await tester.tap(find.byType(IconButton));
      expect(taps, 1);
    },
  );

  for (final dark in [false, true]) {
    testWidgets('text contrast >= 4.5 (dark: $dark)', (tester) async {
      for (final v in D3BadgeVariant.values) {
        await tester.pumpWidget(
          _wrap(
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                D3Badge.count(4, variant: v),
                D3Badge.label('Tag', variant: v),
              ],
            ),
            dark: dark,
          ),
        );
        final surface = Theme.of(tester.element(find.text('Tag')))
            .colorScheme
            .surface;
        final ctx = tester.element(find.text('Tag'));
        final surf = ctx.d3Colors.surface;
        expect(surface, isNotNull);
        // Count: solid background from its decoration.
        Color bgOf(String text) {
          final box = tester.widget<Container>(
            find
                .ancestor(of: find.text(text), matching: find.byType(Container))
                .first,
          );
          return Color.alphaBlend(
            (box.decoration! as BoxDecoration).color!,
            surf,
          );
        }

        for (final t in ['4', 'Tag']) {
          final fg = tester.widget<Text>(find.text(t)).style!.color!;
          expect(
            d3ContrastRatio(fg, bgOf(t)),
            greaterThanOrEqualTo(4.5),
            reason: '$t ${v.name} dark=$dark',
          );
        }
      }
    });
  }

  testWidgets(
    'a count badge keeps its own size in a stretching column and on a '
    '48 dp button',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: D3AppTheme.light(),
          home: Scaffold(
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const D3Badge.count(3),
                D3BadgeAnchor(
                  badge: const D3Badge.count(3),
                  child: const SizedBox(width: 48, height: 48),
                ),
              ],
            ),
          ),
        ),
      );
      final badges = find.byType(D3Badge);
      for (final e in badges.evaluate()) {
        final pill = find.descendant(
          of: find.byWidget(e.widget),
          matching: find.byType(DecoratedBox),
        );
        final size = tester.getSize(pill.first);
        expect(size.width, lessThan(40), reason: 'not stretched');
        expect(size.height, lessThan(30));
      }
    },
  );
}
