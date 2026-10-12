import 'dart:convert';

import 'package:material_ui/material_ui.dart';

import 'package:d3_ui/src/themes/d3_app_theme.dart';
import 'package:d3_ui/src/themes/d3_theme_extension.dart';
import 'package:d3_ui/src/tokens/d3_colors.dart';
import 'package:d3_ui/src/tokens/d3_shape.dart';
import 'package:d3_ui/src/tokens/d3_status.dart';

/// A theme described as data: build an app's whole light and dark theme from a
/// design-token JSON file instead of hand-written constants.
///
/// Expected shape (the Food Finder merchant app's `design-tokens.json`):
///
/// ```json
/// {
///   "kit": "d3-ui-kit v0.5.0",
///   "colors": { "light": { "background": {"hex": "#F6F5F2"}, ... }, "dark": { ... } },
///   "status": { "success": { "light": {"text": ..., "tint": ..., "border": ...}, "dark": {...} }, ... },
///   "radius": 10
/// }
/// ```
///
/// Colour roles are the shadcn-style names (`background`, `foreground`, `card`,
/// `primary`, `primary-foreground`, `secondary`, `muted`, `muted-foreground`,
/// `accent`, `destructive`, `border`, `input`, ...). A colour is a hex string
/// (`#RRGGBB` or `#RRGGBBAA`) or an object with `hex` (and optionally `alpha` or
/// `opacity`, 0..1 or 0..100). `kebab-case` and `camelCase` role names both work.
/// A status `tint` or `border` may be translucent; it composites over its
/// surface at draw time.
///
/// How roles map onto [D3ColorTokens]:
///
/// | JSON role | [D3ColorTokens] |
/// |---|---|
/// | `background` | `surface` |
/// | `foreground` | `onSurface` |
/// | `card` | `surfaceContainerLow` (cards and sheets) |
/// | `muted` | `surfaceVariant`, `surfaceContainer`, `surfaceContainerHighest` |
/// | `accent` | `surfaceContainerHigh` |
/// | `muted-foreground` | `onSurfaceVariant` |
/// | `input` | `outline` |
/// | `border` | `outlineVariant` |
/// | `primary` / `primary-foreground` | `primary` / `onPrimary` |
/// | `secondary` / `secondary-foreground` | `secondary` / `onSecondary` |
/// | `destructive` | `error` (its status tint is `errorContainer`) |
/// | status `success`, `warning` text | `success`, `warning` |
///
/// `primaryContainer` is the primary at 12% (light) or 16% (dark); the `on…`
/// colours on a filled status colour (`onSuccess`, `onWarning`, `onError`) reuse
/// `primary-foreground`. Roles a file lacks fall back to [D3ColorTokens]'s own
/// light or dark defaults, so a partial file still builds a theme.
class D3ThemeSpec {
  const D3ThemeSpec({required this.light, required this.dark, this.kit});

  /// Parses a JSON document.
  factory D3ThemeSpec.parse(String source) {
    final json = jsonDecode(source);
    if (json is! Map<String, dynamic>) {
      throw const FormatException('A theme file must be a JSON object');
    }
    return D3ThemeSpec.fromJson(json);
  }

  /// Builds a spec from an already decoded JSON object.
  ///
  /// [cardOutlineOpacity] sets the card outline to the text colour at that
  /// opacity (the merchant app draws card outlines at 10%); pass `null` to keep
  /// d3_ui's default outline.
  factory D3ThemeSpec.fromJson(
    Map<String, dynamic> json, {
    double? cardOutlineOpacity = 0.1,
  }) {
    final colors = _map(json['colors']);
    final status = _map(json['status']);
    final radius = json['radius'];
    return D3ThemeSpec(
      kit: _kit(json['kit']),
      light: _variant(
        Brightness.light,
        _map(colors['light']),
        status,
        radius,
        cardOutlineOpacity,
      ),
      dark: _variant(
        Brightness.dark,
        _map(colors['dark']),
        status,
        radius,
        cardOutlineOpacity,
      ),
    );
  }

  /// The design-token kit the file was generated from (for the record), for
  /// example `v0.5.0`.
  final String? kit;

  final D3ThemeVariant light;
  final D3ThemeVariant dark;

  /// The light [ThemeData]. Everything [D3AppTheme.light] accepts can be added.
  ThemeData lightTheme({
    D3InputTokens? inputTokens,
    D3ButtonTokens? buttonTokens,
    List<ThemeExtension<dynamic>> extraExtensions = const [],
  }) => D3AppTheme.light(
    colors: light.colors,
    shapeTokens: light.shape,
    statusTokens: light.status,
    inputTokens: inputTokens,
    buttonTokens: buttonTokens,
    extraExtensions: extraExtensions,
  );

  /// The dark [ThemeData].
  ThemeData darkTheme({
    D3InputTokens? inputTokens,
    D3ButtonTokens? buttonTokens,
    List<ThemeExtension<dynamic>> extraExtensions = const [],
  }) => D3AppTheme.dark(
    colors: dark.colors,
    shapeTokens: dark.shape,
    statusTokens: dark.status,
    inputTokens: inputTokens,
    buttonTokens: buttonTokens,
    extraExtensions: extraExtensions,
  );

  // ── parsing ───────────────────────────────────────────────────────────────

  static D3ThemeVariant _variant(
    Brightness brightness,
    Map<String, dynamic> c,
    Map<String, dynamic> status,
    Object? radius,
    double? cardOutlineOpacity,
  ) {
    final isDark = brightness == Brightness.dark;
    final base = isDark ? D3ColorTokens.dark : D3ColorTokens.light;
    final mode = isDark ? 'dark' : 'light';

    Color? role(String name) => _role(c, name);

    final background = role('background') ?? base.surface;
    final foreground = role('foreground') ?? base.onSurface;
    final card = role('card') ?? base.surfaceContainerLow;
    final primary = role('primary') ?? base.primary;
    final onPrimary = role('primary-foreground') ?? base.onPrimary;
    final muted = role('muted') ?? base.surfaceVariant;
    final accent = role('accent') ?? base.surfaceContainerHigh;
    final mutedForeground = role('muted-foreground') ?? base.onSurfaceVariant;
    final destructive = role('destructive') ?? base.error;

    D3StatusColor? statusOf(String kind) {
      final byMode = _map(_map(status[kind])[mode]);
      if (byMode.isEmpty) return null;
      final text = _color(byMode['text']);
      final tint = _color(byMode['tint']);
      final border = _color(byMode['border']);
      if (text == null || tint == null || border == null) return null;
      return D3StatusColor(text: text, tint: tint, border: border);
    }

    final derived = D3StatusTokens.fromColors(
      D3ColorTokens(
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: base.primaryContainer,
        onPrimaryContainer: base.onPrimaryContainer,
        secondary: base.secondary,
        onSecondary: base.onSecondary,
        surface: background,
        surfaceVariant: muted,
        surfaceContainerLow: card,
        surfaceContainer: muted,
        surfaceContainerHigh: accent,
        surfaceContainerHighest: muted,
        onSurface: foreground,
        onSurfaceVariant: mutedForeground,
        outline: role('input') ?? base.outline,
        success: base.success,
        onSuccess: onPrimary,
        warning: base.warning,
        onWarning: onPrimary,
        error: destructive,
        onError: onPrimary,
        errorContainer: base.errorContainer,
        onErrorContainer: base.onErrorContainer,
        scrim: base.scrim,
      ),
    );
    final statuses = D3StatusTokens(
      star: _color(_map(_map(status['warning'])[mode])['star']),
      success: statusOf('success') ?? derived.success,
      warning: statusOf('warning') ?? derived.warning,
      destructive: statusOf('destructive') ?? derived.destructive,
      neutral: statusOf('neutral') ?? derived.neutral,
    );

    final colors = D3ColorTokens(
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primary.withValues(alpha: isDark ? 0.16 : 0.12),
      onPrimaryContainer: primary,
      secondary: role('secondary') ?? base.secondary,
      onSecondary: role('secondary-foreground') ?? base.onSecondary,
      surface: background,
      surfaceVariant: muted,
      surfaceContainerLow: card,
      surfaceContainer: muted,
      surfaceContainerHigh: accent,
      surfaceContainerHighest: muted,
      onSurface: foreground,
      onSurfaceVariant: mutedForeground,
      outline: role('input') ?? base.outline,
      outlineVariant: role('border'),
      success: statuses.success.text,
      onSuccess: onPrimary,
      warning: statuses.warning.text,
      onWarning: onPrimary,
      error: destructive,
      onError: onPrimary,
      errorContainer: statuses.destructive.tint,
      onErrorContainer: statuses.destructive.text,
      scrim: base.scrim,
    );

    return D3ThemeVariant(
      colors: colors,
      status: statuses,
      shape: _shape(
        radius,
        cardBorder: cardOutlineOpacity == null
            ? null
            : foreground.withValues(alpha: cardOutlineOpacity),
      ),
    );
  }

  /// `radius` is a base number (the merchant app uses 10) or an object of named
  /// steps. d3_ui's scale steps shift one up from the file's: `xs` takes `sm`,
  /// `sm` takes `md`, `md` takes `lg`, `lg` (cards) takes `xl`, `xl` (sheets,
  /// dialogs) takes `2xl`. From a base number `b`: sm=b-4, md=b-2, lg=b,
  /// xl=b+4, 2xl=b+8.
  static D3ShapeTokens _shape(Object? radius, {Color? cardBorder}) {
    double? named(Map<String, dynamic> m, String key) {
      final v = m[key];
      return v is num ? v.toDouble() : null;
    }

    if (radius is num) {
      final b = radius.toDouble();
      return D3ShapeTokens(
        xs: b - 4,
        sm: b - 2,
        md: b,
        lg: b + 4,
        xl: b + 8,
        cardBorder: cardBorder,
      );
    }
    final m = _map(radius);
    if (m.isEmpty) return D3ShapeTokens(cardBorder: cardBorder);
    const d = D3ShapeTokens.defaults;
    return D3ShapeTokens(
      xs: named(m, 'sm') ?? d.xs,
      sm: named(m, 'md') ?? d.sm,
      md: named(m, 'lg') ?? d.md,
      lg: named(m, 'xl') ?? d.lg,
      xl: named(m, '2xl') ?? named(m, 'xl2') ?? d.xl,
      cardBorder: cardBorder,
    );
  }

  /// `"d3-ui-kit v0.5.0"`, or an object with a `tag` (and `version`).
  static String? _kit(Object? v) {
    if (v is String) return v;
    final m = _map(v);
    final tag = m['tag'] ?? m['version'];
    return tag is String ? tag : null;
  }

  static Map<String, dynamic> _map(Object? v) =>
      v is Map ? v.cast<String, dynamic>() : const {};

  /// Finds a colour role by kebab-case or camelCase name.
  static Color? _role(Map<String, dynamic> colors, String name) {
    final camel = name.replaceAllMapped(
      RegExp(r'-([a-z])'),
      (m) => m[1]!.toUpperCase(),
    );
    return _color(colors[name] ?? colors[camel]);
  }

  /// `#RRGGBB`, `#RRGGBBAA`, or `{hex, alpha|opacity}`.
  static Color? _color(Object? v) {
    if (v is Map) {
      final base = _color(v['hex']);
      final a = v['alpha'] ?? v['opacity'];
      if (base == null || a is! num) return base;
      final fraction = a > 1 ? a / 100 : a.toDouble();
      return base.withValues(alpha: fraction.clamp(0.0, 1.0).toDouble());
    }
    if (v is! String) return null;
    final hex = v.trim().replaceFirst('#', '');
    if (hex.length != 6 && hex.length != 8) return null;
    final n = int.tryParse(hex, radix: 16);
    if (n == null) return null;
    if (hex.length == 6) return Color(0xFF000000 | n);
    // CSS order: RRGGBBAA.
    return Color(((n & 0xFF) << 24) | (n >> 8));
  }
}

/// One mode's tokens from a [D3ThemeSpec].
class D3ThemeVariant {
  const D3ThemeVariant({
    required this.colors,
    required this.status,
    required this.shape,
  });

  final D3ColorTokens colors;
  final D3StatusTokens status;
  final D3ShapeTokens shape;
}
