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

  group('D3ImageViewerState.replaceImage', () {
    testWidgets('swaps the shown image at the given index in place', (
      tester,
    ) async {
      final key = GlobalKey<D3ImageViewerState>();
      await tester.pumpWidget(
        _wrap(
          D3ImageViewer(
            key: key,
            images: const [
              D3ImageSource.network('https://example.com/original.png'),
            ],
          ),
        ),
      );

      key.currentState!.replaceImage(
        0,
        const D3ImageSource.network('https://example.com/replaced.png'),
      );
      await tester.pump();

      final image = tester.widget<Image>(find.byType(Image));
      final provider = image.image as NetworkImage;
      expect(provider.url, 'https://example.com/replaced.png');
    });

    testWidgets('does not affect actionsBuilder\'s own current-index '
        'tracking', (tester) async {
      final key = GlobalKey<D3ImageViewerState>();
      await tester.pumpWidget(
        _wrap(
          D3ImageViewer(
            key: key,
            images: const [
              D3ImageSource.network('https://example.com/a.png'),
              D3ImageSource.network('https://example.com/b.png'),
            ],
            actionsBuilder: (index) => [Text('actions for $index')],
          ),
        ),
      );

      key.currentState!.replaceImage(
        0,
        const D3ImageSource.network('https://example.com/a2.png'),
      );
      await tester.pump();

      expect(key.currentState!.currentIndex, 0);
      expect(find.text('actions for 0'), findsOneWidget);
    });

    testWidgets('an out-of-range index is a no-op, not a crash', (
      tester,
    ) async {
      final key = GlobalKey<D3ImageViewerState>();
      await tester.pumpWidget(
        _wrap(
          D3ImageViewer(
            key: key,
            images: const [
              D3ImageSource.network('https://example.com/a.png'),
            ],
          ),
        ),
      );

      key.currentState!.replaceImage(
        5,
        const D3ImageSource.network('https://example.com/z.png'),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('a genuinely new images list from the parent still takes '
        'effect via the normal declarative rebuild path', (tester) async {
      var images = const [D3ImageSource.network('https://example.com/a.png')];
      late StateSetter setLocalState;

      await tester.pumpWidget(
        _wrap(
          StatefulBuilder(
            builder: (context, setState) {
              setLocalState = setState;
              return D3ImageViewer(images: images);
            },
          ),
        ),
      );

      setLocalState(() {
        images = const [D3ImageSource.network('https://example.com/b.png')];
      });
      await tester.pump();

      final image = tester.widget<Image>(find.byType(Image));
      final provider = image.image as NetworkImage;
      expect(provider.url, 'https://example.com/b.png');
    });
  });
}
