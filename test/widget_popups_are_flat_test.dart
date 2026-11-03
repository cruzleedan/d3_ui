import 'package:d3_ui/d3_ui.dart';
import 'package:d3_ui/src/components/actions/d3_menu.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Popups are flat in D3 (DESIGN.md "Elevation & Depth"): a tonal fill and a
/// 1 px outline, never a shadow.
void main() {
  for (final dark in [false, true]) {
    final name = dark ? 'dark' : 'light';
    final theme = dark ? D3AppTheme.dark() : D3AppTheme.light();

    Widget app(Widget body) => MaterialApp(
      theme: theme,
      home: Scaffold(
        body: Align(alignment: Alignment.topLeft, child: body),
      ),
    );

    void expectFlat(WidgetTester t, Finder inside) {
      final colors = t.element(inside).d3Colors;
      final materials = t
          .widgetList<Material>(
            find.ancestor(of: inside, matching: find.byType(Material)),
          )
          .toList();
      final panel = materials.firstWhere(
        (m) => m.shape is RoundedRectangleBorder,
      );
      expect(panel.elevation, 0, reason: 'no drop shadow');
      expect(panel.color, colors.surfaceContainerLow);
      final side = (panel.shape! as RoundedRectangleBorder).side;
      expect(side.color, colors.outlineVariant);
      expect(side.width, greaterThan(0));
    }

    testWidgets('D3Menu panel is flat ($name)', (t) async {
      await t.pumpWidget(
        app(
          D3Menu(
            triggerBuilder: (context, toggle) =>
                TextButton(onPressed: toggle, child: const Text('open')),
            entries: [D3MenuItem(label: 'One', onPressed: () {})],
          ),
        ),
      );
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      expectFlat(t, find.text('One'));
    });

    testWidgets('a raw PopupMenuButton is flat ($name)', (t) async {
      await t.pumpWidget(
        app(
          PopupMenuButton<int>(
            itemBuilder: (_) => const [
              PopupMenuItem(value: 1, child: Text('One')),
            ],
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Text('open'),
            ),
          ),
        ),
      );
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      expectFlat(t, find.text('One'));
    });

    testWidgets('a raw showMenu is flat ($name)', (t) async {
      await t.pumpWidget(
        app(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => showMenu<int>(
                context: context,
                position: const RelativeRect.fromLTRB(0, 60, 0, 0),
                items: const [PopupMenuItem(value: 1, child: Text('One'))],
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      expectFlat(t, find.text('One'));
    });
  }
}
