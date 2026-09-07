import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:d3_ui/d3_ui.dart';

Widget _wrap(Widget child) {
  return MaterialApp(theme: D3AppTheme.light(), home: Scaffold(body: child));
}

void main() {
  group('D3PhotoGallery.viewerActionsBuilder', () {
    testWidgets('forwards actions into the pushed viewer, keyed by the '
        'tapped index', (tester) async {
      await tester.pumpWidget(
        _wrap(
          D3PhotoGallery(
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
          const D3PhotoGallery(
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
          D3PhotoGallery(
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

  group('D3PhotoGallery.viewerResolveImage', () {
    testWidgets('forwards into the pushed viewer, called for the tapped '
        'index', (tester) async {
      final calledFor = <int>[];
      await tester.pumpWidget(
        _wrap(
          D3PhotoGallery(
            photoPaths: const ['a.png', 'b.png'],
            itemLabel: 'Test item',
            viewerResolveImage: (index) async {
              calledFor.add(index);
              return D3ImageSource.local('resolved-$index.png');
            },
          ),
        ),
      );

      await tester.tap(find.byType(GestureDetector).at(1));
      await tester.pumpAndSettle();

      expect(calledFor, [1]);
    });

    testWidgets('omitting it changes nothing from before it existed', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const D3PhotoGallery(
            photoPaths: ['a.png'],
            itemLabel: 'Test item',
          ),
        ),
      );

      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();

      expect(find.byType(D3ImageViewer), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('D3PhotoGallery.thumbnailResolveImage', () {
    testWidgets('shows photoPaths\' own entry immediately, then swaps once '
        'resolved', (tester) async {
      var release = false;
      await tester.pumpWidget(
        _wrap(
          D3PhotoGallery(
            photoPaths: const ['a.png'],
            itemLabel: 'Test item',
            thumbnailResolveImage: (index) async {
              while (!release) {
                await Future<void>.delayed(const Duration(milliseconds: 1));
              }
              return 'resolved.png';
            },
          ),
        ),
      );
      await tester.pump();

      var image = tester.widget<Image>(find.byType(Image));
      expect((image.image as FileImage).file.path, 'a.png');

      release = true;
      await tester.pumpAndSettle();

      image = tester.widget<Image>(find.byType(Image));
      expect((image.image as FileImage).file.path, 'resolved.png');
    });

    testWidgets('is called once per thumbnail with its own index', (
      tester,
    ) async {
      final calledFor = <int>[];
      await tester.pumpWidget(
        _wrap(
          D3PhotoGallery(
            photoPaths: const ['a.png', 'b.png'],
            itemLabel: 'Test item',
            thumbnailResolveImage: (index) async {
              calledFor.add(index);
              return 'r$index.png';
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(calledFor, [0, 1]);
    });

    testWidgets('omitting it shows the plain photoPaths entry unchanged', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const D3PhotoGallery(
            photoPaths: ['a.png'],
            itemLabel: 'Test item',
          ),
        ),
      );
      await tester.pumpAndSettle();

      final image = tester.widget<Image>(find.byType(Image));
      expect((image.image as FileImage).file.path, 'a.png');
    });

    testWidgets('a resolver identity change alone (same path) does not '
        'retrigger resolution', (tester) async {
      var callCount = 0;
      Future<String> resolver(int index) async {
        callCount++;
        return 'r.png';
      }

      await tester.pumpWidget(
        _wrap(
          D3PhotoGallery(
            photoPaths: const ['a.png'],
            itemLabel: 'Test item',
            thumbnailResolveImage: resolver,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(callCount, 1);

      // A fresh closure each time, same underlying photoPaths -- mirrors
      // an inline lambda passed anew on every parent rebuild.
      await tester.pumpWidget(
        _wrap(
          D3PhotoGallery(
            photoPaths: const ['a.png'],
            itemLabel: 'Test item',
            thumbnailResolveImage: (index) async {
              callCount++;
              return 'r.png';
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(callCount, 1);
    });
  });

  group('D3PhotoGalleryState.refreshThumbnail', () {
    testWidgets('re-runs thumbnailResolveImage for that index, swapping '
        'the displayed image even though photoPaths itself did not '
        'change', (tester) async {
      var resolvedValue = 'first.png';
      final key = GlobalKey<D3PhotoGalleryState>();

      await tester.pumpWidget(
        _wrap(
          D3PhotoGallery(
            key: key,
            photoPaths: const ['a.png'],
            itemLabel: 'Test item',
            thumbnailResolveImage: (index) async => resolvedValue,
          ),
        ),
      );
      await tester.pumpAndSettle();

      var image = tester.widget<Image>(find.byType(Image));
      expect((image.image as FileImage).file.path, 'first.png');

      resolvedValue = 'second.png';
      key.currentState!.refreshThumbnail(0);
      await tester.pumpAndSettle();

      image = tester.widget<Image>(find.byType(Image));
      expect((image.image as FileImage).file.path, 'second.png');
    });

    testWidgets('an out-of-range index is a no-op, not a crash', (
      tester,
    ) async {
      final key = GlobalKey<D3PhotoGalleryState>();
      await tester.pumpWidget(
        _wrap(
          D3PhotoGallery(
            key: key,
            photoPaths: const ['a.png'],
            itemLabel: 'Test item',
          ),
        ),
      );
      await tester.pumpAndSettle();

      key.currentState!.refreshThumbnail(5);
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });

  group('D3PhotoGalleryState.replaceThumbnail', () {
    testWidgets('shows the given path directly, without calling '
        'thumbnailResolveImage', (tester) async {
      var resolveCallCount = 0;
      final key = GlobalKey<D3PhotoGalleryState>();

      await tester.pumpWidget(
        _wrap(
          D3PhotoGallery(
            key: key,
            photoPaths: const ['a.png'],
            itemLabel: 'Test item',
            thumbnailResolveImage: (index) async {
              resolveCallCount++;
              return 'resolved.png';
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(resolveCallCount, 1);

      key.currentState!.replaceThumbnail(0, 'direct.png');
      await tester.pump();

      final image = tester.widget<Image>(find.byType(Image));
      expect((image.image as FileImage).file.path, 'direct.png');
      // Still 1 -- replaceThumbnail must not trigger another resolve.
      expect(resolveCallCount, 1);
    });

    testWidgets('an out-of-range index is a no-op, not a crash', (
      tester,
    ) async {
      final key = GlobalKey<D3PhotoGalleryState>();
      await tester.pumpWidget(
        _wrap(
          D3PhotoGallery(
            key: key,
            photoPaths: const ['a.png'],
            itemLabel: 'Test item',
          ),
        ),
      );
      await tester.pumpAndSettle();

      key.currentState!.replaceThumbnail(5, 'z.png');
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });

  group('layout wraps instead of scrolling', () {
    // Regression coverage for an on-device report: with the previous
    // single-row, horizontally-scrolling layout, the add-photo tile
    // (always the last item) scrolled off-screen once enough
    // thumbnails filled the visible width, with no visual hint it was
    // still reachable -- effectively undiscoverable once an item
    // already had a handful of photos. A Wrap has no such off-screen
    // state: every child, including the add tile, is laid out and
    // present in the tree regardless of count.
    testWidgets('every thumbnail and the add tile are all present at '
        'once, not just the ones that would fit in one scrolling row', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          D3PhotoGallery(
            photoPaths: List.generate(12, (i) => 'photo$i.png'),
            itemLabel: 'Test item',
            onAdd: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Image), findsNWidgets(12));
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('uses Wrap, not a scrolling ListView', (tester) async {
      await tester.pumpWidget(
        _wrap(
          D3PhotoGallery(
            photoPaths: List.generate(12, (i) => 'photo$i.png'),
            itemLabel: 'Test item',
            onAdd: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Wrap), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });
  });
}
