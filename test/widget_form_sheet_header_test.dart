import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:d3_ui/d3_ui.dart';

// Covers D3FormSheet's header shape from root context/work/0044: with a
// primaryAction the header takes D3Screen's leading/trailing convention
// (Cancel leads, confirm trails); without one it keeps its original shape.

Future<void> _open(
  WidgetTester tester, {
  D3FormSheetAction? primaryAction,
  // A loading action spins forever, so pumpAndSettle would never return.
  bool settle = true,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: D3AppTheme.light(),
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => D3FormSheet.show<void>(
              context,
              title: 'New Project',
              primaryAction: primaryAction,
              child: const SizedBox(height: 120, child: Text('form body')),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    // Long enough for the sheet's entrance animation to finish.
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }
}

double _xOf(WidgetTester tester, Finder f) => tester.getCenter(f).dx;

void main() {
  group('D3FormSheet header', () {
    testWidgets('without a primaryAction, Cancel stays on the right', (
      tester,
    ) async {
      await _open(tester);

      expect(find.text('Cancel'), findsOneWidget);
      expect(
        _xOf(tester, find.text('Cancel')),
        greaterThan(_xOf(tester, find.text('New Project'))),
        reason: 'unchanged for sheets that have not adopted primaryAction',
      );
    });

    testWidgets('with a primaryAction, Cancel leads and the action trails', (
      tester,
    ) async {
      await _open(
        tester,
        primaryAction: D3FormSheetAction(label: 'Save', onPressed: () {}),
      );

      final cancelX = _xOf(tester, find.text('Cancel'));
      final saveX = _xOf(tester, find.text('Save'));
      final titleX = _xOf(tester, find.text('New Project'));

      expect(cancelX, lessThan(titleX), reason: 'Cancel moved to the left');
      expect(saveX, greaterThan(titleX), reason: 'Save trails');
    });

    testWidgets('the primary action fires on tap', (tester) async {
      var saves = 0;
      await _open(
        tester,
        primaryAction: D3FormSheetAction(
          label: 'Save',
          onPressed: () => saves++,
        ),
      );

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(saves, 1);
    });

    testWidgets('a disabled action renders but does not fire', (tester) async {
      var saves = 0;
      await _open(
        tester,
        primaryAction: D3FormSheetAction(
          label: 'Save',
          enabled: false,
          onPressed: () => saves++,
        ),
      );

      expect(find.text('Save'), findsOneWidget);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(saves, 0);
    });

    testWidgets('a loading action shows a spinner and does not fire', (
      tester,
    ) async {
      var saves = 0;
      await _open(
        tester,
        settle: false,
        primaryAction: D3FormSheetAction(
          label: 'Save',
          isLoading: true,
          onPressed: () => saves++,
        ),
      );

      expect(find.text('Save'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.tap(find.byType(CircularProgressIndicator));
      await tester.pump();
      expect(saves, 0);
    });
  });
}
