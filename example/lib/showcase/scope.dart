import 'package:material_ui/material_ui.dart';

import 'brands.dart';

/// The showcase's current choices, available to every page: the brand, the
/// theme mode, and ways to change them. The older gallery pages read these.
class ShowcaseScope extends InheritedWidget {
  const ShowcaseScope({
    super.key,
    required this.pageId,
    required this.onPageChanged,
    required this.brand,
    required this.themeMode,
    required this.onBrandChanged,
    required this.onThemeModeChanged,
    required this.textScale,
    required this.onTextScaleChanged,
    required this.systemTextScaler,
    required this.brandThemes,
    this.embed = false,
    required super.child,
  });

  /// The page being shown, and a way to open another (which updates the URL).
  final String pageId;
  final ValueChanged<String> onPageChanged;
  final ShowcaseBrand brand;
  final ThemeMode themeMode;
  final ValueChanged<ShowcaseBrand> onBrandChanged;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final Map<String, BrandThemes> brandThemes;

  /// The system text size being mimicked (1.0 = the device's own).
  final double textScale;
  final ValueChanged<double> onTextScaleChanged;

  /// The device's own text scaler, which the showcase's controls keep.
  final TextScaler systemTextScaler;

  /// Shown alone in a frame (`?embed=1`): pages drop their own headings.
  final bool embed;

  static ShowcaseScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ShowcaseScope>()!;

  /// Light and dark toggle for pages with their own "toggle theme" button.
  void toggleTheme(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    onThemeModeChanged(dark ? ThemeMode.light : ThemeMode.dark);
  }

  @override
  bool updateShouldNotify(ShowcaseScope old) =>
      pageId != old.pageId ||
      brand != old.brand ||
      themeMode != old.themeMode ||
      textScale != old.textScale ||
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
