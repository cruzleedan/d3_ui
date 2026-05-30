# d3_ui

A minimal, flat Flutter design system built for personal mobile apps. Ships with semantic color tokens, adaptive typography, motion tokens, and 20+ ready-to-use Material 3 components — all in a single import.

## Features

- **Design tokens** — color primitives + semantic tokens, spacing (4dp grid), border radius, motion durations + curves, typography scale
- **Theming** — light and dark `ThemeData` out of the box, with a custom `ThemeExtension` for clean token access via `BuildContext`
- **Components** — buttons, inputs, navigation, surfaces, dialogs, sheets, and feedback — all following the same flat/minimal aesthetic

---

## Installation

```yaml
dependencies:
  d3_ui: ^0.1.0
```

Then import everything with a single line:

```dart
import 'package:d3_ui/d3_ui.dart';
```

---

## Setup

Wrap your app with `D3AppTheme` to apply the design system's light and dark themes:

```dart
MaterialApp(
  theme: D3AppTheme.light(),
  darkTheme: D3AppTheme.dark(),
  themeMode: ThemeMode.system,
  home: const MyHomePage(),
);
```

Tokens are then available via `BuildContext` anywhere in the widget tree:

```dart
// Colors
context.d3Colors.primary
context.d3Colors.surface
context.d3Colors.error

// Button tokens
context.d3ButtonTokens.minHeightMd

// Input tokens
context.d3InputTokens.radius
```

---

## Tokens

### Colors

`D3ColorPrimitives` holds raw color values (blues, greens, reds, ambers, neutrals). Never reference these directly in widgets — use `D3ColorTokens` semantic tokens instead.

`D3ColorTokens` provides semantic names mapped to light and dark values:

| Token | Description |
|---|---|
| `primary` / `onPrimary` | Brand blue, text/icon on brand |
| `primaryContainer` / `onPrimaryContainer` | Tonal fill for selected states |
| `surface` / `onSurface` | Screen background, primary text |
| `surfaceVariant` / `onSurfaceVariant` | Card/input background, secondary text |
| `outline` | Borders and dividers |
| `success` / `error` / `warning` | Semantic feedback colors |
| `scrim` | Modal overlay |

### Spacing

4dp base grid. Use `D3Spacing` constants instead of raw `double` values:

```dart
D3Spacing.s4   // 4
D3Spacing.s8   // 8
D3Spacing.s12  // 12
D3Spacing.s16  // 16
D3Spacing.s24  // 24
D3Spacing.s32  // 32
// ... up to s64
```

### Border Radius

```dart
D3Radius.xs    // 8
D3Radius.sm    // 10
D3Radius.md    // 12
D3Radius.lg    // 14
D3Radius.xl    // 20
D3Radius.full  // 999 (pill)

// BorderRadius helpers
D3Radius.circularMd   // BorderRadius.all(Radius.circular(12))
D3Radius.circularFull // pill shape
```

### Motion

```dart
// Durations
D3Motion.fast      // 100ms
D3Motion.base      // 200ms
D3Motion.moderate  // 300ms
D3Motion.slow      // 400ms

// Curves
D3Motion.standard   // easeInOut
D3Motion.enter      // easeOutCubic — content appearing
D3Motion.exit       // easeInCubic — content leaving
D3Motion.spring     // elasticOut — dismissals, press release
```

### Typography

```dart
D3TypeScale.displayLgSize  // 32sp
D3TypeScale.headlineMdSize // 20sp
D3TypeScale.bodyMdSize     // 14sp
D3TypeScale.labelSmSize    // 11sp
// ... full scale from display to label
```

---

## Components

### D3Button

Flat, mobile-first button with five variants, five sizes, three states, and an icon-only form.

```dart
// Default filled button
D3Button(
  label: 'Continue',
  onPressed: _handleContinue,
)

// Variants
D3Button(label: 'Save',   variant: D3ButtonVariant.tonal,    onPressed: _save)
D3Button(label: 'Cancel', variant: D3ButtonVariant.outlined,  onPressed: _cancel)
D3Button(label: 'Skip',   variant: D3ButtonVariant.ghost,     onPressed: _skip)
D3Button(label: 'Delete', variant: D3ButtonVariant.danger,    onPressed: _delete)

// Sizes: xs, sm, md (default), lg, xl
D3Button(label: 'Small', size: D3ButtonSize.sm, onPressed: _action)

// States
D3Button(label: 'Saving…', buttonState: D3ButtonState.loading, onPressed: null)
D3Button(label: 'Saved',   buttonState: D3ButtonState.success,  onPressed: null)

// With icons
D3Button(
  label: 'Add Item',
  leadingIcon: Icons.add,
  onPressed: _add,
)

// Icon-only
D3Button.icon(
  icon: Icons.share_outlined,
  variant: D3ButtonVariant.ghost,
  onPressed: _share,
)

// Full width
D3Button(label: 'Sign In', isFullWidth: true, onPressed: _signIn)
```

**Enums**
- `D3ButtonVariant` — `filled`, `tonal`, `outlined`, `ghost`, `danger`
- `D3ButtonSize` — `xs`, `sm`, `md`, `lg`, `xl`
- `D3ButtonState` — `idle`, `loading`, `success`, `error`

---

### D3TextField

Styled text input with label, helper text, error, character counter, prefix/suffix icons, and tooltip support.

```dart
D3TextField(
  label: 'Email',
  hint: 'you@example.com',
  keyboardType: TextInputType.emailAddress,
  onChanged: (value) {},
)

// With validation
D3TextField(
  label: 'Username',
  errorText: _usernameError,
  maxLength: 30,
  onChanged: _validateUsername,
)
```

---

### D3Toggle

iOS-style toggle switch.

```dart
D3Toggle(
  value: _isEnabled,
  onChanged: (v) => setState(() => _isEnabled = v),
)

// With label
D3Toggle(
  value: _notificationsOn,
  label: 'Push notifications',
  onChanged: (v) => setState(() => _notificationsOn = v),
)
```

---

### D3Checkbox

Styled checkbox with support for labels and indeterminate state.

```dart
D3Checkbox(
  value: _isChecked,
  onChanged: (v) => setState(() => _isChecked = v),
)
```

---

### D3Radio

Styled radio button.

```dart
D3Radio<String>(
  value: 'option_a',
  groupValue: _selectedOption,
  onChanged: (v) => setState(() => _selectedOption = v),
  label: 'Option A',
)
```

---

### D3SegmentedControl

Animated segmented control for mutually exclusive selections.

```dart
D3SegmentedControl(
  segments: const [
    D3Segment(value: 'list',  label: 'List'),
    D3Segment(value: 'grid',  label: 'Grid'),
    D3Segment(value: 'map',   label: 'Map'),
  ],
  selected: _viewMode,
  onChanged: (v) => setState(() => _viewMode = v),
)

// With icons
D3SegmentedControl(
  segments: const [
    D3Segment(value: 0, icon: Icons.view_list),
    D3Segment(value: 1, icon: Icons.grid_view),
  ],
  selected: _tabIndex,
  onChanged: (v) => setState(() => _tabIndex = v),
)
```

---

### D3Chip

Compact label chip, available in multiple variants.

```dart
D3Chip(label: 'Flutter')
D3Chip(label: 'Action', variant: D3ChipVariant.filled, onTap: _handleTap)
D3Chip(label: 'Filter', onDismiss: _removeFilter)
```

**Variants** — `flat` (default), `filled`, `outlined`

---

### D3SearchBar / D3SearchAnchor

Search input with optional suggestions overlay.

```dart
D3SearchBar(
  hint: 'Search anime…',
  onChanged: _search,
)

D3SearchAnchor(
  hint: 'Search…',
  suggestionsBuilder: (context, controller) => [
    ListTile(title: Text('Result 1'), onTap: () {}),
  ],
)
```

---

### D3Avatar

User avatar with image, initials fallback, status indicators, and group stacking.

```dart
// Image avatar
D3Avatar(
  imageUrl: user.avatarUrl,
  size: D3AvatarSize.md,
)

// Initials fallback
D3Avatar(
  initials: 'DL',
  size: D3AvatarSize.lg,
)

// With status indicator
D3Avatar(
  imageUrl: user.avatarUrl,
  indicator: D3AvatarIndicator.online,
)

// Stacked group
D3AvatarGroup(
  avatars: users.map((u) => D3Avatar(imageUrl: u.avatarUrl)).toList(),
  maxVisible: 3,
)
```

**Sizes** — `xs` (24), `sm` (32), `md` (40), `lg` (48), `xl` (56), `xxl` (72)

**Shapes** — `circle` (default), `square`

**Indicators** — `none`, `online`, `busy`, `offline`

---

### D3NavBar

Bottom navigation bar.

```dart
D3NavBar(
  items: const [
    D3NavItem(icon: Icons.home_outlined,    activeIcon: Icons.home,    label: 'Home'),
    D3NavItem(icon: Icons.search_outlined,                              label: 'Search'),
    D3NavItem(icon: Icons.person_outlined,  activeIcon: Icons.person,  label: 'Profile'),
  ],
  currentIndex: _currentTab,
  onTap: (i) => setState(() => _currentTab = i),
)
```

---

### D3Screen

Opinionated screen scaffold with a collapsing large title, app bar actions, and flexible layout modes.

```dart
D3Screen(
  title: 'Library',
  leading: D3ScreenLeading.back,
  actions: [
    D3ScreenAction.icon(Icons.filter_list, onPressed: _openFilter),
  ],
  child: _buildContent(),
)

// Sliver layout for scroll-aware collapsing title
D3Screen(
  title: 'Discover',
  layout: D3ScreenLayout.sliver,
  sliver: SliverList(delegate: SliverChildBuilderDelegate(_buildItem)),
)
```

**Leading options** — `D3ScreenLeading.back`, `.cancel`, `.none`, `.custom(widget)`

---

### D3Card

Surface card with optional header, media, and tap handler.

```dart
D3Card(
  child: Text('Simple card'),
)

D3Card(
  variant: D3CardVariant.elevated,
  onTap: _openDetail,
  header: D3CardHeader(title: 'Episode 1', subtitle: '24 min'),
  child: _buildContent(),
)
```

---

### D3ListTile

Styled list tile.

```dart
D3ListTile(
  title: 'Attack on Titan',
  subtitle: 'Action · 4 seasons',
  leading: D3Avatar(imageUrl: show.thumbnail),
  trailing: const Icon(Icons.chevron_right),
  onTap: () => _openDetail(show),
)
```

---

### D3Dialog

Alert dialog with icon, title, message, and stacked or inline actions.

```dart
D3Dialog.show(
  context: context,
  title: 'Delete List',
  message: 'This action cannot be undone.',
  icon: Icons.delete_outline,
  actions: [
    D3DialogAction(
      label: 'Cancel',
      variant: D3ButtonVariant.outlined,
      onPressed: () => Navigator.pop(context),
    ),
    D3DialogAction(
      label: 'Delete',
      variant: D3ButtonVariant.danger,
      onPressed: _deleteList,
    ),
  ],
);
```

---

### D3BottomSheet

Draggable bottom sheet with optional snap points, header, and sticky footer.

```dart
D3BottomSheet.show<void>(
  context: context,
  title: 'Sort By',
  snapPoints: [D3SnapPoint(0.4), D3SnapPoint(0.85)],
  builder: (context) => _buildSortOptions(),
);
```

---

### D3Toast

Snackbar-style toast with variants and an optional action.

```dart
D3Toast.show(
  context: context,
  message: 'Added to watchlist',
  variant: D3ToastVariant.success,
)

D3Toast.show(
  context: context,
  message: 'Failed to sync',
  variant: D3ToastVariant.error,
  action: D3ToastAction(label: 'Retry', onPressed: _retry),
)
```

**Variants** — `success`, `error`, `warning`, `info`, `neutral`

---

### D3Skeleton

Loading placeholder shimmer for any shape.

```dart
D3Skeleton(width: 200, height: 16)              // line
D3Skeleton.circle(size: 40)                     // avatar placeholder
D3Skeleton(width: double.infinity, height: 120) // block
```

---

### D3EmptyState

Zero-data state with icon, title, subtitle, and optional action.

```dart
D3EmptyState(
  icon: Icons.bookmark_outline,
  title: 'Nothing saved yet',
  subtitle: 'Tap the bookmark icon on any title to save it here.',
  action: D3Button(label: 'Browse', onPressed: _browse),
)
```

---

### D3Image

Network image with loading skeleton and error fallback.

```dart
D3Image(
  url: item.posterUrl,
  width: 120,
  height: 180,
  radius: D3Radius.md,
)
```

---

## Customising Tokens

Pass `overrides` to the theme factories to customise any token without rebuilding from scratch:

```dart
D3AppTheme.dark(
  overrides: D3TokensExtension.dark.copyWith(
    colors: D3ColorTokens.dark.copyWith(primary: Colors.purple),
  ),
)
```

---

## License

MIT — see [LICENSE](LICENSE).
