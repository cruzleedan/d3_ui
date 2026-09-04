import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:d3_ui/d3_ui.dart';

/// Wraps a widget with [D3AppTheme] so tokens are available.
Widget _wrap(Widget child) {
  return MaterialApp(
    theme: D3AppTheme.light(),
    darkTheme: D3AppTheme.dark(),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('D3Debouncer', () {
    test('runs the action once after the delay, cancelling prior runs', () async {
      var callCount = 0;
      final debouncer = D3Debouncer(delay: const Duration(milliseconds: 20));

      debouncer.run(() => callCount++);
      debouncer.run(() => callCount++);
      debouncer.run(() => callCount++);

      await Future<void>.delayed(const Duration(milliseconds: 40));
      expect(callCount, 1);
    });
  });

  group('D3HyperlinkButton', () {
    testWidgets('renders label and calls onPressed when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(D3HyperlinkButton(label: 'Sign in', onPressed: () => tapped = true)),
      );
      expect(find.text('Sign in'), findsOneWidget);
      await tester.tap(find.byType(D3HyperlinkButton));
      expect(tapped, isTrue);
    });

    testWidgets('does not call onPressed when disabled', (tester) async {
      await tester.pumpWidget(_wrap(const D3HyperlinkButton(label: 'Disabled')));
      await tester.tap(find.byType(D3HyperlinkButton));
      // No onPressed provided — tapping must not throw.
      expect(find.text('Disabled'), findsOneWidget);
    });
  });

  group('D3ExpandingFab', () {
    testWidgets('expands to show actions and collapses on selection', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        _wrap(
          D3ExpandingFab(
            actions: [
              D3FabAction(
                icon: Icons.photo_camera_outlined,
                label: 'Photo',
                onPressed: () => pressed = true,
              ),
            ],
          ),
        ),
      );

      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
      expect(find.text('Photo'), findsNothing);

      await tester.tap(find.byType(D3ExpandingFab));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      expect(find.text('Photo'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.photo_camera_outlined));
      await tester.pumpAndSettle();

      expect(pressed, isTrue);
      expect(find.text('Photo'), findsNothing);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
    });
  });

  group('D3ListTileSkeleton / D3FormSkeleton', () {
    testWidgets('render without error inside D3Shimmer', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const D3Shimmer(
            child: Column(
              children: [
                D3ListTileSkeleton(),
                D3FormSkeleton(fieldCount: 2),
              ],
            ),
          ),
        ),
      );
      expect(find.byType(D3ListTileSkeleton), findsOneWidget);
      expect(find.byType(D3FormSkeleton), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 100));
    });
  });

  group('showD3CalendarPicker', () {
    testWidgets('opens, selects a day, and returns it on OK', (tester) async {
      DateTime? picked;
      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) => D3Button(
              label: 'Open',
              onPressed: () async {
                picked = await showD3CalendarPicker(
                  context: context,
                  initialDate: DateTime(2026, 9, 4),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(D3Button));
      await tester.pumpAndSettle();

      expect(find.text('September 2026'), findsOneWidget);

      await tester.tap(find.text('10'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(picked, DateTime(2026, 9, 10));
    });

    testWidgets('Cancel returns null', (tester) async {
      DateTime? picked = DateTime(2020, 1, 1);
      var completed = false;
      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) => D3Button(
              label: 'Open',
              onPressed: () async {
                picked = await showD3CalendarPicker(
                  context: context,
                  initialDate: DateTime(2026, 9, 4),
                );
                completed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(D3Button));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(completed, isTrue);
      expect(picked, isNull);
    });
  });
}
