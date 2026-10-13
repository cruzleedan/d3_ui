import 'dart:ui' show Brightness;

import 'package:flutter/painting.dart';
import 'package:syntax_highlight/syntax_highlight.dart';

/// Syntax highlighting for the example code, with VS Code's Dark+ and Light+
/// themes (the `syntax_highlight` package, which reads TextMate grammars).
///
/// Start [load] at launch without waiting for it (the grammar takes a moment to
/// parse); until it finishes [spans] returns null and the code shows as plain
/// text, and anything that waited on [whenReady] repaints with colour.
class CodeHighlighting {
  CodeHighlighting._();

  static Highlighter? _light;
  static Highlighter? _dark;
  static final _cache = <(Brightness, String), TextSpan>{};

  static bool get isReady => _light != null && _dark != null;

  /// The editor-like colours of the code panel itself.
  static CodePanelColors panel(Brightness brightness) =>
      brightness == Brightness.dark
          ? CodePanelColors.dark
          : CodePanelColors.light;

  static Future<void>? _loading;

  /// Completes when the grammar and themes are loaded.
  static Future<void> get whenReady => load();

  static Future<void> load() => _loading ??= _load();

  static Future<void> _load() async {
    await Highlighter.initialize(['dart']);
    final themes = await Future.wait([
      HighlighterTheme.loadLightTheme(),
      HighlighterTheme.loadDarkTheme(),
    ]);
    _light = Highlighter(language: 'dart', theme: themes[0]);
    _dark = Highlighter(language: 'dart', theme: themes[1]);
  }

  /// The highlighted [source], or null when [load] has not finished.
  static TextSpan? spans(String source, Brightness brightness) {
    final highlighter = brightness == Brightness.dark ? _dark : _light;
    if (highlighter == null) return null;
    return _cache.putIfAbsent((brightness, source), () {
      final span = highlighter.highlight(source);
      return brightness == Brightness.dark ? span : _darkenBrackets(span);
    });
  }

  /// The package colours nested brackets with a fixed pastel palette made for
  /// dark backgrounds (contrast 1.9 to 3.2 on white). On the light theme, swap
  /// each for a darker colour of the same hue.
  static const _lightBrackets = <int, Color>{
    0xFF5CAEEF: Color(0xFF0B6BB5),
    0xFFDFB976: Color(0xFF8A6500),
    0xFFC172D9: Color(0xFF8E2BA8),
    0xFF4FB1BC: Color(0xFF00767F),
    0xFF97C26C: Color(0xFF3D7A1F),
    0xFFABB2C0: Color(0xFF5B6574),
  };

  static TextSpan _darkenBrackets(TextSpan span) {
    final color = span.style?.color;
    final swap = color == null ? null : _lightBrackets[color.toARGB32()];
    return TextSpan(
      text: span.text,
      style: swap == null ? span.style : span.style!.copyWith(color: swap),
      children: [
        for (final child in span.children ?? const <InlineSpan>[])
          child is TextSpan ? _darkenBrackets(child) : child,
      ],
    );
  }
}

/// Background, border and default text colour of the code panel.
class CodePanelColors {
  const CodePanelColors({
    required this.background,
    required this.border,
    required this.text,
    required this.accent,
  });

  final Color background;
  final Color border;
  final Color text;

  /// File icon and the "copied" tick.
  final Color accent;

  static const dark = CodePanelColors(
    background: Color(0xFF1E1E1E),
    border: Color(0xFF333333),
    text: Color(0xFFD4D4D4),
    accent: Color(0xFF4EC9B0),
  );

  static const light = CodePanelColors(
    background: Color(0xFFFFFFFF),
    border: Color(0xFFE0E0E0),
    text: Color(0xFF000000),
    accent: Color(0xFF1B6F86),
  );
}
