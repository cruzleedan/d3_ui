import 'package:d3_ui/src/tokens/d3_colors.dart';
import 'package:d3_ui/src/tokens/d3_radius.dart';
import 'package:d3_ui/src/tokens/d3_spacing.dart';
import 'package:material_ui/material_ui.dart';

/// Custom ThemeExtension carrying all design system tokens.
/// Access via: Theme.of(context).d3Tokens
class D3TokensExtension extends ThemeExtension<D3TokensExtension> {
  const D3TokensExtension({
    required this.colors,
    required this.buttonTokens,
    required this.inputTokens,
    required this.photoStripTokens,
  });

  final D3ColorTokens colors;
  final D3ButtonTokens buttonTokens;
  final D3InputTokens inputTokens;
  final D3PhotoStripTokens photoStripTokens;

  @override
  D3TokensExtension copyWith({
    D3ColorTokens? colors,
    D3ButtonTokens? buttonTokens,
    D3InputTokens? inputTokens,
    D3PhotoStripTokens? photoStripTokens,
  }) {
    return D3TokensExtension(
      colors: colors ?? this.colors,
      buttonTokens: buttonTokens ?? this.buttonTokens,
      inputTokens: inputTokens ?? this.inputTokens,
      photoStripTokens: photoStripTokens ?? this.photoStripTokens,
    );
  }

  @override
  D3TokensExtension lerp(D3TokensExtension? other, double t) {
    if (other == null) return this;
    return this;
  }

  static const light = D3TokensExtension(
    colors: D3ColorTokens.light,
    buttonTokens: D3ButtonTokens.defaults,
    inputTokens: D3InputTokens.defaults,
    photoStripTokens: D3PhotoStripTokens.defaults,
  );

  static const dark = D3TokensExtension(
    colors: D3ColorTokens.dark,
    buttonTokens: D3ButtonTokens.defaults,
    inputTokens: D3InputTokens.defaults,
    photoStripTokens: D3PhotoStripTokens.defaults,
  );
}

/// Button-specific tokens. Separated for clarity and override granularity.
class D3ButtonTokens {
  const D3ButtonTokens({
    required this.disabledOpacity,
    required this.pressScale,
    required this.pressOpacity,
    required this.iconSize,
    required this.iconGap,
    required this.maxLines,
    required this.minHeightXs,
    required this.minHeightSm,
    required this.minHeightMd,
    required this.minHeightLg,
    required this.minHeightXl,
    required this.hPaddingXs,
    required this.hPaddingMd,
    required this.hPaddingLg,
    required this.vPaddingXs,
    required this.vPaddingMd,
    required this.vPaddingLg,
    required this.radiusXs,
    required this.radiusSm,
    required this.radiusMd,
    required this.radiusLg,
  });

  final double disabledOpacity;
  final double pressScale;
  final double pressOpacity;
  final double iconSize;
  final double iconGap;
  final int maxLines;

  // Min heights (floor — button grows above this with large text)
  final double minHeightXs;
  final double minHeightSm;
  final double minHeightMd;
  final double minHeightLg;
  final double minHeightXl;

  // Horizontal padding
  final double hPaddingXs;
  final double hPaddingMd;
  final double hPaddingLg;

  // Vertical padding (drives adaptive height)
  final double vPaddingXs;
  final double vPaddingMd;
  final double vPaddingLg;

  // Radii
  final double radiusXs;
  final double radiusSm;
  final double radiusMd;
  final double radiusLg;

  static const defaults = D3ButtonTokens(
    disabledOpacity: 0.35,
    pressScale: 0.96,
    pressOpacity: 0.85,
    iconSize: 16,
    iconGap: D3Spacing.s8,
    maxLines: 1,
    minHeightXs: 30,
    minHeightSm: 38,
    minHeightMd: 46,
    minHeightLg: 54,
    minHeightXl: 56,
    hPaddingXs: D3Spacing.s12,
    hPaddingMd: D3Spacing.s22,
    hPaddingLg: D3Spacing.s28,
    vPaddingXs: D3Spacing.s6,
    vPaddingMd: D3Spacing.s10,
    vPaddingLg: D3Spacing.s12,
    radiusXs: D3Radius.xs,
    radiusSm: D3Radius.sm,
    radiusMd: D3Radius.md,
    radiusLg: D3Radius.lg,
  );

  D3ButtonTokens copyWith({
    double? disabledOpacity,
    double? pressScale,
    double? pressOpacity,
    double? iconSize,
    double? iconGap,
    int? maxLines,
    double? minHeightXs,
    double? minHeightSm,
    double? minHeightMd,
    double? minHeightLg,
    double? minHeightXl,
    double? hPaddingXs,
    double? hPaddingMd,
    double? hPaddingLg,
    double? vPaddingXs,
    double? vPaddingMd,
    double? vPaddingLg,
    double? radiusXs,
    double? radiusSm,
    double? radiusMd,
    double? radiusLg,
  }) {
    return D3ButtonTokens(
      disabledOpacity: disabledOpacity ?? this.disabledOpacity,
      pressScale: pressScale ?? this.pressScale,
      pressOpacity: pressOpacity ?? this.pressOpacity,
      iconSize: iconSize ?? this.iconSize,
      iconGap: iconGap ?? this.iconGap,
      maxLines: maxLines ?? this.maxLines,
      minHeightXs: minHeightXs ?? this.minHeightXs,
      minHeightSm: minHeightSm ?? this.minHeightSm,
      minHeightMd: minHeightMd ?? this.minHeightMd,
      minHeightLg: minHeightLg ?? this.minHeightLg,
      minHeightXl: minHeightXl ?? this.minHeightXl,
      hPaddingXs: hPaddingXs ?? this.hPaddingXs,
      hPaddingMd: hPaddingMd ?? this.hPaddingMd,
      hPaddingLg: hPaddingLg ?? this.hPaddingLg,
      vPaddingXs: vPaddingXs ?? this.vPaddingXs,
      vPaddingMd: vPaddingMd ?? this.vPaddingMd,
      vPaddingLg: vPaddingLg ?? this.vPaddingLg,
      radiusXs: radiusXs ?? this.radiusXs,
      radiusSm: radiusSm ?? this.radiusSm,
      radiusMd: radiusMd ?? this.radiusMd,
      radiusLg: radiusLg ?? this.radiusLg,
    );
  }
}

/// Input field tokens.
class D3InputTokens {
  const D3InputTokens({
    required this.paddingH,
    required this.paddingV,
    required this.minHeight,
    required this.radius,
    required this.borderWidth,
    required this.focusedBorderWidth,
    required this.textSize,
    required this.labelSize,
    required this.helperSize,
    required this.iconSize,
    required this.disabledOpacity,
    required this.counterWarnThreshold,
    required this.borderAnimDuration,
    required this.tooltipRadius,
    required this.tooltipMaxWidth,
    required this.tooltipPaddingH,
    required this.tooltipPaddingV,
  });

  /// Horizontal padding — label, input text, helper, counter all align to this.
  final double paddingH;
  final double paddingV;
  final double minHeight;
  final double radius;

  /// Border width in idle/disabled/filled state.
  final double borderWidth;

  /// Border width when focused, in error, or in success state.
  final double focusedBorderWidth;

  final double textSize;
  final double labelSize;
  final double helperSize;

  /// Prefix/suffix icons — fixed, does not scale with text.
  final double iconSize;
  final double disabledOpacity;

  /// 0.0–1.0. Counter turns amber above this fraction of maxLength.
  final double counterWarnThreshold;
  final Duration borderAnimDuration;

  // Tooltip popover
  final double tooltipRadius;
  final double tooltipMaxWidth;
  final double tooltipPaddingH;
  final double tooltipPaddingV;

  static const defaults = D3InputTokens(
    paddingH: D3Spacing.s16,
    paddingV: D3Spacing.s12,
    minHeight: 48,
    radius: D3Radius.md,
    borderWidth: 1.0,
    focusedBorderWidth: 1.5,
    textSize: 14,
    labelSize: 12,
    helperSize: 11,
    iconSize: 18,
    disabledOpacity: 0.38,
    counterWarnThreshold: 0.80,
    borderAnimDuration: Duration(milliseconds: 150),
    tooltipRadius: 10,
    tooltipMaxWidth: 240,
    tooltipPaddingH: D3Spacing.s12,
    tooltipPaddingV: D3Spacing.s10,
  );

  D3InputTokens copyWith({
    double? paddingH,
    double? paddingV,
    double? minHeight,
    double? radius,
    double? borderWidth,
    double? focusedBorderWidth,
    double? textSize,
    double? labelSize,
    double? helperSize,
    double? iconSize,
    double? disabledOpacity,
    double? counterWarnThreshold,
    Duration? borderAnimDuration,
    double? tooltipRadius,
    double? tooltipMaxWidth,
    double? tooltipPaddingH,
    double? tooltipPaddingV,
  }) {
    return D3InputTokens(
      paddingH: paddingH ?? this.paddingH,
      paddingV: paddingV ?? this.paddingV,
      minHeight: minHeight ?? this.minHeight,
      radius: radius ?? this.radius,
      borderWidth: borderWidth ?? this.borderWidth,
      focusedBorderWidth: focusedBorderWidth ?? this.focusedBorderWidth,
      textSize: textSize ?? this.textSize,
      labelSize: labelSize ?? this.labelSize,
      helperSize: helperSize ?? this.helperSize,
      iconSize: iconSize ?? this.iconSize,
      disabledOpacity: disabledOpacity ?? this.disabledOpacity,
      counterWarnThreshold: counterWarnThreshold ?? this.counterWarnThreshold,
      borderAnimDuration: borderAnimDuration ?? this.borderAnimDuration,
      tooltipRadius: tooltipRadius ?? this.tooltipRadius,
      tooltipMaxWidth: tooltipMaxWidth ?? this.tooltipMaxWidth,
      tooltipPaddingH: tooltipPaddingH ?? this.tooltipPaddingH,
      tooltipPaddingV: tooltipPaddingV ?? this.tooltipPaddingV,
    );
  }
}

/// Tokens for [D3PhotoStrip] — thumbnail sizing and the remove-button hit
/// target. [removeButtonHitSize] is kept independent of [removeButtonGlyphSize]
/// so the tappable area can meet the Material touch-target minimum (48dp)
/// without inflating the visible glyph.
class D3PhotoStripTokens {
  const D3PhotoStripTokens({
    required this.thumbnailSize,
    required this.thumbnailGap,
    required this.thumbnailRadius,
    required this.removeButtonHitSize,
    required this.removeButtonGlyphSize,
    required this.removeButtonOffset,
  });

  /// Side length of each square thumbnail.
  final double thumbnailSize;

  /// Gap between adjacent thumbnails in the row.
  final double thumbnailGap;

  final double thumbnailRadius;

  /// Tappable hit area for the remove button — kept at or above the 48dp
  /// Material minimum regardless of [removeButtonGlyphSize].
  final double removeButtonHitSize;

  /// Visible size of the remove button's icon/circle.
  final double removeButtonGlyphSize;

  /// How far the remove button's hit area is inset from the thumbnail's
  /// top-right corner (negative values let it overhang, matching a
  /// standard "badge" placement).
  final double removeButtonOffset;

  static const defaults = D3PhotoStripTokens(
    thumbnailSize: D3Spacing.s64,
    thumbnailGap: D3Spacing.s8,
    thumbnailRadius: D3Radius.sm,
    removeButtonHitSize: 48,
    removeButtonGlyphSize: D3Spacing.s20,
    removeButtonOffset: -D3Spacing.s12,
  );

  D3PhotoStripTokens copyWith({
    double? thumbnailSize,
    double? thumbnailGap,
    double? thumbnailRadius,
    double? removeButtonHitSize,
    double? removeButtonGlyphSize,
    double? removeButtonOffset,
  }) {
    return D3PhotoStripTokens(
      thumbnailSize: thumbnailSize ?? this.thumbnailSize,
      thumbnailGap: thumbnailGap ?? this.thumbnailGap,
      thumbnailRadius: thumbnailRadius ?? this.thumbnailRadius,
      removeButtonHitSize: removeButtonHitSize ?? this.removeButtonHitSize,
      removeButtonGlyphSize:
          removeButtonGlyphSize ?? this.removeButtonGlyphSize,
      removeButtonOffset: removeButtonOffset ?? this.removeButtonOffset,
    );
  }
}

/// Convenience extension on BuildContext for clean token access.
extension D3ThemeExtensions on BuildContext {
  D3TokensExtension get d3Tokens =>
      Theme.of(this).extension<D3TokensExtension>()!;

  D3ColorTokens get d3Colors => d3Tokens.colors;
  D3ButtonTokens get d3ButtonTokens => d3Tokens.buttonTokens;
  D3InputTokens get d3InputTokens => d3Tokens.inputTokens;
  D3PhotoStripTokens get d3PhotoStripTokens => d3Tokens.photoStripTokens;
}
