import 'package:material_ui/material_ui.dart';

import 'brands.dart';
import 'page_model.dart';
import 'params.dart';
import 'registry.dart';
import 'scope.dart';
import 'shell.dart';

/// The d3_ui showcase: the shell, the brands and the choices made in the URL.
class ShowcaseApp extends StatefulWidget {
  const ShowcaseApp({
    super.key,
    required this.brandThemes,
    this.params = const ShowcaseParams(),
  });

  final Map<String, BrandThemes> brandThemes;
  final ShowcaseParams params;

  @override
  State<ShowcaseApp> createState() => _ShowcaseAppState();
}

class _ShowcaseAppState extends State<ShowcaseApp> {
  late ShowcaseBrand _brand = brandById(widget.params.brand);
  late ThemeMode _themeMode = widget.params.themeMode ?? ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    final themes = widget.brandThemes[_brand.id]!;
    return MaterialApp(
      title: 'd3_ui: a Flutter design system',
      debugShowCheckedModeBanner: false,
      theme: themes.light,
      darkTheme: themes.dark,
      themeMode: _themeMode,
      home: Builder(
        builder: (context) => ShowcaseScope(
          brand: _brand,
          themeMode: _themeMode,
          brandThemes: widget.brandThemes,
          onBrandChanged: (b) => setState(() => _brand = b),
          onThemeModeChanged: (m) => setState(() => _themeMode = m),
          child: ShowcaseShell(initialPageId: widget.params.page),
        ),
      ),
    );
  }
}

/// The page for a `?page=` value; unknown or missing is the overview.
ShowcasePage pageForId(String? id) => showcasePages.firstWhere(
      (p) => p.id == id,
      orElse: () => showcasePages.first,
    );
