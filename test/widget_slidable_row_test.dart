import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:d3_ui/d3_ui.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: D3AppTheme.light(),
    home: Scaffold(body: SizedBox(height: 80, child: child)),
  );
}

void main() {
  group('D3SlidableRow', () {
    testWidgets('renders the child unchanged before any swipe', (tester) async {
      await tester.pumpWidget(
        _wrap(
          D3SlidableRow(
            groupTag: 'test',
            actions: [D3SwipeAction(icon: Icons.delete_outline, onPressed: () {})],
            child: const Text('Row content'),
          ),
        ),
      );

      expect(find.text('Row content'), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });

    testWidgets('swiping left reveals the action, tapping it calls onPressed', (
      tester,
    ) async {
      var pressed = false;
      await tester.pumpWidget(
        _wrap(
          D3SlidableRow(
            groupTag: 'test',
            actions: [
              D3SwipeAction(
                icon: Icons.delete_outline,
                label: 'Delete',
                onPressed: () => pressed = true,
              ),
            ],
            child: const Text('Row content'),
          ),
        ),
      );

      await tester.drag(find.text('Row content'), const Offset(-300, 0));
      await tester.pumpAndSettle();

      expect(find.text('Delete'), findsOneWidget);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(pressed, isTrue);
    });

    testWidgets('multiple actions all render once revealed', (tester) async {
      await tester.pumpWidget(
        _wrap(
          D3SlidableRow(
            groupTag: 'test',
            actions: [
              D3SwipeAction(icon: Icons.edit_outlined, label: 'Edit', onPressed: () {}),
              D3SwipeAction(
                icon: Icons.delete_outline,
                label: 'Delete',
                onPressed: () {},
              ),
            ],
            child: const Text('Row content'),
          ),
        ),
      );

      await tester.drag(find.text('Row content'), const Offset(-300, 0));
      await tester.pumpAndSettle();

      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });
  });
}
