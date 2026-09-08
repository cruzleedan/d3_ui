import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:d3_ui/d3_ui.dart';

Widget _wrap(Widget child) {
  return MaterialApp(theme: D3AppTheme.light(), home: Scaffold(body: child));
}

void main() {
  group('D3Dialog.pop', () {
    testWidgets('closes the dialog and returns the given result', (tester) async {
      Object? result;
      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) => D3Button(
              label: 'Open',
              onPressed: () async {
                result = await D3Dialog.show<bool>(
                  context,
                  title: 'Delete?',
                  actions: [
                    D3DialogAction(
                      label: 'Cancel',
                      onPressedWithContext: (ctx) => D3Dialog.pop(ctx),
                    ),
                    D3DialogAction(
                      label: 'Delete',
                      isDestructive: true,
                      onPressedWithContext: (ctx) => D3Dialog.pop(ctx, true),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Delete?'), findsOneWidget);

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Delete?'), findsNothing);
      expect(result, isTrue);
    });

    // Regression test for the exact bug this API exists to fix: a dialog
    // shown (via useRootNavigator: true, the default) from a screen that
    // is itself nested inside its own Navigator (e.g. a
    // StatefulShellRoute branch in a real app). A raw
    // Navigator.of(callerContext).pop() from the dialog's action would
    // resolve to the *nested* Navigator -- the caller's own -- and pop
    // its single page instead of the dialog, since useRootNavigator only
    // controls where the dialog *route* is pushed, not what the
    // caller's own Navigator.of resolves to. D3Dialog.pop must close the
    // dialog without touching the nested Navigator at all.
    testWidgets(
      'shown from a nested Navigator, pop closes the dialog without '
      'popping the host screen\'s own (single-page) Navigator',
      (tester) async {
        Object? result;
        var hostPopped = false;

        await tester.pumpWidget(
          _wrap(
            // Simulates a StatefulShellRoute branch: its own Navigator,
            // with exactly one page -- popping it would be the crash
            // this test guards against.
            Navigator(
              onDidRemovePage: (_) => hostPopped = true,
              pages: [
                MaterialPage(
                  child: Builder(
                    builder: (context) => D3Button(
                      label: 'Open',
                      onPressed: () async {
                        result = await D3Dialog.show<bool>(
                          context,
                          title: 'Delete?',
                          // Default useRootNavigator: true -- the dialog
                          // route goes to the *root* Navigator (from
                          // _wrap's MaterialApp), not this nested one.
                          actions: [
                            D3DialogAction(
                              label: 'Delete',
                              onPressedWithContext: (ctx) => D3Dialog.pop(ctx, true),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        expect(find.text('Delete?'), findsOneWidget);

        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();

        expect(find.text('Delete?'), findsNothing);
        expect(result, isTrue);
        // The critical assertion: the nested (host) Navigator's own
        // single page was never touched.
        expect(hostPopped, isFalse);
        expect(find.text('Open'), findsOneWidget);
      },
    );

    testWidgets('omitting a result pops with null', (tester) async {
      Object? result = 'not-null-yet';
      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) => D3Button(
              label: 'Open',
              onPressed: () async {
                result = await D3Dialog.show<bool>(
                  context,
                  title: 'Info',
                  actions: [
                    D3DialogAction(
                      label: 'OK',
                      onPressedWithContext: (ctx) => D3Dialog.pop(ctx),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(result, isNull);
    });

    testWidgets(
      'the plain onPressed (non-context) callback still works unchanged '
      '-- non-breaking for every existing call site',
      (tester) async {
        var pressed = false;
        await tester.pumpWidget(
          _wrap(
            Builder(
              builder: (context) => D3Button(
                label: 'Open',
                onPressed: () => D3Dialog.show<void>(
                  context,
                  title: 'Info',
                  actions: [
                    D3DialogAction(label: 'OK', onPressed: () => pressed = true),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        expect(pressed, isTrue);
      },
    );
  });

  group('D3DialogAction', () {
    test('requires exactly one of onPressed or onPressedWithContext', () {
      expect(
        () => D3DialogAction(label: 'X', onPressed: () {}),
        returnsNormally,
      );
      expect(
        () => D3DialogAction(label: 'X', onPressedWithContext: (_) {}),
        returnsNormally,
      );
      expect(
        () => D3DialogAction(label: 'X'),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => D3DialogAction(
          label: 'X',
          onPressed: () {},
          onPressedWithContext: (_) {},
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
