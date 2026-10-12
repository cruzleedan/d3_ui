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
