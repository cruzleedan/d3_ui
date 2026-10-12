import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Every public widget in the library must appear in the showcase (an example
/// or a page), so a new component cannot ship without being shown. A widget
/// that is deliberately not shown goes in [notShown] with the reason.
const notShown = <String, String>{};

void main() {
  test('every public d3_ui widget appears in the showcase', () {
    final classPattern = RegExp(
      r'^class (D3\w+)(?:<[^>]*>)? extends (?:StatelessWidget|StatefulWidget)\b',
      multiLine: true,
    );
    // Only what the package exports counts; helpers stay out.
    final exported = RegExp(r"export 'src/(components/[^']+)'")
        .allMatches(File('../lib/d3_ui.dart').readAsStringSync())
        .map((m) => '../lib/src/${m.group(1)}');
    final components = <String>{};
    for (final path in exported) {
      for (final m in classPattern.allMatches(File(path).readAsStringSync())) {
        components.add(m.group(1)!);
      }
    }
    expect(components, isNotEmpty, reason: 'found no components to check');

    final shown = StringBuffer();
    for (final dir in ['lib/examples', 'lib/showcase/pages', 'lib/patterns']) {
      for (final file in Directory(dir)
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))) {
        shown.writeln(file.readAsStringSync());
      }
    }
    final text = shown.toString();

    final missing = [
      for (final name in components.toList()..sort())
        if (!notShown.containsKey(name) &&
            !RegExp('\\b$name\\b').hasMatch(text))
          name,
    ];
    expect(
      missing,
      isEmpty,
      reason:
          'Add an example for these (lib/examples/, then a page), or list them '
          'in notShown with the reason: $missing',
    );
  });

  test('every example file is used by a page', () {
    final pages = StringBuffer();
    for (final file in Directory('lib/showcase/pages').listSync().whereType<File>()) {
      pages.writeln(file.readAsStringSync());
    }
    final unused = [
      for (final file in Directory('lib/examples')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart')))
        if (!pages.toString().contains(
          "'${file.path.replaceFirst('lib/examples/', '')}'",
        ))
          file.path,
    ];
    expect(unused, isEmpty, reason: 'No page shows these examples: $unused');
  });

  test('notShown lists only widgets that exist', () {
    // Stops the list rotting: an entry for a removed widget must go.
    final all = StringBuffer();
    for (final file in Directory('../lib/src/components')
        .listSync(recursive: true)
        .whereType<File>()) {
      all.writeln(file.readAsStringSync());
    }
    for (final name in notShown.keys) {
      expect(RegExp('class $name\\b').hasMatch(all.toString()), isTrue,
          reason: '$name no longer exists: remove it from notShown');
    }
  });
}
