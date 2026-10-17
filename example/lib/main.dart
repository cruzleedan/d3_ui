import 'dart:async';

import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:material_ui/material_ui.dart';

import 'showcase/app.dart';
import 'showcase/brands.dart';
import 'showcase/code_highlighting.dart';

Future<void> main() async {
  // Real paths, not #/ fragments, so the address is /button?brand=green and a
  // shared link opens that page (the host serves index.html for any path).
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  // The first frame waits only for the brand themes. The code highlighter
  // (a grammar to parse and four small files) loads in the background; until
  // it is ready the code shows as plain text and then repaints with colour.
  unawaited(CodeHighlighting.load());
  final brandThemes = await loadBrandThemes();
  runApp(ShowcaseApp(brandThemes: brandThemes, initialUri: Uri.base));
}
