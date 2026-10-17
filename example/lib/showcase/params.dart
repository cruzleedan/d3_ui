import 'package:material_ui/material_ui.dart';

import 'text_size.dart';

/// What the address asks for, so a link (or the portfolio's embed) can open the
/// showcase on a page, in a theme and in a brand:
/// `/patterns?theme=dark&brand=terracotta&embed=1`.
///
/// The page is the first path segment (`/button`); the older form
/// `/?page=button` still reads the same. Missing or unknown values never break
/// the page: the theme falls back to the device setting, the brand to the first
/// brand, the page to the overview.
class ShowcaseParams {
  const ShowcaseParams({
    this.page,
    this.themeMode,
    this.brand,
    this.textScale,
    this.embed = false,
  });

  final String? page;
  final ThemeMode? themeMode;
  final String? brand;

  /// `?text=1.5`: mimic a system text size of 150%.
  final double? textScale;

  /// `?embed=1`: show only the page, with none of the navigation, for a frame.
  final bool embed;

  factory ShowcaseParams.fromQuery(Map<String, String> query) {
    ThemeMode? mode;
    switch (query['theme']?.toLowerCase()) {
      case 'light':
        mode = ThemeMode.light;
      case 'dark':
        mode = ThemeMode.dark;
      case 'system':
        mode = ThemeMode.system;
    }
    return ShowcaseParams(
      page: query['page'],
      themeMode: mode,
      brand: query['brand']?.toLowerCase(),
      textScale: ShowcaseTextSize.parse(query['text']),
      embed: query['embed'] == '1' || query['embed'] == 'true',
    );
  }

  /// From an address: the page from the path, else from `?page=`.
  factory ShowcaseParams.fromUri(Uri uri) {
    final fromQuery = ShowcaseParams.fromQuery(uri.queryParameters);
    final segments = uri.pathSegments.where((s) => s.isNotEmpty);
    return ShowcaseParams(
      page: segments.isNotEmpty ? segments.first : fromQuery.page,
      themeMode: fromQuery.themeMode,
      brand: fromQuery.brand,
      textScale: fromQuery.textScale,
      embed: fromQuery.embed,
    );
  }
}

/// The address an old-style link (`/?page=button&brand=green`) now has
/// (`/button?brand=green`), or null when it is not one.
Uri? legacyLocation(Uri uri) {
  final page = uri.queryParameters['page'];
  if (uri.pathSegments.where((s) => s.isNotEmpty).isNotEmpty || page == null) {
    return null;
  }
  final rest = {...uri.queryParameters}..remove('page');
  return Uri(
    path: page.isEmpty ? '/' : '/$page',
    queryParameters: rest.isEmpty ? null : rest,
  );
}

/// The address for a showcase state: `/button?theme=dark&brand=green`.
///
/// Defaults are left out so a plain address stays plain: the overview, the
/// device theme and the first brand. `embed` is kept when it is on.
Uri showcaseLocation({
  required String page,
  required ThemeMode themeMode,
  required String brand,
  double textScale = 1.0,
  bool embed = false,
  String defaultPage = 'overview',
  String defaultBrand = 'blue',
}) {
  final query = <String, String>{
    if (themeMode != ThemeMode.system) 'theme': themeMode.name,
    if (brand != defaultBrand) 'brand': brand,
    if (textScale != 1.0) 'text': ShowcaseTextSize.format(textScale),
    if (embed) 'embed': '1',
  };
  return Uri(
    path: page == defaultPage ? '/' : '/$page',
    queryParameters: query.isEmpty ? null : query,
  );
}
