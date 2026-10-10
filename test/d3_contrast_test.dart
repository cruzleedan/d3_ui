import 'package:d3_ui/d3_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  const white = Color(0xFFFFFFFF);
  const black = Color(0xFF000000);

  test('ratio matches the WCAG extremes', () {
    expect(d3ContrastRatio(black, white), closeTo(21, 0.01));
    expect(d3ContrastRatio(white, white), closeTo(1, 0.001));
  });

  test('a colour that already passes is returned unchanged', () {
    expect(d3EnsureContrast(black, white), black);
  });

  test('amber on white is darkened until it reaches 4.5:1', () {
    const amber = Color(0xFFF59E0B); // 2.15:1 on white
    final fixed = d3EnsureContrast(amber, white);
    expect(d3ContrastRatio(amber, white), lessThan(4.5));
    expect(d3ContrastRatio(fixed, white), greaterThanOrEqualTo(4.5));
    // Still amber-ish: red channel dominant, not turned grey.
    expect(fixed.r, greaterThan(fixed.b));
  });

  test('on a dark background it lightens instead', () {
    const dim = Color(0xFF333333);
    const bg = Color(0xFF0F1117);
    final fixed = d3EnsureContrast(dim, bg);
    expect(d3ContrastRatio(fixed, bg), greaterThanOrEqualTo(4.5));
    expect(fixed.computeLuminance(), greaterThan(dim.computeLuminance()));
  });

  test('the light theme primary clears AA on white and the card surface', () {
    final colors = D3ColorTokens.light;
    expect(d3ContrastRatio(colors.primary, white), greaterThanOrEqualTo(4.5));
    expect(
      d3ContrastRatio(colors.primary, colors.surfaceContainer),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      d3ContrastRatio(colors.onPrimary, colors.primary),
      greaterThanOrEqualTo(4.5),
    );
  });
}
