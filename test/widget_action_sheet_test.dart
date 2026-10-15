import 'dart:ui' show Tristate;

import 'package:d3_ui/d3_ui.dart';
import 'package:d3_ui/src/components/sheets/d3_action_sheet.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Widget _app(
  Widget Function(BuildContext) opener, {
  ThemeData? theme,
  double textScale = 1.0,
}) {
  return MaterialApp(
    theme: theme ?? D3AppTheme.light(),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(textScale)),
      child: child!,
    ),
    home: Scaffold(body: Builder(builder: opener)),
  );
}

void main() {
  Future<void> open(WidgetTester tester, Widget app) async {
    await tester.pumpWidget(app);
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  Widget opener(
    BuildContext context, {
    required void Function(Object?) onResult,
    List<D3ActionSheetAction>? actions,
    String? title,
    String? message,
  }) {
    return TextButton(
      child: const Text('Open'),
      onPressed: () async {
        onResult(
          await D3ActionSheet.show<String>(
            context,
            title: title,
            message: message,
            actions: actions ?? const [D3ActionSheetAction(label: 'Share')],
          ),
        );
      },
    );
  }

  testWidgets('shows title, message, rows and Cancel', (tester) async {
    await open(
      tester,
      _app(
        (c) => opener(
          c,
          onResult: (_) {},
          title: 'Photo',
          message: 'Pick one',
          actions: const [
            D3ActionSheetAction(label: 'Share'),
            D3ActionSheetAction(label: 'Edit'),
          ],
        ),
      ),
    );
    for (final t in ['Photo', 'Pick one', 'Share', 'Edit', 'Cancel']) {
      expect(find.text(t), findsOneWidget);
    }
  });

  testWidgets('tapping a row calls its callback and closes', (tester) async {
    var called = 0;
    Object? result = 'unset';
    await open(
      tester,
      _app(
        (c) => opener(
          c,
          onResult: (r) => result = r,
          actions: [
            D3ActionSheetAction(label: 'Share', onPressed: () => called++),
          ],
        ),
      ),
    );
    await tester.tap(find.text('Share'));
    await tester.pumpAndSettle();
    expect(called, 1);
    expect(find.text('Share'), findsNothing);
    expect(result, isNull);
  });

  testWidgets('pop with a result returns it', (tester) async {
    Object? result;
    await open(
      tester,
      _app(
        (c) => opener(
          c,
          onResult: (r) => result = r,
          actions: [
            D3ActionSheetAction(
              label: 'Delete',
              onPressedWithContext: (ctx) => D3ActionSheet.pop(ctx, 'del'),
            ),
          ],
        ),
      ),
    );
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Delete'), findsNothing);
    expect(result, 'del');
  });

  testWidgets('Cancel and tap outside return null', (tester) async {
    Object? result = 'unset';
    final app = _app((c) => opener(c, onResult: (r) => result = r));
    await open(tester, app);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Cancel'), findsNothing);
    expect(result, isNull);

    result = 'unset';
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.text('Cancel'), findsNothing);
    expect(result, isNull);
  });

  testWidgets('rows are at least 56dp and Cancel at least 48dp', (
    tester,
  ) async {
    await open(
      tester,
      _app(
        (c) => opener(
          c,
          onResult: (_) {},
          actions: const [D3ActionSheetAction(label: 'Share')],
        ),
      ),
    );
    final row = tester.getSize(
      find
          .ancestor(of: find.text('Share'), matching: find.byType(InkWell))
          .first,
    );
    final cancel = tester.getSize(
      find
          .ancestor(of: find.text('Cancel'), matching: find.byType(InkWell))
          .first,
    );
    expect(row.height, greaterThanOrEqualTo(56));
    expect(cancel.height, greaterThanOrEqualTo(48));
  });

  for (final dark in [false, true]) {
    testWidgets(
      'destructive text has 4.5:1 contrast (${dark ? 'dark' : 'light'})',
      (tester) async {
        final theme = dark ? D3AppTheme.dark() : D3AppTheme.light();
        await open(
          tester,
          _app(
            (c) => opener(
              c,
              onResult: (_) {},
              actions: const [
                D3ActionSheetAction(label: 'Delete', isDestructive: true),
              ],
            ),
            theme: theme,
          ),
        );
        final style = tester.widget<Text>(find.text('Delete')).style!;
        final bg = (dark ? D3ColorTokens.dark : D3ColorTokens.light)
            .surfaceContainerHigh;
        expect(d3ContrastRatio(style.color!, bg), greaterThanOrEqualTo(4.5));
      },
    );
  }

  testWidgets('many actions scroll at text scale 1.5 on a small screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await open(
      tester,
      _app(
        (c) => opener(
          c,
          onResult: (_) {},
          title: 'Many',
          actions: [
            for (var i = 0; i < 20; i++)
              D3ActionSheetAction(label: 'Action $i'),
          ],
        ),
        textScale: 1.5,
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.byType(Scrollable), findsWidgets);
  });

  testWidgets('semantics: destructive hint and selected state', (tester) async {
    final handle = tester.ensureSemantics();
    await open(
      tester,
      _app(
        (c) => opener(
          c,
          onResult: (_) {},
          actions: const [
            D3ActionSheetAction(label: 'Delete', isDestructive: true),
            D3ActionSheetAction(label: 'Newest', isSelected: true),
          ],
        ),
      ),
    );
    expect(find.bySemanticsLabel('Delete, destructive'), findsOneWidget);
    final node = tester.getSemantics(find.bySemanticsLabel('Newest'));
    expect(node.flagsCollection.isSelected, Tristate.isTrue);
    handle.dispose();
  });
}
