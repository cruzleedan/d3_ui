# Changelog

## Unreleased

- **Showcase** the engine (`canvaskit.wasm`, 2 MB) now lives in
  `canvaskit-<hash>/`, a name that changes with the engine, so a host can cache it
  for a year as immutable without ever serving an old wasm to a new app. The
  build script renames the folder and updates the page and loader.
- **Showcase** faster first load: the bundled Roboto fonts are subset to Latin and
  unhinted (811 KB down to about 120 KB, and hosts send fonts uncompressed), the
  unused Light weight is gone, the first frame no longer waits for the code
  highlighter (code shows plain, then in colour), the two large downloads are
  preloaded, and the splash has a progress bar. First-load transfer is about
  3.3 MB, from about 4.0 MB.
- **Showcase** text size: an "Aa" control (rail, and the app bar on a phone)
  mimics the device's font-size setting from 85% to 200%, so every component
  and label can be seen at larger system text sizes. It scales the page,
  dialogs, sheets and toasts, leaves the showcase's own controls readable, shows
  a "Text size N% / Reset" pill while on, and is in the address as `?text=1.5`.
- **Fix** large system text in compact controls: `D3NavBar` labels wrap to two
  lines (and stop growing at 1.5x) instead of being cut to one; `D3SegmentedControl`
  grows taller and wraps a label to two lines; `D3QuantityStepper`'s number stops
  growing at 1.5x so it no longer overflows its 48 dp pill.
- **Fix** long text and large system text size: field labels (`D3TextField`,
  `D3DateField`, `D3DropdownField`) wrap instead of overflowing, `D3Chip` and
  `D3SplitButton` ellipsize a long label inside their width, and `D3Button`
  wraps its label (up to 3 lines) when the text scale is above 1.3 instead of
  cutting it. `test/audit/text_scale_audit_test.dart` checks 40 widgets at text
  scales 1 to 3 with long strings.
- **Fix** tap targets and ripples: every tappable widget now has a tap region of
  at least 48 x 48 dp even where its visual is smaller (`D3Button` xs/sm/md and
  icon-only, `D3Chip`, `D3HyperlinkButton` (new `inline` opt-out for links in
  running text), `D3ScrimIconButton`, `D3SplitButton` segments, the nav bar
  centre action, `D3ListTile`, `D3Card` and `D3ExpandableSection` headers when
  tappable). The new `D3PaddedTapTarget` does this without changing the visual.
  Text and decimal fields focus from anywhere in their box. Ripples are confined
  to the visible shape: `D3Chip` is now a pill-shaped Material, `D3NavBar` items
  ripple inside the pill, and `D3QuantityStepper` stays inside its pill.
  Layout: `D3Button` xs/sm/md now occupy 48 dp of height. `test/audit/` holds
  asserting audits for both.
- **New widgets** (mobile first, from the theme's tokens, 48 dp targets, text
  scale 1.5, reduced motion): `D3Rating` (display with half stars and input with
  tap, drag and keyboard), `D3OtpField` (one real text field behind the cells, so
  paste and SMS autofill work), `showD3TimePicker` and `D3TimeField` (a wheel
  time sheet and its field), `D3Menu` and `D3MenuButton` (anchored, flips to stay
  on screen, keyboard), and `D3Tooltip` and `D3InfoTip` (hover, focus,
  long-press; tap-to-open for touch).
- **New widgets** (mobile first, all from the theme's tokens): `D3Banner` (a
  persistent inline message, four variants, action and dismiss),
  `D3ProgressBar` and `D3ProgressRing` (determinate and indeterminate),
  `D3Badge` (count, dot, label) and `D3BadgeAnchor` (overlay on any widget),
  `D3Slider`, `D3QuantityStepper` (hold to repeat) and `D3ActionSheet` (a bottom
  sheet of thumb-sized actions with destructive and selected rows and a
  separate Cancel). Touch targets are at least 48 dp, text scales to 1.5, and
  motion stops under reduced motion.
- **Fix** `D3Dialog` on phones: buttons are at least 48 dp tall (inline were
  about 36, stacked 46); the body scrolls with the actions pinned, so long text,
  large text scale or landscape no longer overflow; inline actions wrap instead
  of overflowing; the destructive button's label uses `onError` (white on the
  dark theme's salmon `error` was about 2.5:1); title 17 sp and message 14 sp;
  the title is a header and the dialog names its route for screen readers;
  action order is stable.
- **Fix** `D3Toast`: the action and the dismiss button are 48 dp touch targets
  with ink (they were about 20 and 23 dp).
- **Fix** the search field in `D3DropdownField`'s bottom sheet (`D3DropdownMode.sheet`,
  `searchable`) was barely visible: its fill matched the sheet colour. It is now a
  `D3SearchBar`, which tints with `onSurface`, so it shows in light and dark (and
  gets the clear button).
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
