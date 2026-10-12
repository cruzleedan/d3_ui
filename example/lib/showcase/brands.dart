import 'package:d3_ui/d3_ui.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:material_ui/material_ui.dart';

/// A brand the showcase can wear: a name and, except for the default, a design
/// token file that [D3ThemeSpec] turns into a whole light and dark theme.
class ShowcaseBrand {
  const ShowcaseBrand({
    required this.id,
    required this.label,
    required this.summary,
    this.asset,
  });

  /// The `?brand=` value.
  final String id;
  final String label;

  /// One line on what the brand shows off.
  final String summary;

  /// A design-token JSON asset; `null` is d3_ui's own default theme.
  final String? asset;
}

/// The brands, default first.
///
/// To add a brand: drop a design-token JSON into `assets/themes/` (the same
/// format as the others; `D3ThemeSpec` documents it) and add one entry here
/// with a new `id`, a label, a one-line summary and the asset path. The picker
/// chip colour is the file's own primary. `test/brands_test.dart` then checks
/// that the file parses, the text colours read (4.5:1) in light and dark, and
/// the brand differs from the others. Never rename an `id`: they are in links
/// (`?brand=`) and in the portfolio's embed.
///
/// Brands in use: `blue` is d3_ui with nothing set; `green` is a
/// small hand-written token file (a different primary, softer corners);
/// `terracotta` is a real brand's tokens (the Food Finder merchant app).
const showcaseBrands = [
  ShowcaseBrand(
    id: 'blue',
    label: 'd3 blue',
    summary: 'The defaults: nothing set.',
  ),
  ShowcaseBrand(
    id: 'green',
    label: 'Green',
    summary: 'A token file with a different primary and rounder corners.',
    asset: 'assets/themes/green.json',
  ),
  ShowcaseBrand(
    id: 'terracotta',
    label: 'Terracotta',
    summary: 'A real brand: terracotta on warm neutrals (Food Finder).',
    asset: 'assets/themes/terracotta.json',
  ),
];

/// The brand for a `?brand=` value; unknown or missing is the first.
ShowcaseBrand brandById(String? id) => showcaseBrands.firstWhere(
      (b) => b.id == id,
      orElse: () => showcaseBrands.first,
    );

/// A brand's light and dark [ThemeData], plus the parsed spec when it has one
/// (the Theme page shows what the file contained).
class BrandThemes {
  const BrandThemes({required this.light, required this.dark, this.spec});

  final ThemeData light;
  final ThemeData dark;
  final D3ThemeSpec? spec;
}

/// Loads every brand's themes once, before the first frame.
Future<Map<String, BrandThemes>> loadBrandThemes({
  Future<String> Function(String asset)? load,
}) async {
  final read = load ?? rootBundle.loadString;
  final result = <String, BrandThemes>{};
  for (final brand in showcaseBrands) {
    final asset = brand.asset;
    if (asset == null) {
      result[brand.id] = BrandThemes(
        light: D3AppTheme.light(),
        dark: D3AppTheme.dark(),
      );
    } else {
      final spec = D3ThemeSpec.parse(await read(asset));
      result[brand.id] = BrandThemes(
        light: spec.lightTheme(),
        dark: spec.darkTheme(),
        spec: spec,
      );
    }
  }
  return result;
}
