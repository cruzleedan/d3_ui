import 'package:d3_ui/d3_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Widget _host(ThemeData theme, Widget child) => MaterialApp(
  theme: theme,
  home: Scaffold(body: Center(child: child)),
);

Color _fill(WidgetTester tester) {
  final box = tester.widget<DecoratedBox>(
    find.descendant(
      of: find.byType(D3Chip),
      matching: find.byType(DecoratedBox),
    ),
  );
  return (box.decoration as BoxDecoration).color!;
}

Color _labelColour(WidgetTester tester) =>
    tester.widget<Text>(find.text('Tag')).style!.color!;

void main() {
  for (final entry in {
    'light': D3AppTheme.light(),
    'dark': D3AppTheme.dark(),
  }.entries) {
    testWidgets('default tonal label reaches 4.5:1 (${entry.key})', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          entry.value,
          const D3Chip(label: 'Tag', variant: D3ChipVariant.tonal),
        ),
      );
      expect(
        d3ContrastRatio(
          _labelColour(tester),
          Color.alphaBlend(_fill(tester), entry.value.colorScheme.surface),
        ),
        greaterThanOrEqualTo(4.5),
      );
    });
  }

  testWidgets('tonal honours colour overrides', (tester) async {
    await tester.pumpWidget(
      _host(
        D3AppTheme.light(),
        const D3Chip(
          label: 'Tag',
          variant: D3ChipVariant.tonal,
          backgroundColor: Color(0xFFFFF3CD),
          foregroundColor: Color(0xFF222222),
        ),
      ),
    );
    expect(_fill(tester), const Color(0xFFFFF3CD));
    expect(_labelColour(tester), const Color(0xFF222222));
  });

  testWidgets('outlined honours colour overrides, border included', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        D3AppTheme.light(),
        const D3Chip(
          label: 'Tag',
          foregroundColor: Color(0xFF8A4B00),
          backgroundColor: Color(0xFFFFF3CD),
        ),
      ),
    );
    expect(_fill(tester), const Color(0xFFFFF3CD));
    expect(_labelColour(tester), const Color(0xFF8A4B00));
    final box = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byType(D3Chip),
        matching: find.byType(DecoratedBox),
      ),
    );
    expect(
      (box.decoration as BoxDecoration).border!.top.color,
      const Color(0xFF8A4B00),
    );
  });
}
