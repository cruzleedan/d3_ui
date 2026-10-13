# Changelog

## Unreleased

- **Fix** `D3DecimalField`: `decimalPlaces` is now applied when the field loses
  focus (`5` becomes `5.00`, `5.` becomes `5.00`, a lone `.` is cleared); it only
  limited typing before. It also has the clear (✕) button the text field has,
  shown while focused with text (`showClearButton`, default true; clearing keeps
  the focus and reports 0.0). The button is shared as an internal
  `D3FieldClearButton`.
- **Fix** the clear (✕) button of `D3TextField` and `D3SearchBar` on desktop and the
  web: pressing it unfocused the field first, so on `D3TextField` the button
  vanished before the release and nothing was cleared. A press on the button now
  counts as inside the field (`TextFieldTapRegion`): the field is cleared and
  stays focused. The password visibility toggle benefits too.
- **New** `D3NavRail` (a vertical rail with the same `D3NavItem`s as `D3NavBar`,
  optional leading and trailing widgets, `extended` mode) and
  `D3WindowSizeClass` / `D3WindowSizeBuilder` (the Material 3 compact, medium and
  expanded classes, from the window or from the width a widget is given).
- **New** `D3SearchAnchor.useRootNavigator` (default true, as before): pass
  false in an app nested inside another so the search page stays inside it.
- **Fix** `D3BottomSheet` can be dragged with a mouse, trackpad or stylus (the
  handle was dead on desktop and the web).
- **Fix** tap feedback: `D3NavBar` items and centre action, `D3Screen` icon and
  text actions and Cancel, `D3SegmentedControl`, `D3HyperlinkButton`,
  `D3ScrimIconButton`, `D3PosterCard`, `D3SearchBar` (read-only) and `D3TabBar`
  now show an ink splash; `D3ListTile` and `D3Card` splashes are stronger.
- **Custom themes** — `D3ThemeSpec` builds a whole light and dark theme from a
  design-token JSON file; `D3ColorTokens.outlineVariant`, `D3StatusTokens`
  (`context.d3Status`) and `D3ShapeTokens` (`context.d3Shape`) let a brand
  restyle status colours, corner radii and the card outline. All optional; the
  defaults equal the previous fixed values.
- **Web** — `D3Avatar`, `D3PhotoCarousel`, `D3PhotoGallery` and `D3ImageViewer`
  no longer call `Image.file` in a browser (a local path that is really a URL
  shows via `Image.network`; anything else shows the error fallback).
- **Showcase** — the `example/` app builds for the web; `scripts/build_showcase.sh`
  produces a tarball for hosting.

## 0.2.0

- **New components**
  - `D3SplitButton` — primary action with an attached overflow-menu trigger
  - `D3ListScreen` — scaffolded list screen with search, filters, and a
    contextual action bar (CAB) for multi-select operations
  - `D3DateField`, `D3DecimalField`, `D3DropdownField` — themed form fields
    rounding out `D3TextField` for common structured-input cases
  - `D3FilterChipRow` — horizontal scrollable row of toggleable filter chips
  - `D3ExpandableSection` — collapsible content section with animated reveal
  - `D3ImageViewer` — full-screen pinch-to-zoom image viewer
  - `D3AdaptiveLayout` — responsive layout helper that swaps arrangements by
    breakpoint
- **D3Chip** — `backgroundColor`/`foregroundColor` overrides for the `filled`
  variant, e.g. to render status-colored badges (success/warning/error) on a
  filled background
- **Theming** — `D3AppTheme.light()`/`dark()` now accept `colors`,
  `inputTokens`, `buttonTokens`, and `extraExtensions` so apps can layer a
  custom palette and component tokens onto the base theme without replacing
  it wholesale
- **D3List**, **D3SearchAnchor**, **D3NavBar**, **D3Screen** — assorted
  enhancements and refinements (see component docs for details)

## 0.1.1

- **D3StatusChip** — added `onTap` callback parameter

## 0.1.0

Initial release.

- **Tokens** — color primitives + semantic tokens, spacing (4dp grid), border radius, motion (durations + curves), typography scale
- **Theming** — `D3AppTheme.light()` / `D3AppTheme.dark()`, `D3TokensExtension` ThemeExtension, `BuildContext` shortcuts (`context.d3Colors`, `context.d3ButtonTokens`, `context.d3InputTokens`)
- **Components**
  - Actions: `D3Button` (filled, tonal, outlined, ghost, danger; xs–xl sizes; loading/success/error states; icon-only variant)
  - Inputs: `D3TextField`, `D3NumericController`, `D3SegmentedControl`, `D3SearchBar`, `D3SearchAnchor`, `D3Toggle`, `D3Checkbox`, `D3Radio`, `D3Chip`
  - Navigation: `D3NavBar`, `D3Screen`
  - Surfaces: `D3Card`, `D3ListTile`
  - Display: `D3Avatar`, `D3EmptyState`, `D3List`, `D3Skeleton`, `D3Image`
  - Sheets: `D3BottomSheet`
  - Dialogs: `D3Dialog`
  - Feedback: `D3Toast`
