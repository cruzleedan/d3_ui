import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:d3_ui/d3_ui.dart';

void main() {
  group('D3Spacing', () {
    test('values follow 4dp base grid', () {
      expect(D3Spacing.s4, 4.0);
      expect(D3Spacing.s8, 8.0);
      expect(D3Spacing.s16, 16.0);
      expect(D3Spacing.s24, 24.0);
      expect(D3Spacing.s32, 32.0);
    });

    test('s2 is the smallest token', () {
      expect(D3Spacing.s2, lessThan(D3Spacing.s4));
    });

    test('all values are positive', () {
      const values = [
        D3Spacing.s2,
        D3Spacing.s4,
        D3Spacing.s6,
        D3Spacing.s8,
        D3Spacing.s10,
        D3Spacing.s12,
        D3Spacing.s16,
        D3Spacing.s20,
        D3Spacing.s22,
        D3Spacing.s24,
        D3Spacing.s28,
        D3Spacing.s32,
        D3Spacing.s40,
        D3Spacing.s48,
        D3Spacing.s56,
        D3Spacing.s64,
      ];
      for (final v in values) {
        expect(v, greaterThan(0.0));
      }
    });
  });

  group('D3Radius', () {
    test('xs < sm < md < lg < xl', () {
      expect(D3Radius.xs, lessThan(D3Radius.sm));
      expect(D3Radius.sm, lessThan(D3Radius.md));
      expect(D3Radius.md, lessThan(D3Radius.lg));
      expect(D3Radius.lg, lessThan(D3Radius.xl));
    });

    test('full is pill-shaped (very large value)', () {
      expect(D3Radius.full, greaterThanOrEqualTo(999.0));
    });

    test('circularMd wraps md value', () {
      expect(
        D3Radius.circularMd,
        const BorderRadius.all(Radius.circular(D3Radius.md)),
      );
    });

    test('circularFull wraps full value', () {
      expect(
        D3Radius.circularFull,
        const BorderRadius.all(Radius.circular(D3Radius.full)),
      );
    });
  });

  group('D3Motion', () {
    test('duration order: fast < base < moderate < slow', () {
      expect(D3Motion.fast, lessThan(D3Motion.base));
      expect(D3Motion.base, lessThan(D3Motion.moderate));
      expect(D3Motion.moderate, lessThan(D3Motion.slow));
    });

    test('instant is zero duration', () {
      expect(D3Motion.instant.inMilliseconds, 0);
    });

    test('fast is 100ms', () {
      expect(D3Motion.fast.inMilliseconds, 100);
    });

    test('base is 200ms', () {
      expect(D3Motion.base.inMilliseconds, 200);
    });

    test('curves are non-null', () {
      expect(D3Motion.standard, isNotNull);
      expect(D3Motion.enter, isNotNull);
      expect(D3Motion.exit, isNotNull);
      expect(D3Motion.spring, isNotNull);
    });
  });

  group('D3TypeScale', () {
    test('display sizes are larger than headline sizes', () {
      expect(
          D3TypeScale.displaySmSize, greaterThan(D3TypeScale.headlineLgSize));
    });

    test('headline sizes are larger than body sizes', () {
      expect(D3TypeScale.headlineSmSize, greaterThan(D3TypeScale.bodyLgSize));
    });

    test('body sizes are larger than label sizes', () {
      expect(D3TypeScale.bodySmSize, greaterThan(D3TypeScale.labelLgSize));
    });

    test('button sizes are positive', () {
      const btnSizes = [
        D3TypeScale.btnXsSize,
        D3TypeScale.btnSmSize,
        D3TypeScale.btnMdSize,
        D3TypeScale.btnLgSize,
        D3TypeScale.btnXlSize,
      ];
      for (final s in btnSizes) {
        expect(s, greaterThan(0.0));
      }
    });
  });

  group('D3ColorTokens', () {
    test('light and dark tokens are distinct', () {
      expect(D3ColorTokens.light.surface, isNot(D3ColorTokens.dark.surface));
    });

    test('light surface is white or near-white', () {
      // Light surface should have high luminance
      final luminance = D3ColorTokens.light.surface.computeLuminance();
      expect(luminance, greaterThan(0.8));
    });

    test('dark surface is dark', () {
      final luminance = D3ColorTokens.dark.surface.computeLuminance();
      expect(luminance, lessThan(0.05));
    });

    test('primary color is present in both themes', () {
      expect(D3ColorTokens.light.primary, isNotNull);
      expect(D3ColorTokens.dark.primary, isNotNull);
    });

    test('all semantic tokens are non-null in light theme', () {
      const c = D3ColorTokens.light;
      expect(c.primary, isNotNull);
      expect(c.onPrimary, isNotNull);
      expect(c.surface, isNotNull);
      expect(c.onSurface, isNotNull);
      expect(c.error, isNotNull);
      expect(c.success, isNotNull);
      expect(c.warning, isNotNull);
    });
  });

  group('d3ButtonTextStyle', () {
    test('returns TextStyle with correct fontSize', () {
      const style = TextStyle(fontSize: 14);
      final result = d3ButtonTextStyle(
        fontSize: 14,
        color: const Color(0xFFFFFFFF),
      );
      expect(result.fontSize, style.fontSize);
    });

    test('uses tight line height', () {
      final style = d3ButtonTextStyle(
        fontSize: 14,
        color: const Color(0xFF000000),
      );
      expect(style.height, D3TypeFace.tight);
    });

    test('font weight is semibold (w600)', () {
      final style = d3ButtonTextStyle(
        fontSize: 14,
        color: const Color(0xFF000000),
      );
      expect(style.fontWeight, FontWeight.w600);
    });
  });
}
