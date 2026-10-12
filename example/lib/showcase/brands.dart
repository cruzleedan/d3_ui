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
    required this.swatch,
    this.asset,
  });

  /// The `?brand=` value.
  final String id;
  final String label;

  /// One line on what the brand shows off.
  final String summary;

  /// The brand's primary colour, for the picker.
  final Color swatch;

  /// A design-token JSON asset; `null` is d3_ui's own default theme.
  final String? asset;
}

/// The brands, default first. `blue` is d3_ui with nothing set; `green` is a
/// small hand-written token file (a different primary, softer corners);
/// `terracotta` is a real brand's tokens (the Food Finder merchant app).
const showcaseBrands = [
  ShowcaseBrand(
    id: 'blue',
    label: 'd3 blue',
    summary: 'The defaults: nothing set.',
    swatch: Color(0xFF4D62C5),
  ),
  ShowcaseBrand(
    id: 'green',
    label: 'Green',
    summary: 'A token file with a different primary and rounder corners.',
    swatch: Color(0xFF1B6B3A),
    asset: 'assets/themes/green.json',
  ),
  ShowcaseBrand(
    id: 'terracotta',
    label: 'Terracotta',
    summary: 'A real brand: terracotta on warm neutrals (Food Finder).',
    swatch: Color(0xFFB4441F),
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
