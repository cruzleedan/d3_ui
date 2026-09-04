# d3_ui — UX & Navigation Guidelines

Companion to `README.md` (component/API reference). This doc covers
*behavior*, not visual style: navigation, screen states, form interaction,
and motion — the conventions every app sharing `d3_ui` should follow so
screens feel consistent without needing Figma or a design-doc workflow.

Written per `context/work/0004-d3-ui-ux-and-navigation-guidelines.md`
(workspace root) — see that item for the reasoning behind writing this
down instead of adopting a design tool. Text-only, deliberately — no
wireframes or mockups in scope.

---

## Navigation

- **Push to go deeper, pop to go back.** Don't use `pushReplacement` for
  normal forward navigation — reserve it for cases where the previous
  screen genuinely shouldn't be returned to (e.g. after completing a
  multi-step flow that shouldn't be re-entered by pressing back).
- **Let `D3Screen` handle back-button/leading-icon logic.** It
  auto-detects `Navigator.canPop(context)` and shows a back arrow only
  when appropriate — don't hand-roll leading widgets per screen. Use
  `D3ScreenLeading.cancel` only for modal/sheet-style screens (it forces
  `actions` to be empty, matching the iOS modal convention of no other
  trailing actions).
- **Page transitions: Flutter's own Material default, no override.**
  `D3AppTheme` deliberately does not set `ThemeData.pageTransitionsTheme` —
  leaving it unset gives each platform its real native default
  (`PredictiveBackPageTransitionsBuilder` on Android,
  `CupertinoPageTransitionsBuilder` on iOS/macOS, Zoom on Windows/Linux).
  Don't set a custom `pageTransitionsTheme` per-app or per-route. Decided
  over a custom transition to avoid an unbounded design/animation-tuning
  task for apps whose goal is finishing quickly, not novel motion — and
  over hand-specifying Material's defaults, which would just mean keeping
  a copy in sync with Flutter's own for no benefit.

## Screen states

Every screen that loads or lists data has four possible states. Handle
all four explicitly — don't ship a screen that only handles the happy
path:

| State | Component | Notes |
|---|---|---|
| Loading | `D3Skeleton` (`D3SkeletonBox`/`D3SkeletonText` inside a `D3Shimmer`) | Shape the skeleton to roughly match the eventual content's layout, not a generic spinner, for screens with list/card content. A centered `CircularProgressIndicator` is fine for short one-off waits (e.g. a submit action). |
| Empty | `D3EmptyState` (standard) | Icon + title + optional message + primary action (e.g. "Create your first item"). Use `compact: true` when embedding inside a card or other bounded container rather than a full screen. |
| Error | `D3EmptyState` with `iconColor: context.d3Colors.error` | Same component as empty, tinted red, with a "Try again" action wired to retry the failed operation. Don't invent a separate error-state widget. |
| Populated | (screen-specific content) | — |

`D3ListScreen` already composes search + filter chips + a selection
action bar for the common "list of records" screen shape — reach for it
before hand-building a list screen from `D3Screen` + `ListView` + loose
parts.

## Forms

- **Validation timing: `D3ValidationMode.onBlurThenChange`** (the default
  on `D3TextField` — don't override it without a specific reason). A
  field validates once the user leaves it, then re-validates live only
  once an error is already showing, so users aren't interrupted mid-typing
  on their first pass through a field but get immediate feedback once
  they're fixing a mistake. Reserve `onSubmit` for cases where validating
  earlier would be actively unhelpful (e.g. a field that depends on
  another field submitted later in the same form); reserve `onChange` for
  rare cases needing instant feedback (e.g. a live character counter
  against a hard limit).
- **Primary action placement:** bottom of the screen, full-width or
  trailing-aligned, not floating mid-form. For a `D3Screen` styled as a
  modal/sheet, prefer `D3ScreenAction.text('Save', onPressed: ...)` in the
  trailing app-bar slot over a body-embedded button.
- **Required fields:** mark visually (e.g. `D3TextField`'s built-in
  required/label handling) rather than relying on a submit-time error
  alone to communicate that a field is mandatory.

## Motion

- **`D3Motion` tokens are mandatory.** Never hardcode a raw
  `Duration(milliseconds: ...)` or `Curves.something` in app code — every
  animation should reference `D3Motion.fast/base/moderate/slow` and
  `D3Motion.standard/decelerate/accelerate/enter/exit` (or the
  button-specific `D3ButtonMotion` tokens), the same way spacing/color
  reference their own token sets.
- **Bias toward minimal, functional motion.** This workspace's apps are
  corporate/form-heavy utility apps (ERP-style workflows), not consumer or
  marketing apps — animate to communicate state change (a screen
  transitioning, an item being added/removed, a button press), not for
  visual flourish. When in doubt, prefer no animation over a custom one.

---

## When this doc doesn't cover something

If a screen needs a pattern not described here (a new navigation shape, a
state this doc doesn't list, a form interaction not covered), make the
call, build it, and then consider whether the pattern is reusable enough
to add here — the same promotion instinct as
`context/work/0003-d3-ui-per-app-style-overrides-and-component-promotion-
policy.md` applies to conventions, not just components.
