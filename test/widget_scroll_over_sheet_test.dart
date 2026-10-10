import 'package:d3_ui/d3_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Widget _host(Widget child) => MaterialApp(
  theme: D3AppTheme.light(),
  home: Scaffold(body: child),
);

void main() {
  group('D3ScrollOverSheetScaffold', () {
    final anchorKey = GlobalKey();
    final stickyKey = GlobalKey();
    D3ScrollOverSheetState? last;

    Widget scaffold() => _host(
      D3ScrollOverSheetScaffold(
        topBarContentHeight: 56,
        anchorKey: anchorKey,
        stickyPlaceholderKey: stickyKey,
        stickyHeight: 40,
        sticky: const ColoredBox(color: Colors.red, child: Text('STICKY')),
        topBar: (context, state) {
          last = state;
          return const SizedBox();
        },
        page: const SizedBox(height: 400, child: Text('PAGE')),
        sheet: ColoredBox(
          color: Colors.blue,
          child: Column(
            children: [
              SizedBox(key: anchorKey, height: 48, child: const Text('ANCHOR')),
              SizedBox(key: stickyKey, height: 40),
              const SizedBox(height: 100, child: Text('SHEET BODY')),
            ],
          ),
        ),
      ),
    );

    testWidgets('page moves at half pace, sheet 1:1', (tester) async {
      await tester.pumpWidget(scaffold());
      await tester.pumpAndSettle();
      final pageTop = tester.getTopLeft(find.text('PAGE')).dy;
      final sheetTop = tester.getTopLeft(find.text('SHEET BODY')).dy;

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -100));
      await tester.pumpAndSettle();

      expect(pageTop - tester.getTopLeft(find.text('PAGE')).dy, closeTo(50, 1));
      expect(
        sheetTop - tester.getTopLeft(find.text('SHEET BODY')).dy,
        closeTo(100, 1),
      );
    });

    testWidgets('scrolled fully up: anchor is behind the bar, progress is 1, '
        'sticky pins under the bar', (tester) async {
      await tester.pumpWidget(scaffold());
      await tester.pumpAndSettle();
      expect(last!.anchorHidden, isFalse);
      expect(last!.progress, 0);

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -3000));
      await tester.pumpAndSettle();

      expect(last!.anchorHidden, isTrue);
      expect(last!.progress, 1);
      expect(
        tester.getTopLeft(find.text('STICKY')).dy,
        closeTo(last!.barHeight, 1),
      );
    });
  });

  group('D3SectionTabsController', () {
    testWidgets('scrollTo brings a section under the pinned area and selects '
        'its tab; scrolling selects the tab again', (tester) async {
      final scroll = ScrollController();
      late D3SectionTabsController tabs;
      await tester.pumpWidget(
        _host(
          StatefulBuilder(
            builder: (context, setState) {
              return _TabsHost(scroll: scroll, onReady: (t) => tabs = t);
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tabs.tabController!.index, 0);

      final done = tabs.scrollTo(2);
      await tester.pumpAndSettle();
      await done;
      expect(tabs.tabController!.index, 2);
      expect(tester.getTopLeft(find.text('Section c')).dy, lessThan(120));

      scroll.jumpTo(0);
      await tester.pumpAndSettle();
      expect(tabs.tabController!.index, 0);
      tabs.dispose();
    });

    testWidgets('zero sections is allowed', (tester) async {
      late D3SectionTabsController tabs;
      await tester.pumpWidget(
        _host(
          _TabsHost(
            scroll: ScrollController(),
            ids: const [],
            onReady: (t) => tabs = t,
          ),
        ),
      );
      expect(tabs.tabController!.length, 0);
    });
  });

  group('components', () {
    testWidgets('D3SectionHeader.label shows just the label', (tester) async {
      await tester.pumpWidget(
        _host(const D3SectionHeader.label(label: 'TERMS')),
      );
      expect(find.text('TERMS'), findsOneWidget);
    });

    testWidgets('D3ScrimIconButton is a labelled button that taps', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(
        _host(
          D3ScrimIconButton(
            icon: Icons.arrow_back,
            semanticsLabel: 'Back',
            onTap: () => taps++,
          ),
        ),
      );
      await tester.tap(find.bySemanticsLabel('Back'));
      expect(taps, 1);
    });

    testWidgets('D3TicketCard grows with text scale without overflowing', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: D3AppTheme.light(),
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2)),
            child: const Scaffold(
              body: Center(
                child: D3TicketCard(
                  title: 'A rather long headline for a small card',
                  primaryLine: 'Until 3:00 PM',
                  secondaryLine: 'Dine-in · Takeaway · ₱500 min',
                ),
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(D3TicketCard)).height, 160);
    });

    testWidgets('D3ThumbnailCard shows title, description, badge, trailing', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const D3ThumbnailCard(
            title: 'Tonkotsu',
            description: 'Pork bone broth',
            badge: '20% off',
            trailing: Text('₱420'),
          ),
        ),
      );
      for (final t in ['Tonkotsu', 'Pork bone broth', '20% off', '₱420']) {
        expect(find.text(t), findsOneWidget);
      }
    });

    testWidgets('D3InfoCard lays out rows', (tester) async {
      await tester.pumpWidget(
        _host(
          D3InfoCard(
            children: [
              D3InfoRow.text(icon: Icons.place, text: 'Poblacion'),
              D3InfoRow.text(icon: Icons.schedule, text: 'Open now'),
            ],
          ),
        ),
      );
      expect(find.text('Poblacion'), findsOneWidget);
      expect(find.text('Open now'), findsOneWidget);
    });
  });
}

class _TabsHost extends StatefulWidget {
  const _TabsHost({
    required this.scroll,
    required this.onReady,
    this.ids = const ['a', 'b', 'c'],
  });

  final ScrollController scroll;
  final void Function(D3SectionTabsController) onReady;
  final List<String> ids;

  @override
  State<_TabsHost> createState() => _TabsHostState();
}

class _TabsHostState extends State<_TabsHost> with TickerProviderStateMixin {
  late final D3SectionTabsController tabs = D3SectionTabsController(
    vsync: this,
    scrollController: widget.scroll,
    stickyBottom: () => 100,
  );

  @override
  Widget build(BuildContext context) {
    tabs.setSections(widget.ids);
    widget.onReady(tabs);
    // Not a lazy ListView: every section must be built to be measured.
    return SingleChildScrollView(
      controller: widget.scroll,
      child: Column(
        children: [
          for (final id in widget.ids) ...[
            SizedBox(
              key: tabs.keyFor(id),
              height: 40,
              child: Text('Section $id'),
            ),
            const SizedBox(height: 700),
          ],
        ],
      ),
    );
  }
}
