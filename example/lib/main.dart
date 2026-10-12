import 'package:material_ui/material_ui.dart';

import 'showcase/app.dart';
import 'showcase/brands.dart';
import 'showcase/params.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final brandThemes = await loadBrandThemes();
  runApp(
    ShowcaseApp(
      brandThemes: brandThemes,
      params: ShowcaseParams.fromUri(Uri.base),
    ),
  );
}
