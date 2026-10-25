# d3_ui Design System

## Overview

`d3_ui` is a token-driven Flutter component library built on Material 3.
Its shared visual language uses semantic colors, tonal surface layers,
rounded shapes, and restrained motion. Apps can supply their own palettes
and component tokens without rebuilding the shared components.

This guide describes the existing implementation. The linked Dart token
definitions remain the source of truth for values and supported overrides.
Read [UX_GUIDELINES.md](UX_GUIDELINES.md) for navigation, modal selection,
screen states, forms, selection, and read-only behavior. Use the component
source for current constructor signatures and [README.md](README.md) for
the package overview.

## Colors

Build themes with [D3AppTheme.light/dark](lib/src/themes/d3_app_theme.dart).
Access semantic colors through `context.d3Colors`; do not use raw
`D3ColorPrimitives` or hard-coded colors in app widgets.

[D3ColorTokens](lib/src/tokens/d3_colors.dart) defines the default light
and dark palettes. The default primary is blue (`#4D62C5` in light mode,
`#6C8FFF` in dark mode); apps may override it through the theme factories.
Always pair fills with their semantic foreground, such as `primary` with
`onPrimary`, rather than assuming white text works in both themes.

Use surface roles for hierarchy, outline roles for boundaries, and
success/warning/error roles for meaning. App-specific roles belong in
`ThemeExtension` tokens passed through `extraExtensions`. Status styling
is supported by [D3StatusTokens](lib/src/tokens/d3_status.dart).

## Typography

Use the existing component styles and theme text roles. The theme factory
does not select a custom font family; do not introduce one as a consequence
of using this guide.

[D3TypeScale](lib/src/tokens/d3_typography.dart) provides these sizes in sp:

| Role | Large | Medium | Small |
|---|---:|---:|---:|
| Display | 32 | 28 | 24 |
| Headline | 22 | 20 | 18 |
| Title | 17 | 15 | 14 |
| Body | 16 | 14 | 13 |
| Label | 12 | 11 | 10 |

These are available tokens, not a claim that the factory replaces every
Material text style with this scale. `D3TypeFace` provides line-height
multipliers of 1.2, 1.5, and 1.75. Preserve system text scaling and adapt
layouts to longer text rather than suppressing accessibility settings.

## Layout

Use [D3Spacing](lib/src/tokens/d3_spacing.dart) rather than raw spacing
values: `s2`, `s4`, `s6`, `s8`, `s10`, `s12`, `s16`, `s20`, `s22`, `s24`,
`s28`, `s32`, `s40`, `s48`, `s56`, and `s64` (logical pixels).

Start screens with `D3Screen`; consider `D3ListScreen` for searchable,
filterable lists with selection. Compose existing components before
creating a new screen-specific equivalent. Let available constraints and
content determine responsive layout; this guide introduces no new global
breakpoints. Check narrow and wide layouts, both themes, long text, and
system text scale 1.0 and 2.0 when changing screens.

## Elevation & Depth

The system is deliberately shadow-free. Use the tonal ladder
`surfaceContainerLow`, `surfaceContainer`, `surfaceContainerHigh`, and
`surfaceContainerHighest` to distinguish raised surfaces from the base
`surface`. Do not add decorative shadows to simulate elevation.

`D3Card` offers elevated and tonal variants; “elevated” refers to tonal
separation, not a drop shadow. Reuse the component's border treatment and
theme shape tokens instead of styling a second card system in app code.

## Shapes

[D3Radius](lib/src/tokens/d3_radius.dart) defines defaults: `xs` 8, `sm` 10,
`md` 12, `lg` 14, `xl` 20, and `full` 999 logical pixels.
[D3ShapeTokens](lib/src/tokens/d3_shape.dart) carries theme-level shape
overrides. Respect the active component/theme tokens rather than copying
these default numbers into consumers.

## Components

Use `D3Button` for shared actions, `D3TextField` and related fields for
input, `D3Card` and `D3ListTile` for surfaces, and the existing dialog,
sheet, menu, and navigation components for their respective tasks.
[D3TokensExtension](lib/src/themes/d3_theme_extension.dart) provides
button, input, gallery, shape, status, and color configuration.

Follow [UX_GUIDELINES.md](UX_GUIDELINES.md) when choosing modal surfaces
and placing primary actions. Represent loading, empty, error, and
populated states explicitly. Preserve the field components' validation
and read-only behavior rather than replacing them with ad hoc variants.

Motion uses [D3Motion](lib/src/tokens/d3_motion.dart): `instant` 0 ms,
`fast` 100 ms, `base` 200 ms, `moderate` 300 ms, and `slow` 400 ms, with
named standard, enter, and exit curves. Button-specific tokens live in
`D3ButtonMotion`. Favor functional state transitions and respect reduced
motion. Existing tokens include spring curves; their availability is not
a requirement to introduce bouncy motion into a workflow.

## Do's and Don'ts

- Do preserve app-specific theme overrides and semantic foreground pairs.
- Do reuse components and consult their current source before copying an example.
- Do verify actual touch targets, contrast, text scaling, and screen states.
- Do keep reusable behavioral conventions in `UX_GUIDELINES.md` and update
  this guide when the shared visual system changes.
- Don't select a generated palette or font pairing over an app's existing tokens.
- Don't hard-code spacing, radii, colors, or animation durations in consumers.
- Don't treat a default token value as a mandatory palette for every app.
