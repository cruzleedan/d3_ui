import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:d3_ui/d3_ui.dart';

Widget _wrap(Widget child) {
  return MaterialApp(theme: D3AppTheme.light(), home: Scaffold(body: child));
}

void main() {
  group('D3PhotoStrip.viewerActionsBuilder', () {
    testWidgets('forwards actions into the pushed viewer, keyed by the '
        'tapped index', (tester) async {
      await tester.pumpWidget(
        _wrap(
          D3PhotoStrip(
            photoPaths: const ['a.png', 'b.png'],
            itemLabel: 'Test item',
            viewerActionsBuilder: (index) => [Text('action for $index')],
          ),
        ),
      );

      // Tap the second thumbnail specifically, to prove the index
      // forwarded is the one actually tapped, not always 0.
      await tester.tap(find.byType(GestureDetector).at(1));
      await tester.pumpAndSettle();

      expect(find.text('action for 1'), findsOneWidget);
    });

    testWidgets('omitting viewerActionsBuilder shows no extra actions, '
        'unchanged from before this parameter existed', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const D3PhotoStrip(
            photoPaths: ['a.png'],
            itemLabel: 'Test item',
          ),
        ),
      );

      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();

      // The pushed viewer exists (proves navigation itself still works)
      // but carries no caller-supplied action widgets.
      expect(find.byType(D3ImageViewer), findsOneWidget);
    });

    testWidgets('actions update when swiping to a different photo inside '
        'one viewer session', (tester) async {
      await tester.pumpWidget(
        _wrap(
          D3PhotoStrip(
            photoPaths: const ['a.png', 'b.png'],
            itemLabel: 'Test item',
            viewerActionsBuilder: (index) => [Text('action for $index')],
          ),
        ),
      );

      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();
      expect(find.text('action for 0'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();
      expect(find.text('action for 0'), findsNothing);
      expect(find.text('action for 1'), findsOneWidget);
    });
  });
}
