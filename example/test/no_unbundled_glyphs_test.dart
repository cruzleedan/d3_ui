import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The showcase must not request a font from a third party at run time. Roboto
/// (bundled) lacks some symbols, and Flutter then fetches a fallback from Google
/// Fonts. This test fails on such characters in the showcase's own text.
void main() {
  test('showcase text has no symbols missing from the bundled fonts', () {
    // Symbols found in the wild that Roboto does not have (and that look like
    // plain text to a reviewer): the command key, option key, shift key,
    // arrows keycaps, emoji.
    final risky = RegExp(
      '[\u2318\u2325\u21E7\u2303\u238B\u{1F300}-\u{1FAFF}\u2600-\u27BF]',
      unicode: true,
    );
    final offenders = <String>[];
    for (final dir in ['lib/showcase', 'lib/patterns']) {
      for (final file in Directory(dir)
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))) {
        final text = file.readAsStringSync();
        for (final m in risky.allMatches(text)) {
          offenders.add(
              '${file.path}: U+${m.group(0)!.runes.first.toRadixString(16)}');
        }
      }
    }
    expect(offenders, isEmpty,
        reason: 'Use words (Cmd, Ctrl) instead: $offenders');
  });
}
