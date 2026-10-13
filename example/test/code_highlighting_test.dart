import 'dart:ui' show Brightness;

import 'package:d3_ui/d3_ui.dart';
import 'package:d3_ui_example/showcase/code_highlighting.dart';
import 'package:d3_ui_example/showcase/generated/example_sources.g.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

String _text(InlineSpan span) {
  final buffer = StringBuffer();
  span.visitChildren((s) {
    if (s is TextSpan && s.text != null) buffer.write(s.text);
    return true;
  });
  return buffer.toString();
}

Set<Color> _colors(InlineSpan span) {
  final colors = <Color>{};
  span.visitChildren((s) {
    final color = s.style?.color;
    if (color != null) colors.add(color);
    return true;
  });
  return colors;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(CodeHighlighting.load);

  test('every example highlights, and the text is unchanged', () {
    for (final brightness in Brightness.values) {
      for (final entry in exampleSources.entries) {
        final span = CodeHighlighting.spans(entry.value, brightness)!;
        expect(_text(span), entry.value, reason: '${entry.key} $brightness');
        expect(
          _colors(span).length,
          greaterThan(2),
          reason: '${entry.key} has more than one colour',
        );
      }
    }
  });

  for (final brightness in Brightness.values) {
    test('every colour used reads on the panel (${brightness.name}, 4:1)', () {
      // Dark+ keeps its comment green at 4.2:1 on purpose (VS Code's own
      // value), so the bar is 4:1 rather than 4.5:1.
      final background = CodeHighlighting.panel(brightness).background;
      for (final source in exampleSources.values) {
        for (final color in _colors(
          CodeHighlighting.spans(source, brightness)!,
        )) {
          expect(
            d3ContrastRatio(color, background),
            greaterThanOrEqualTo(4.0),
            reason: '$color on ${brightness.name}',
          );
        }
      }
    });
  }
}
