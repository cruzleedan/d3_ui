import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:d3_ui/d3_ui.dart';

void main() {
  group('D3AppTheme', () {
    test('light() returns ThemeData with light brightness', () {
      final theme = D3AppTheme.light();
      expect(theme.brightness, Brightness.light);
    });

    test('dark() returns ThemeData with dark brightness', () {
      final theme = D3AppTheme.dark();
      expect(theme.brightness, Brightness.dark);
    });

    test('light theme includes D3TokensExtension', () {
      final theme = D3AppTheme.light();
      expect(theme.extension<D3TokensExtension>(), isNotNull);
    });

    test('dark theme includes D3TokensExtension', () {
      final theme = D3AppTheme.dark();
      expect(theme.extension<D3TokensExtension>(), isNotNull);
    });

    test('light theme extension holds light color tokens', () {
      final theme = D3AppTheme.light();
      final ext = theme.extension<D3TokensExtension>()!;
      expect(ext.colors.surface.computeLuminance(), greaterThan(0.8));
    });

    test('dark theme extension holds dark color tokens', () {
      final theme = D3AppTheme.dark();
      final ext = theme.extension<D3TokensExtension>()!;
      expect(ext.colors.surface.computeLuminance(), lessThan(0.05));
    });

    test('useMaterial3 is true', () {
      expect(D3AppTheme.light().useMaterial3, isTrue);
      expect(D3AppTheme.dark().useMaterial3, isTrue);
    });

    test('light() accepts overrides', () {
      const customColors = D3ColorTokens.light;
      final override = D3TokensExtension.light.copyWith(colors: customColors);
      final theme = D3AppTheme.light(overrides: override);
      expect(theme.extension<D3TokensExtension>(), isNotNull);
    });
  });

  group('D3TokensExtension', () {
    test('copyWith replaces only specified fields', () {
      final original = D3TokensExtension.light;
      final copy = original.copyWith(colors: D3ColorTokens.dark);
      expect(copy.colors, D3ColorTokens.dark);
      expect(copy.buttonTokens, original.buttonTokens);
    });

    test('lerp returns this when other is null', () {
      final ext = D3TokensExtension.light;
      final result = ext.lerp(null, 0.5);
      expect(result, ext);
    });
  });

  group('D3ButtonTokens defaults', () {
    const t = D3ButtonTokens.defaults;

    test('disabled opacity is between 0 and 1', () {
      expect(t.disabledOpacity, greaterThan(0.0));
      expect(t.disabledOpacity, lessThan(1.0));
    });

    test('min heights increase with size', () {
      expect(t.minHeightXs, lessThan(t.minHeightSm));
      expect(t.minHeightSm, lessThan(t.minHeightMd));
      expect(t.minHeightMd, lessThan(t.minHeightLg));
    });

    test('icon size is positive', () {
      expect(t.iconSize, greaterThan(0.0));
    });
  });
}
