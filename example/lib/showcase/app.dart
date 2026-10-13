import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show SystemNavigator;
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

class _ShowcaseAppState extends State<ShowcaseApp> with WidgetsBindingObserver {
  late ShowcaseBrand _brand = brandById(widget.params.brand);
  late ThemeMode _themeMode = widget.params.themeMode ?? ThemeMode.system;
  late String _pageId = pageForId(widget.params.page).id;

  @override
  void initState() {
    super.initState();
    // Registered before any app below it (the Places preview is an app of its
    // own), and the first observer to return true wins, so browser back and
    // forward are handled here and never reach the apps nested inside.
    WidgetsBinding.instance.addObserver(this);
    if (kIsWeb && !widget.params.embed) {
      // A MaterialApp with no router tells the engine to keep a single browser
      // history entry, and does so when it is created (after this runs). After
      // the first frame, ask for real history instead, so back and forward
      // work, then write the address the page was opened with, which the
      // engine would otherwise reset to "/".
      WidgetsBinding.instance.addPostFrameCallback((_) {
        SystemNavigator.selectMultiEntryHistory();
        _syncUrl(replace: true);
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Browser back, forward, or a link opened in this tab.
  @override
  Future<bool> didPushRouteInformation(
      RouteInformation routeInformation) async {
    final p = ShowcaseParams.fromUri(routeInformation.uri);
    setState(() {
      _pageId = pageForId(p.page).id;
      _brand = brandById(p.brand);
      _themeMode = p.themeMode ?? ThemeMode.system;
    });
    return true;
  }

  /// Puts the state in the address bar so the page can be bookmarked and shared.
  /// A page change is a history entry (back works); a brand or theme change
  /// replaces the current one.
  void _syncUrl({required bool replace}) {
    if (!kIsWeb || widget.params.embed) return;
    SystemNavigator.routeInformationUpdated(
      uri: showcaseLocation(
        page: _pageId,
        themeMode: _themeMode,
        brand: _brand.id,
        defaultPage: showcasePages.first.id,
        defaultBrand: showcaseBrands.first.id,
      ),
      replace: replace,
    );
  }

  void _change({String? page, ShowcaseBrand? brand, ThemeMode? mode}) {
    setState(() {
      if (page != null) _pageId = page;
      if (brand != null) _brand = brand;
      if (mode != null) _themeMode = mode;
    });
    _syncUrl(replace: page == null);
  }

  @override
  Widget build(BuildContext context) {
    final themes = widget.brandThemes[_brand.id]!;
    return MaterialApp(
      title: 'd3_ui: a Flutter design system',
      debugShowCheckedModeBanner: false,
      theme: themes.light,
      darkTheme: themes.dark,
      themeMode: _themeMode,
      // Explicit, so the address (which carries a query) is not read as a route
      // name by the Navigator.
      initialRoute: '/',
      home: Builder(
        builder: (context) => ShowcaseScope(
          pageId: _pageId,
          onPageChanged: (id) => _change(page: id),
          brand: _brand,
          themeMode: _themeMode,
          brandThemes: widget.brandThemes,
          embed: widget.params.embed,
          onBrandChanged: (b) => _change(brand: b),
          onThemeModeChanged: (m) => _change(mode: m),
          // The tab title follows the page, so a bookmark has a useful name.
          child: Title(
            title: _pageId == showcasePages.first.id
                ? 'd3_ui: a Flutter design system'
                : '${pageForId(_pageId).title} · d3_ui',
            color: themes.light.colorScheme.primary,
            child: ShowcaseShell(embed: widget.params.embed),
          ),
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
