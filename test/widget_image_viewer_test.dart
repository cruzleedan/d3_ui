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

    testWidgets('shows a loading spinner over the placeholder while '
        'resolveImage is in flight, gone once it resolves', (tester) async {
      // Regression coverage: showing the placeholder at full strength
      // as if it were final (no loading indication at all) read as a
      // flicker on-device for a resolver whose real output looks
      // meaningfully different from the placeholder -- e.g. a raw
      // photo swapping to the same photo with annotations drawn on it.
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
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      resolveCompleter.complete(
        const D3ImageSource.network('https://example.com/resolved.png'),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
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

  group('swipe down to dismiss', () {
    // Pushed on top of a base screen (rather than _wrap's bare `home:`)
    // so a successful dismiss has somewhere to pop back to -- otherwise
    // Navigator.maybePop would have nothing to observe.
    Future<void> pumpPushed(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: D3AppTheme.light(),
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => D3ImageViewer(
                        images: const [
                          D3ImageSource.network('https://example.com/a.png'),
                        ],
                      ),
                    ),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.byType(D3ImageViewer), findsOneWidget);
    }

    testWidgets('a drag past the threshold dismisses the viewer', (
      tester,
    ) async {
      await pumpPushed(tester);

      await tester.drag(find.byType(D3ImageViewer), const Offset(0, 200));
      await tester.pumpAndSettle();

      expect(find.byType(D3ImageViewer), findsNothing);
      expect(find.text('Open'), findsOneWidget);
    });

    testWidgets('a short drag snaps back instead of dismissing', (
      tester,
    ) async {
      await pumpPushed(tester);

      await tester.drag(find.byType(D3ImageViewer), const Offset(0, 40));
      await tester.pumpAndSettle();

      expect(find.byType(D3ImageViewer), findsOneWidget);
    });

    testWidgets('mid-drag, the AppBar moves with the image -- the whole '
        'screen drags together, not just the photo', (tester) async {
      await pumpPushed(tester);

      final appBarBefore = tester.getTopLeft(find.byType(AppBar));

      // Two incremental moves rather than one large jump -- a single
      // moveBy past the touch-slop threshold in one step is not how a
      // real drag is ever actually delivered (always many small
      // pointer-move events) and, empirically, doesn't reliably cross
      // VerticalDragGestureRecognizer's own slop-then-accept sequence
      // in this test binding either. tester.drag (used by the other
      // tests in this group) already breaks a drag into multiple
      // moveBy calls under the hood for the same reason.
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(D3ImageViewer)),
      );
      await gesture.moveBy(const Offset(0, 20));
      await tester.pump();
      await gesture.moveBy(const Offset(0, 40));
      await tester.pump();

      final appBarDuring = tester.getTopLeft(find.byType(AppBar));
      expect(appBarDuring.dy, greaterThan(appBarBefore.dy));

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('a second pointer joining mid-drag stops the dismiss '
        'gesture from continuing to track the first', (tester) async {
      await pumpPushed(tester);

      final appBarBefore = tester.getTopLeft(find.byType(AppBar));
      final center = tester.getCenter(find.byType(D3ImageViewer));

      final first = await tester.startGesture(center);
      await first.moveBy(const Offset(0, 20));
      await tester.pump();
      await first.moveBy(const Offset(0, 40));
      await tester.pump();

      final appBarMidDrag = tester.getTopLeft(find.byType(AppBar));
      // Sanity check: the drag was genuinely progressing before the
      // second pointer arrives, so the assertion below is meaningful.
      expect(appBarMidDrag.dy, greaterThan(appBarBefore.dy));

      // A second finger touches down elsewhere on the image -- the
      // start of what would be a pinch. InteractiveViewer's own
      // onInteractionUpdate reports the resulting pointerCount == 2
      // from here on, which _onInteractionUpdate treats as "no longer
      // a single-finger dismiss drag" (see _dragIsSingleFinger).
      final second = await tester.startGesture(center + const Offset(40, 0));
      await tester.pump();

      // The first finger keeps moving, as it would mid-pinch. If the
      // pointerCount check above were missing, the AppBar would keep
      // sliding down with it.
      final appBarAtRejection = tester.getTopLeft(find.byType(AppBar));
      await first.moveBy(const Offset(0, 40));
      await tester.pump();
      final appBarAfterSecondPointer = tester.getTopLeft(find.byType(AppBar));

      expect(appBarAfterSecondPointer.dy, appBarAtRejection.dy);

      await first.up();
      await second.up();
      await tester.pumpAndSettle();
    });

    testWidgets('a genuine two-finger pinch still zooms the image', (
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
      await tester.pumpAndSettle();
      final center = tester.getCenter(find.byType(D3ImageViewer));

      final p1 = await tester.startGesture(center - const Offset(20, 0));
      final p2 = await tester.startGesture(center + const Offset(20, 0));
      await tester.pump();

      // Incremental moves spreading the fingers apart, matching how a
      // real pinch (and every other gesture in this file) is delivered
      // -- a single large jump doesn't reliably cross
      // ScaleGestureRecognizer's own detection threshold in this
      // binding either, the same lesson as the drag tests above.
      for (var i = 0; i < 10; i++) {
        await p1.moveBy(const Offset(-10, 0));
        await p2.moveBy(const Offset(10, 0));
        await tester.pump();
      }
      await p1.up();
      await p2.up();
      await tester.pumpAndSettle();

      final interactiveViewer = tester.widget<InteractiveViewer>(
        find.byType(InteractiveViewer),
      );
      final scale = interactiveViewer.transformationController!.value
          .getMaxScaleOnAxis();
      expect(scale, greaterThan(1.01));
    });

    testWidgets('dismiss still works after an earlier horizontal swipe '
        'attempt', (tester) async {
      // Regression coverage for an on-device report: swipe-to-dismiss
      // became unreliable after a horizontal page-swipe attempt had
      // happened first. Under the current architecture (driven by
      // InteractiveViewer's own onInteractionStart/Update/End, not a
      // sibling recognizer competing for the same pointer -- see
      // _D3ViewerPage's doc comment) there is no separate
      // pointer-tracking state of this widget's own left to go stale,
      // but this still exercises the same real user sequence end to
      // end.
      await tester.pumpWidget(
        MaterialApp(
          theme: D3AppTheme.light(),
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => D3ImageViewer(
                        images: const [
                          D3ImageSource.network('https://example.com/a.png'),
                          D3ImageSource.network('https://example.com/b.png'),
                        ],
                      ),
                    ),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // A horizontal swipe attempt -- InteractiveViewer reports it via
      // onInteractionStart/Update/End the same as any other
      // single-finger interaction.
      final horizontal = await tester.startGesture(
        tester.getCenter(find.byType(D3ImageViewer)),
      );
      await horizontal.moveBy(const Offset(-20, 0));
      await tester.pump();
      await horizontal.moveBy(const Offset(-40, 0));
      await tester.pump();
      await horizontal.up();
      await tester.pumpAndSettle();

      // Now a genuine, separate single-finger vertical drag -- must
      // still dismiss normally.
      await tester.drag(find.byType(D3ImageViewer), const Offset(0, 200));
      await tester.pumpAndSettle();

      expect(find.byType(D3ImageViewer), findsNothing);
      expect(find.text('Open'), findsOneWidget);
    });

    testWidgets('paging via the nav arrow still works, unaffected by the '
        'dismiss gesture', (tester) async {
      // A plain drag on the viewer is claimed by InteractiveViewer's own
      // pan handling before it reaches PageView (true with or without
      // the dismiss gesture -- confirmed by reproducing the same result
      // against this file's pre-dismiss-gesture code), so paging in
      // every other test in this file goes through the nav arrow
      // instead of a drag. This test exists to confirm that path is
      // still intact after adding the vertical-drag recognizer.
      await tester.pumpWidget(
        _wrap(
          D3ImageViewer(
            images: const [
              D3ImageSource.network('https://example.com/a.png'),
              D3ImageSource.network('https://example.com/b.png'),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();

      expect(find.text('2 / 2'), findsOneWidget);
    });
  });

  group('D3ImageViewer.push', () {
    testWidgets('pushes a non-opaque route -- the base screen stays in '
        'the tree underneath, not disposed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: D3AppTheme.light(),
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => D3ImageViewer.push(
                    context,
                    images: const [
                      D3ImageSource.network('https://example.com/a.png'),
                    ],
                  ),
                  child: const Text('base screen marker'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('base screen marker'));
      await tester.pumpAndSettle();

      expect(find.byType(D3ImageViewer), findsOneWidget);
      // Still present (just obscured), not popped off the tree --
      // exactly what a non-opaque route preserves and a normal opaque
      // MaterialPageRoute would not guarantee.
      expect(find.text('base screen marker'), findsOneWidget);
    });

    testWidgets('dismissing pops back to the base screen', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: D3AppTheme.light(),
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => D3ImageViewer.push(
                    context,
                    images: const [
                      D3ImageSource.network('https://example.com/a.png'),
                    ],
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.drag(find.byType(D3ImageViewer), const Offset(0, 200));
      await tester.pumpAndSettle();

      expect(find.byType(D3ImageViewer), findsNothing);
      expect(find.text('Open'), findsOneWidget);
    });
  });

  group('double tap to zoom', () {
    Future<void> doubleTapAt(WidgetTester tester, Offset location) async {
      // Two taps close enough together in time for the framework's
      // DoubleTapGestureRecognizer to treat them as one double tap,
      // rather than two independent single taps -- there is no
      // dedicated WidgetTester helper for this, so it's built from two
      // tapAt calls with a short gap.
      await tester.tapAt(location);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tapAt(location);
      await tester.pump();
    }

    testWidgets('zooms in on double tap, back out on a second double tap', (
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
      await tester.pumpAndSettle();

      final center = tester.getCenter(find.byType(D3ImageViewer));

      await doubleTapAt(tester, center);
      await tester.pump(const Duration(milliseconds: 250));

      var interactiveViewer = tester.widget<InteractiveViewer>(
        find.byType(InteractiveViewer),
      );
      var scale = interactiveViewer.transformationController!.value
          .getMaxScaleOnAxis();
      expect(scale, greaterThan(1.01));

      await doubleTapAt(tester, center);
      await tester.pump(const Duration(milliseconds: 250));

      interactiveViewer = tester.widget<InteractiveViewer>(
        find.byType(InteractiveViewer),
      );
      scale = interactiveViewer.transformationController!.value
          .getMaxScaleOnAxis();
      expect(scale, closeTo(1.0, 0.01));
    });
  });

  group('reset zoom button', () {
    testWidgets('disabled at 1x, enabled once zoomed, resets on tap', (
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
      await tester.pumpAndSettle();

      IconButton resetButton() =>
          tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.zoom_out_map));

      expect(resetButton().onPressed, isNull);

      final interactiveViewer = tester.widget<InteractiveViewer>(
        find.byType(InteractiveViewer),
      );
      interactiveViewer.transformationController!.value = Matrix4.identity()
        ..scaleByDouble(2.5, 2.5, 2.5, 1);
      await tester.pump();

      expect(resetButton().onPressed, isNotNull);

      await tester.tap(find.widgetWithIcon(IconButton, Icons.zoom_out_map));
      // A single large-duration pump right after the tap does not
      // reliably advance the reset animation in this test binding
      // (confirmed by reproduction -- the animation ticks correctly
      // with two smaller pumps but not one large one covering the same
      // total elapsed time), so it's pumped in two steps here instead.
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 200));

      final scale = interactiveViewer.transformationController!.value
          .getMaxScaleOnAxis();
      expect(scale, closeTo(1.0, 0.01));
      expect(resetButton().onPressed, isNull);
    });
  });
}
