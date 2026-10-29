import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:d3_ui/d3_ui.dart';

Widget _wrap(Widget child, {Widget? bottom}) => MaterialApp(
  theme: D3AppTheme.light(),
  home: Scaffold(
    bottomNavigationBar: bottom,
    body: Center(child: child),
  ),
);

Finder _ink(Finder control) => find.descendant(
  of: control,
  matching: find.byWidgetPredicate((w) => w is InkWell || w is InkResponse),
);

/// Asserts [control] contains an ink widget, that a held press paints
/// without error, and that a tap still reaches the callback.
Future<void> _check(
  WidgetTester tester, {
  required Finder control,
  required Finder target,
  required int Function() taps,
}) async {
  expect(_ink(control), findsWidgets);
  final gesture = await tester.startGesture(tester.getCenter(target));
  await tester.pump(const Duration(milliseconds: 150));
  await gesture.up();
  await tester.pumpAndSettle();
  expect(taps(), 1);
}

void main() {
  testWidgets('D3NavBar item shows ink and taps', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _wrap(
        const SizedBox(),
        bottom: D3NavBar(
          selectedIndex: 0,
          onTabSelected: (_) => taps++,
          items: const [
            D3NavItem(icon: Icons.home_outlined, label: 'Home'),
            D3NavItem(icon: Icons.search_outlined, label: 'Explore'),
          ],
        ),
      ),
    );
    await _check(
      tester,
      control: find.byType(D3NavBar),
      target: find.text('Explore'),
      taps: () => taps,
    );
  });

  testWidgets('D3NavBar centre action shows ink and taps', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _wrap(
        const SizedBox(),
        bottom: D3NavBar(
          selectedIndex: 0,
          onTabSelected: (_) {},
          items: const [
            D3NavItem(icon: Icons.home_outlined, label: 'Home'),
            D3NavItem(icon: Icons.search_outlined, label: 'Explore'),
          ],
          centerAction: D3NavBarCenterAction(
            icon: Icons.add,
            onPressed: () => taps++,
          ),
        ),
      ),
    );
    await _check(
      tester,
      control: find.byType(D3NavBar),
      target: find.byIcon(Icons.add),
      taps: () => taps,
    );
  });

  testWidgets('D3Screen icon action shows ink and taps', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: D3AppTheme.light(),
        home: D3Screen(
          title: 'T',
          leading: D3ScreenLeading.none,
          actions: [D3ScreenAction.icon(Icons.edit, onPressed: () => taps++)],
          body: const SizedBox(),
        ),
      ),
    );
    await _check(
      tester,
      control: find.byType(D3Screen),
      target: find.byIcon(Icons.edit),
      taps: () => taps,
    );
  });

  testWidgets('D3Screen text action shows ink and taps', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: D3AppTheme.light(),
        home: D3Screen(
          title: 'T',
          leading: D3ScreenLeading.none,
          actions: [D3ScreenAction.text('Save', onPressed: () => taps++)],
          body: const SizedBox(),
        ),
      ),
    );
    await _check(
      tester,
      control: find.byType(D3Screen),
      target: find.text('Save'),
      taps: () => taps,
    );
  });

  testWidgets('D3Screen cancel button shows ink and pops', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: D3AppTheme.light(),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => D3Screen(
                  title: 'Sheet',
                  leading: D3ScreenLeading.cancel,
                  body: const SizedBox(),
                ),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(_ink(find.byType(D3Screen)), findsWidgets);
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Cancel')),
    );
    await tester.pump(const Duration(milliseconds: 150));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.byType(D3Screen), findsNothing);
  });

  testWidgets('D3SegmentedControl segment shows press feedback and taps', (
    tester,
  ) async {
    Object? picked;
    await tester.pumpWidget(
      _wrap(
        D3SegmentedControl<int>(
          segments: const [
            D3Segment(value: 1, label: 'One'),
            D3Segment(value: 2, label: 'Two'),
          ],
          selected: 1,
          onChanged: (v) => picked = v,
        ),
      ),
    );
    // The control is a sliding segmented control, which answers a press with
    // its thumb and a pressed fill rather than an ink splash, so there is no
    // ink widget to look for: check that a held press paints and a tap lands.
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Two')),
    );
    await tester.pump(const Duration(milliseconds: 150));
    expect(tester.takeException(), isNull);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(picked, 2);
  });

  testWidgets('D3HyperlinkButton shows ink and taps', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _wrap(D3HyperlinkButton(label: 'Link', onPressed: () => taps++)),
    );
    await _check(
      tester,
      control: find.byType(D3HyperlinkButton),
      target: find.text('Link'),
      taps: () => taps,
    );
  });

  testWidgets('D3ScrimIconButton shows ink and taps', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _wrap(
        D3ScrimIconButton(
          icon: Icons.close,
          semanticsLabel: 'Close',
          onTap: () => taps++,
        ),
      ),
    );
    await _check(
      tester,
      control: find.byType(D3ScrimIconButton),
      target: find.byIcon(Icons.close),
      taps: () => taps,
    );
  });

  testWidgets('D3PosterCard shows ink and taps', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _wrap(
        SizedBox(
          width: 150,
          height: 220,
          child: D3PosterCard(
            imageUrl: '',
            title: 'Poster',
            onTap: () => taps++,
          ),
        ),
      ),
    );
    await _check(
      tester,
      control: find.byType(D3PosterCard),
      target: find.byType(D3PosterCard),
      taps: () => taps,
    );
  });

  testWidgets('D3TabBar tabs show ink and tap', (tester) async {
    int? tapped;
    await tester.pumpWidget(
      _wrap(
        DefaultTabController(
          length: 2,
          child: D3TabBar(
            tabs: const [
              Tab(text: 'A'),
              Tab(text: 'B'),
            ],
            onTap: (i) => tapped = i,
          ),
        ),
      ),
    );
    await _check(
      tester,
      control: find.byType(D3TabBar),
      target: find.text('B'),
      taps: () => tapped == 1 ? 1 : 0,
    );
  });

  testWidgets('read-only D3SearchBar shows ink and taps', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _wrap(D3SearchBar(readOnly: true, onTap: () => taps++)),
    );
    await _check(
      tester,
      control: find.byType(D3SearchBar),
      target: find.byIcon(Icons.search_rounded),
      taps: () => taps,
    );
  });
}
