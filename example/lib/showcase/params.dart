import 'package:material_ui/material_ui.dart';

/// What the page's URL asks for, so a link (or the portfolio's embed) can open
/// the showcase on a page, in a theme and in a brand:
/// `?page=patterns&theme=dark&brand=terracotta`.
///
/// Missing or unknown values never break the page: the theme falls back to the
/// device setting, the brand to the first brand, the page to the overview.
class ShowcaseParams {
  const ShowcaseParams(
      {this.page, this.themeMode, this.brand, this.embed = false});

  final String? page;
  final ThemeMode? themeMode;
  final String? brand;

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
      embed: query['embed'] == '1' || query['embed'] == 'true',
    );
  }

  /// From the page's own address.
  factory ShowcaseParams.fromUri(Uri uri) =>
      ShowcaseParams.fromQuery(uri.queryParameters);
}

/// The address for a showcase state: `/?page=button&theme=dark&brand=green`.
///
/// Defaults are left out so a plain address stays plain: the overview, the
/// device theme and the first brand. `embed` is kept when it is on.
Uri showcaseLocation({
  required String page,
  required ThemeMode themeMode,
  required String brand,
  bool embed = false,
  String defaultPage = 'overview',
  String defaultBrand = 'blue',
}) {
  final query = <String, String>{
    if (page != defaultPage) 'page': page,
    if (themeMode != ThemeMode.system) 'theme': themeMode.name,
    if (brand != defaultBrand) 'brand': brand,
    if (embed) 'embed': '1',
  };
  return Uri(path: '/', queryParameters: query.isEmpty ? null : query);
}
