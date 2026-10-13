import 'package:material_ui/material_ui.dart';

import '../example_card.dart';
import '../generated/example_sources.g.dart';

/// An [ExampleCard] whose code is the generated source of [path], a file under
/// `lib/examples/` (for example `button/variants.dart`).
ExampleCard exampleCard(
  String title,
  String path,
  Widget child, {
  String? description,
}) {
  assert(
    exampleSources.containsKey(path),
    'No example source for $path: run dart run tool/gen_example_sources.dart',
  );
  return ExampleCard(
    title: title,
    description: description,
    source: exampleSources[path],
    sourcePath: path,
    child: child,
  );
}
