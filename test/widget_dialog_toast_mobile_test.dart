import 'package:d3_ui/d3_ui.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Mobile UX checks for D3Dialog and D3Toast (WORK-0080): thumb-sized targets,
/// no overflow with long text or large text scale, contrast, semantics.

Future<void> _open(
  WidgetTester tester, {
  required D3Dialog Function(BuildContext) dialog,
  Size size = const Size(360, 740),
  double textScale = 1.0,
  bool dark = false,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: dark ? D3AppTheme.dark() : D3AppTheme.light(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () =>
                showDialog<void>(context: context, builder: dialog),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

D3DialogAction _action(
  String label, {
  bool destructive = false,
  bool primary = false,
}) => D3DialogAction(
  label: label,
  isDestructive: destructive,
  isDefault: primary,
  onPressedWithContext: (c) => D3Dialog.pop(c),
);

void main() {
  group('D3Dialog on a phone', () {
    testWidgets('inline buttons are at least 48 dp tall', (tester) async {
      await _open(
        tester,
        dialog: (_) => D3Dialog(
          title: 'Leave?',
          message: 'Your draft is saved.',
          actions: [_action('Stay'), _action('Leave', primary: true)],
        ),
      );
      for (final label in ['Stay', 'Leave']) {
        final button = find.ancestor(
          of: find.text(label),
          matching: find.byType(TextButton),
        );
        expect(
          tester.getSize(button).height,
          greaterThanOrEqualTo(48),
          reason: label,
        );
      }
    });

    testWidgets('stacked buttons are at least 48 dp tall', (tester) async {
      await _open(
        tester,
        dialog: (_) => D3Dialog(
          icon: Icons.delete_outline,
          title: 'Delete',
          actions: [_action('Cancel'), _action('Delete', destructive: true)],
        ),
      );
      for (final label in ['Cancel', 'Delete']) {
        final box = find.ancestor(
          of: find.text(label),
          matching: find.byType(InkWell),
        );
        expect(
          tester.getSize(box).height,
          greaterThanOrEqualTo(48),
          reason: label,
        );
      }
    });

    testWidgets('long content scrolls and the actions stay reachable', (
      tester,
    ) async {
      await _open(
        tester,
        size: const Size(320, 480),
        textScale: 2.0,
        dialog: (_) => D3Dialog(
          icon: Icons.info_outline,
          title: 'Terms and conditions',
          message: List.filled(
            40,
            'A long sentence about the terms.',
          ).join(' '),
          actions: [_action('Decline'), _action('Accept', primary: true)],
        ),
      );
      expect(tester.takeException(), isNull, reason: 'no overflow');
      expect(find.text('Accept'), findsOneWidget);
      final accept = tester.getRect(find.text('Accept'));
      expect(accept.bottom, lessThanOrEqualTo(480), reason: 'on screen');
    });

    testWidgets('two long inline labels wrap instead of overflowing', (
      tester,
    ) async {
      await _open(
        tester,
        size: const Size(320, 640),
        dialog: (_) => D3Dialog(
          title: 'Sync',
          message: 'Choose what to do with your changes.',
          actions: [
            _action('Discard my local changes'),
            _action('Keep and upload everything', primary: true),
          ],
        ),
      );
      expect(tester.takeException(), isNull);
    });

    for (final dark in [false, true]) {
      testWidgets(
        'destructive label reads on its button (${dark ? 'dark' : 'light'})',
        (tester) async {
          await _open(
            tester,
            dark: dark,
            dialog: (_) => D3Dialog(
              icon: Icons.delete_outline,
              title: 'Delete',
              actions: [
                _action('Cancel'),
                _action('Delete', destructive: true),
              ],
            ),
          );
          final colors = (dark ? D3AppTheme.dark() : D3AppTheme.light())
              .extension<D3TokensExtension>()!
              .colors;
          expect(
            d3ContrastRatio(colors.onError, colors.error),
            greaterThanOrEqualTo(4.5),
          );
          final text = tester.widget<Text>(find.text('Delete').last);
          expect(text.style!.color, colors.onError);
        },
      );
    }

    testWidgets('stacked order keeps the given order within each group', (
      tester,
    ) async {
      await _open(
        tester,
        dialog: (_) => D3Dialog(
          icon: Icons.help_outline,
          title: 'Choose',
          actions: [
            _action('Later'),
            _action('Never'),
            _action('Now', primary: true),
          ],
        ),
      );
      final y = {
        for (final l in ['Now', 'Later', 'Never'])
          l: tester.getTopLeft(find.text(l)).dy,
      };
      expect(y['Now']!, lessThan(y['Later']!));
      expect(y['Later']!, lessThan(y['Never']!));
    });

    testWidgets('announces itself: named route and a header title', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _open(
        tester,
        dialog: (_) => D3Dialog(
          title: 'Delete account',
          message: 'This cannot be undone.',
          actions: [_action('Cancel'), _action('Delete', destructive: true)],
        ),
      );
      final node = tester.getSemantics(
        find.bySemanticsLabel('Delete account').first,
      );
      expect(
        node.getSemanticsData().flagsCollection.isHeader ||
            node.getSemanticsData().flagsCollection.namesRoute,
        isTrue,
      );
      expect(
        tester
            .getSemantics(find.text('Delete account'))
            .getSemanticsData()
            .flagsCollection
            .isHeader,
        isTrue,
      );
      handle.dispose();
    });
  });

  group('D3Toast targets', () {
    Future<void> show(WidgetTester tester, {VoidCallback? onAction}) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: D3AppTheme.light(),
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => D3Toast.show(
                  context,
                  title: 'Item deleted',
                  action: D3ToastAction(
                    label: 'Undo',
                    onPressed: onAction ?? () {},
                  ),
                  duration: Duration.zero,
                ),
                child: const Text('go'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
    }

    testWidgets('the action and the dismiss button are at least 48 dp', (
      tester,
    ) async {
      await show(tester);
      final action = find.ancestor(
        of: find.text('Undo'),
        matching: find.byType(InkWell),
      );
      expect(tester.getSize(action).height, greaterThanOrEqualTo(48));
      expect(tester.getSize(action).width, greaterThanOrEqualTo(48));
      final dismiss = find
          .ancestor(
            of: find.byIcon(Icons.close_rounded),
            matching: find.byType(SizedBox),
          )
          .first;
      expect(tester.getSize(dismiss).width, greaterThanOrEqualTo(48));
      expect(tester.getSize(dismiss).height, greaterThanOrEqualTo(48));
    });

    testWidgets('the action runs and dismisses the toast', (tester) async {
      var ran = 0;
      await show(tester, onAction: () => ran++);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(ran, 1);
      expect(find.text('Item deleted'), findsNothing);
    });

    testWidgets('the dismiss button closes it', (tester) async {
      await show(tester);
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Item deleted'), findsNothing);
    });
  });
}
