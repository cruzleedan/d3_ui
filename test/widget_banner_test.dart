import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:d3_ui/d3_ui.dart';
import 'package:d3_ui/src/components/feedback/d3_banner.dart';

Widget _wrap(Widget child, {bool dark = false, double scale = 1}) =>
    MaterialApp(
      theme: dark ? D3AppTheme.dark() : D3AppTheme.light(),
      builder: (context, c) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(scale)),
        child: c!,
      ),
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

void main() {
  testWidgets('renders text for each variant', (tester) async {
    for (final v in D3BannerVariant.values) {
      await tester.pumpWidget(
        _wrap(
          D3Banner(variant: v, title: 'T ${v.name}', message: 'M ${v.name}'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('T ${v.name}'), findsOneWidget);
      expect(find.text('M ${v.name}'), findsOneWidget);
    }
  });

  testWidgets('action and dismiss fire and are at least 48x48', (tester) async {
    var action = 0, dismiss = 0;
    await tester.pumpWidget(
      _wrap(
        D3Banner(
          message: 'Hello',
          action: D3BannerAction(label: 'Retry', onPressed: () => action++),
          onDismiss: () => dismiss++,
        ),
      ),
    );
    await tester.pumpAndSettle();
    for (final label in ['Retry']) {
      final ink = find.ancestor(
        of: find.text(label),
        matching: find.byType(InkWell),
      );
      final size = tester.getSize(ink.first);
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
    }
    final close = find.ancestor(
      of: find.byIcon(Icons.close_rounded),
      matching: find.byType(InkWell),
    );
    expect(tester.getSize(close.first).height, greaterThanOrEqualTo(48));
    expect(tester.getSize(close.first).width, greaterThanOrEqualTo(48));
    await tester.tap(find.text('Retry'));
    await tester.tap(find.byIcon(Icons.close_rounded));
    expect(action, 1);
    expect(dismiss, 1);
  });

  testWidgets('is a live region', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_wrap(const D3Banner(message: 'Offline')));
    await tester.pumpAndSettle();
    final node = tester.getSemantics(find.text('Offline'));
    expect(node.flagsCollection.isLiveRegion, isTrue);
    handle.dispose();
  });

  testWidgets('text scale 1.5 does not overflow', (tester) async {
    await tester.pumpWidget(
      _wrap(
        D3Banner(
          title: 'A fairly long title for the banner',
          message: 'A long message that has to wrap over several lines. ' * 3,
          action: D3BannerAction(label: 'Retry', onPressed: () {}),
          onDismiss: () {},
        ),
        scale: 1.5,
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('no animation under reduced motion', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: D3AppTheme.light(),
        home: const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Scaffold(body: D3Banner(message: 'Now')),
        ),
      ),
    );
    expect(tester.getSize(find.byType(Material).last).height, greaterThan(20));
  });

  for (final dark in [false, true]) {
    testWidgets('contrast >= 4.5 (dark: $dark)', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (c) {
              ctx = c;
              return const SizedBox();
            },
          ),
          dark: dark,
        ),
      );
      for (final v in D3BannerVariant.values) {
        final s = D3BannerStyle.of(ctx, v);
        final surface = ctx.d3Colors.surface;
        final bg = Color.alphaBlend(s.background, surface);
        for (final fg in [s.titleColor, s.messageColor, s.accent]) {
          expect(
            d3ContrastRatio(fg, bg),
            greaterThanOrEqualTo(4.5),
            reason: '${v.name} dark=$dark',
          );
        }
      }
    });
  }
}
