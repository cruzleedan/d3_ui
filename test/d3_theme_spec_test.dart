import 'package:d3_ui/d3_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// The Food Finder merchant app's tokens (d3-ui-kit v0.5.0), as `design-tokens.json`
/// describes them.
const _json = '''
{
  "kit": "d3-ui-kit v0.5.0",
  "colors": {
    "light": {
      "background": {"hex": "#F6F5F2"}, "foreground": {"hex": "#1D1D1B"},
      "card": {"hex": "#FFFFFF"}, "primary": {"hex": "#B4441F"},
      "primary-foreground": {"hex": "#FFFFFF"},
      "secondary": {"hex": "#ECEBE7"}, "secondary-foreground": {"hex": "#1D1D1B"},
      "muted": {"hex": "#ECEBE7"}, "muted-foreground": {"hex": "#6B6A66"},
      "accent": {"hex": "#ECEBE7"}, "destructive": {"hex": "#B3261E"},
      "border": {"hex": "#DEDCD6"}, "input": {"hex": "#DEDCD6"}
    },
    "dark": {
      "background": {"hex": "#171716"}, "foreground": {"hex": "#EFEDE8"},
      "card": {"hex": "#222220"}, "primary": {"hex": "#E0714A"},
      "primary-foreground": {"hex": "#171716"},
      "secondary": {"hex": "#2E2E2B"}, "secondary-foreground": {"hex": "#EFEDE8"},
      "muted": {"hex": "#2E2E2B"}, "muted-foreground": {"hex": "#A3A19B"},
      "accent": {"hex": "#2E2E2B"}, "destructive": {"hex": "#F07A70"},
      "border": {"hex": "#3A3935"}, "input": {"hex": "#3A3935"}
    }
  },
  "status": {
    "success": {
      "light": {"text": "#008236", "tint": {"hex": "#00A63E", "opacity": 15}, "border": {"hex": "#00A63E", "opacity": 60}},
      "dark":  {"text": "#05DF72", "tint": {"hex": "#00A63E", "opacity": 15}, "border": {"hex": "#00C950", "opacity": 60}}
    },
    "warning": {
      "light": {"text": "#BB4D00", "tint": {"hex": "#FE9A00", "opacity": 15}, "border": {"hex": "#FE9A00", "opacity": 70}},
      "dark":  {"text": "#FFB900", "tint": {"hex": "#FE9A00", "opacity": 15}, "border": {"hex": "#FE9A00", "opacity": 70}}
    },
    "destructive": {
      "light": {"text": "#B3261E", "tint": {"hex": "#B3261E", "opacity": 10}, "border": {"hex": "#B3261E", "opacity": 50}},
      "dark":  {"text": "#F07A70", "tint": {"hex": "#F07A70", "opacity": 20}, "border": {"hex": "#F07A70", "opacity": 50}}
    },
    "neutral": {
      "light": {"text": "#6B6A66", "tint": "#ECEBE7", "border": "#DEDCD6"},
      "dark":  {"text": "#A3A19B", "tint": "#2E2E2B", "border": "#3A3935"}
    }
  },
  "radius": 10
}
''';

void main() {
  final spec = D3ThemeSpec.parse(_json);

  test('records the kit', () => expect(spec.kit, 'd3-ui-kit v0.5.0'));

  test('maps the colour roles onto the d3 tokens (light)', () {
    final c = spec.light.colors;
    expect(c.surface, const Color(0xFFF6F5F2));
    expect(c.onSurface, const Color(0xFF1D1D1B));
    expect(c.surfaceContainerLow, const Color(0xFFFFFFFF)); // card
    expect(c.primary, const Color(0xFFB4441F));
    expect(c.onPrimary, const Color(0xFFFFFFFF));
    expect(c.onSurfaceVariant, const Color(0xFF6B6A66));
    expect(c.outline, const Color(0xFFDEDCD6)); // input
    expect(c.outlineVariant, const Color(0xFFDEDCD6)); // border
    expect(c.error, const Color(0xFFB3261E));
    expect(c.onError, const Color(0xFFFFFFFF));
  });

  test('maps the dark roles, with dark text on the primary', () {
    final c = spec.dark.colors;
    expect(c.surface, const Color(0xFF171716));
    expect(c.surfaceContainerLow, const Color(0xFF222220));
    expect(c.primary, const Color(0xFFE0714A));
    expect(c.onPrimary, const Color(0xFF171716));
    expect(c.error, const Color(0xFFF07A70));
  });

  test('status colours keep their text, tint opacity and border', () {
    final s = spec.light.status;
    expect(s.success.text, const Color(0xFF008236));
    expect(s.success.tint.a, closeTo(0.15, 0.01));
    expect(s.warning.border.a, closeTo(0.7, 0.01));
    expect(s.neutral.tint, const Color(0xFFECEBE7));
    expect(spec.dark.status.destructive.tint.a, closeTo(0.2, 0.01));
  });

  test(
    'the radius base shifts the d3 scale: cards 14, sheets 18, fields 10',
    () {
      final shape = spec.light.shape;
      expect(shape.md, 10);
      expect(shape.lg, 14);
      expect(shape.xl, 18);
      expect(shape.cardBorder!.a, closeTo(0.1, 0.01));
    },
  );

  test('a partial file still builds a theme from the defaults', () {
    final partial = D3ThemeSpec.parse(
      '{"colors":{"light":{"primary":"#112233"}}}',
    );
    expect(partial.light.colors.primary, const Color(0xFF112233));
    expect(partial.light.colors.surface, D3ColorTokens.light.surface);
    expect(partial.dark.colors.primary, D3ColorTokens.dark.primary);
  });

  test('rejects a file that is not an object', () {
    expect(() => D3ThemeSpec.parse('[1,2]'), throwsFormatException);
  });

  testWidgets('the themes carry the tokens and the widgets use them', (
    tester,
  ) async {
    late BuildContext captured;
    await tester.pumpWidget(
      MaterialApp(
        theme: spec.lightTheme(),
        home: Scaffold(
          body: Builder(
            builder: (context) {
              captured = context;
              return const D3Card(title: 'Hello');
            },
          ),
        ),
      ),
    );
    expect(captured.d3Colors.primary, const Color(0xFFB4441F));
    expect(captured.d3Shape.lg, 14);
    expect(captured.d3Status.warning.text, const Color(0xFFBB4D00));
    expect(Theme.of(captured).scaffoldBackgroundColor, const Color(0xFFF6F5F2));
    // The card outline is the text colour at 10%, not the default.
    final material = tester.widget<Material>(
      find
          .descendant(of: find.byType(D3Card), matching: find.byType(Material))
          .first,
    );
    final side = (material.shape as RoundedRectangleBorder).side;
    expect(side.color.a, closeTo(0.1, 0.01));
  });

  test('d3 defaults are unchanged for an app that sets nothing', () {
    final theme = D3AppTheme.light();
    final ext = theme.extension<D3TokensExtension>()!;
    expect(ext.shapeTokens.lg, D3Radius.lg);
    expect(ext.shapeTokens.xl, D3Radius.xl);
    expect(ext.shapeTokens.cardBorder, isNull);
    expect(ext.colors.outlineVariant, ext.colors.outline);
  });

  test('readableTextOn lifts a status text that is a shade short of 4.5:1', () {
    final warning = spec.light.status.warning; // 4.48 on its tint
    final surface = spec.light.colors.surfaceContainerLow;
    final lifted = warning.readableTextOn(surface);
    expect(
      d3ContrastRatio(lifted, Color.alphaBlend(warning.tint, surface)),
      greaterThanOrEqualTo(4.5),
    );
  });
}
