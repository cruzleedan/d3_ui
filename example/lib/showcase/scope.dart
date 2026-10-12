import 'package:material_ui/material_ui.dart';

import 'brands.dart';

/// The showcase's current choices, available to every page: the brand, the
/// theme mode, and ways to change them. The older gallery pages read these.
class ShowcaseScope extends InheritedWidget {
  const ShowcaseScope({
    super.key,
    required this.brand,
    required this.themeMode,
    required this.onBrandChanged,
    required this.onThemeModeChanged,
    required this.brandThemes,
    required super.child,
  });

  final ShowcaseBrand brand;
  final ThemeMode themeMode;
  final ValueChanged<ShowcaseBrand> onBrandChanged;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final Map<String, BrandThemes> brandThemes;

  static ShowcaseScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ShowcaseScope>()!;

  /// Light and dark toggle for pages with their own "toggle theme" button.
  void toggleTheme(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    onThemeModeChanged(dark ? ThemeMode.light : ThemeMode.dark);
  }

  @override
  bool updateShouldNotify(ShowcaseScope old) =>
      brand != old.brand ||
      themeMode != old.themeMode ||
      brandThemes != old.brandThemes;
}

/// Lets a page send the reader to another page by id.
class ShowcaseNav extends InheritedWidget {
  const ShowcaseNav({super.key, required this.open, required super.child});

  final void Function(String pageId) open;

  static ShowcaseNav of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ShowcaseNav>()!;

  @override
  bool updateShouldNotify(ShowcaseNav old) => false;
}
