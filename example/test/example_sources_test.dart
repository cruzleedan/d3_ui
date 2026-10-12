import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('generated example sources are up to date', () async {
    final file = File('lib/showcase/generated/example_sources.g.dart');
    final before = file.readAsStringSync();
    final result =
        await Process.run('dart', ['run', 'tool/gen_example_sources.dart']);
    expect(result.exitCode, 0, reason: '${result.stderr}');
    final after = file.readAsStringSync();
    if (after != before) file.writeAsStringSync(before);
    expect(after, before,
        reason: 'run: dart run tool/gen_example_sources.dart');
  });
}
