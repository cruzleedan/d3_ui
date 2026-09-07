import 'dart:async';

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

  group('D3ImageViewer.resolveImage', () {
    testWidgets('shows the passed-in image immediately, then swaps to the '
        'resolved one once it completes', (tester) async {
      final resolveCompleter = Completer<D3ImageSource>();

      await tester.pumpWidget(
        _wrap(
          D3ImageViewer(
            images: const [
              D3ImageSource.network('https://example.com/original.png'),
            ],
            resolveImage: (index) => resolveCompleter.future,
          ),
        ),
      );

      var image = tester.widget<Image>(find.byType(Image));
      expect(
        (image.image as NetworkImage).url,
        'https://example.com/original.png',
      );

      resolveCompleter.complete(
        const D3ImageSource.network('https://example.com/resolved.png'),
      );
      await tester.pump();

      image = tester.widget<Image>(find.byType(Image));
      expect(
        (image.image as NetworkImage).url,
        'https://example.com/resolved.png',
      );
    });

    testWidgets('is called at most once per index, not on every rebuild', (
      tester,
    ) async {
      var callCount = 0;
      await tester.pumpWidget(
        _wrap(
          D3ImageViewer(
            images: const [
              D3ImageSource.network('https://example.com/a.png'),
            ],
            resolveImage: (index) async {
              callCount++;
              return const D3ImageSource.network('https://example.com/a2.png');
            },
          ),
        ),
      );
      await tester.pump();
      expect(callCount, 1);

      // An unrelated rebuild of the same widget tree (e.g. a parent
      // setState) must not re-trigger resolution for an index already
      // resolved.
      await tester.pumpWidget(
        _wrap(
          D3ImageViewer(
            images: const [
              D3ImageSource.network('https://example.com/a.png'),
            ],
            resolveImage: (index) async {
              callCount++;
              return const D3ImageSource.network('https://example.com/a2.png');
            },
          ),
        ),
      );
      await tester.pump();

      expect(callCount, 1);
    });

    testWidgets('is called again for a newly-visited page after swiping', (
      tester,
    ) async {
      // Local sources rather than network -- resolving to a *third*,
      // not-yet-fetched network URL after the swipe reliably fails in
      // this test binding's sandboxed HttpClient (every request returns
      // 400), which is a test-environment artifact unrelated to the
      // resolution logic under test here.
      final calledFor = <int>[];
      await tester.pumpWidget(
        _wrap(
          D3ImageViewer(
            images: const [
              D3ImageSource.local('a.png'),
              D3ImageSource.local('b.png'),
            ],
            resolveImage: (index) async {
              calledFor.add(index);
              return D3ImageSource.local('$index-r.png');
            },
          ),
        ),
      );
      await tester.pump();
      expect(calledFor, [0]);

      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();

      expect(calledFor, [0, 1]);
    });

    testWidgets('omitting resolveImage changes nothing from before it '
        'existed', (tester) async {
      await tester.pumpWidget(
        _wrap(
          D3ImageViewer(
            images: const [
              D3ImageSource.network('https://example.com/a.png'),
            ],
          ),
        ),
      );
      await tester.pump();

      final image = tester.widget<Image>(find.byType(Image));
      expect(
        (image.image as NetworkImage).url,
        'https://example.com/a.png',
      );
    });
  });
}
