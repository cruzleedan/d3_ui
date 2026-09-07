import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:d3_ui/d3_ui.dart';

Widget _wrap(Widget child) {
  return MaterialApp(theme: D3AppTheme.light(), home: child);
}

void main() {
  group('D3ImageViewer.actionsBuilder', () {
    testWidgets('actions builds from the initial index on first render', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          D3ImageViewer(
            images: const [
              D3ImageSource.network('https://example.com/a.png'),
              D3ImageSource.network('https://example.com/b.png'),
            ],
            actionsBuilder: (index) => [Text('actions for $index')],
          ),
        ),
      );

      expect(find.text('actions for 0'), findsOneWidget);
      expect(find.text('actions for 1'), findsNothing);
    });

    testWidgets('actions rebuild for the new page after swiping', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          D3ImageViewer(
            images: const [
              D3ImageSource.network('https://example.com/a.png'),
              D3ImageSource.network('https://example.com/b.png'),
            ],
            actionsBuilder: (index) => [Text('actions for $index')],
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();

      expect(find.text('actions for 0'), findsNothing);
      expect(find.text('actions for 1'), findsOneWidget);
    });

    testWidgets('onPageChanged still fires alongside actionsBuilder', (
      tester,
    ) async {
      var lastIndex = -1;
      await tester.pumpWidget(
        _wrap(
          D3ImageViewer(
            images: const [
              D3ImageSource.network('https://example.com/a.png'),
              D3ImageSource.network('https://example.com/b.png'),
            ],
            actionsBuilder: (index) => const [],
            onPageChanged: (i) => lastIndex = i,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();

      expect(lastIndex, 1);
    });

    testWidgets('plain actions still works unchanged when actionsBuilder '
        'is omitted', (tester) async {
      await tester.pumpWidget(
        _wrap(
          D3ImageViewer(
            images: const [D3ImageSource.network('https://example.com/a.png')],
            actions: const [Text('fixed action')],
          ),
        ),
      );

      expect(find.text('fixed action'), findsOneWidget);
    });

    testWidgets('passing both actions and actionsBuilder asserts', (
      tester,
    ) async {
      expect(
        () => D3ImageViewer(
          images: const [D3ImageSource.network('https://example.com/a.png')],
          actions: const [SizedBox()],
          actionsBuilder: (index) => const [],
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
