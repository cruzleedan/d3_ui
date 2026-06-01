# Changelog

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
