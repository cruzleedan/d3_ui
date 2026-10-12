import 'dart:io';

import 'package:d3_ui/d3_ui.dart';
import 'package:d3_ui_example/showcase/brands.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads the token files straight from disk, so the test needs no asset bundle.
Future<String> _fromDisk(String asset) => File(asset).readAsString();

void main() {
  late Map<String, BrandThemes> themes;

  setUpAll(() async {
    themes = await loadBrandThemes(load: _fromDisk);
  });

  test('brand ids are unique and the published ones are unchanged', () {
    final ids = [for (final b in showcaseBrands) b.id];
    expect(ids.toSet().length, ids.length);
    // These are in links and in the portfolio's embed: never rename them.
    expect(ids, containsAll(['blue', 'green', 'terracotta']));
    expect(ids.first, 'blue', reason: 'the default comes first');
  });

  test('every brand has a token file that exists and parses', () {
    for (final brand in showcaseBrands) {
      final asset = brand.asset;
      if (asset == null) continue;
      expect(File(asset).existsSync(), isTrue, reason: '${brand.id}: $asset');
      expect(themes[brand.id]!.spec, isNotNull, reason: brand.id);
    }
  });

  test('each brand has its own primary colour', () {
    final primaries = [
      for (final b in showcaseBrands)
        themes[b.id]!.light.colorScheme.primary.toARGB32(),
    ];
    expect(primaries.toSet().length, primaries.length);
  });

  for (final dark in [false, true]) {
    test(
        'text reads on its background in every brand (${dark ? 'dark' : 'light'})',
        () {
      for (final brand in showcaseBrands) {
        final theme = dark ? themes[brand.id]!.dark : themes[brand.id]!.light;
        final c = theme.extension<D3TokensExtension>()!.colors;
        final pairs = {
          'onSurface on surface': (c.onSurface, c.surface),
          'onSurfaceVariant on surface': (c.onSurfaceVariant, c.surface),
          'onPrimary on primary': (c.onPrimary, c.primary),
          'onError on error': (c.onError, c.error),
        };
        pairs.forEach((name, pair) {
          expect(
            d3ContrastRatio(pair.$1, pair.$2),
            greaterThanOrEqualTo(4.5),
            reason: '${brand.id} ${dark ? 'dark' : 'light'}: $name',
          );
        });
      }
    });
  }
}
