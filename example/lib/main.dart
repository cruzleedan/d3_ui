import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:material_ui/material_ui.dart';

import 'showcase/app.dart';
import 'showcase/brands.dart';

Future<void> main() async {
  // Real paths, not #/ fragments, so the address is /button?brand=green and a
  // shared link opens that page (the host serves index.html for any path).
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  final brandThemes = await loadBrandThemes();
  runApp(ShowcaseApp(brandThemes: brandThemes, initialUri: Uri.base));
}
