# d3_ui — UX & Navigation Guidelines

Companion to `README.md` (component/API reference). This doc covers
*behavior*, not visual style: navigation, screen states, form interaction,
and motion — the conventions every app sharing `d3_ui` should follow so
screens built by different people (or by an AI agent) still feel
consistent without needing Figma or a shared design-doc workflow.
Text-only, deliberately — no wireframes or mockups in scope.

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

## Modal surfaces — which one, and when

`d3_ui` ships five ways to interrupt the user's current screen:
`D3BottomSheet`, `D3FormSheet`, `D3Dialog` (+ `D3CalendarPicker`),
`D3DropdownField`'s `popup` mode, and a plain pushed route. Picking wrong
either makes a quick task feel heavier than it is, or nests modals in a
way that breaks the "I'll be right back" contract a sheet is supposed to
signal — e.g. a form sheet whose own picker field opens a second,
independently-scrimmed sheet, whose own "add new" action opens a third.
This section exists so that never needs rediscovering per app.

**Base the choice on task depth, not on "does a sheet look nicer here."**
Both Material Design 3 and Apple's Human Interface Guidelines converge on
the same axis for this decision — how much focus and space the task
genuinely needs — even though the two platforms differ on tone/motion:

| Task shape | Material 3 says | Apple HIG says | `d3_ui` component |
|---|---|---|---|
| A single bounded choice from a short, static list (≤5 items) | anchored popup/menu | a menu/popover | `D3DropdownField(mode: popup)` |
| A quick, contained action that doesn't need the user's full focus, with the calling screen still meaningfully relevant | modal bottom sheet | a sheet ("some of the parent view remains visible... helping people retain their original context") | `D3BottomSheet` / `D3FormSheet` |
| A prompt requiring a decision before continuing, no meaningful body content beyond the question itself | dialog | an alert | `D3Dialog` |
| A genuinely deep or multi-step task — real scrollable content, several fields, or a task that benefits from the user's undivided attention | full-screen dialog ("minimizes the appearance of stacked sheets of material") | full-screen modal ("in-depth content or a complex task... minimizes distractions") | pushed route (`D3Screen`) |

**Never open a second modal surface from inside a `D3BottomSheet`/
`D3FormSheet`/`D3Dialog`'s content.** Both platforms name this
specifically as a failure mode, not just a style preference — Material 3
calls out avoiding "stacked sheets of material (dialogs above dialogs)";
it is the mechanism that makes a nested picker-with-quick-add feel like
navigating deeper rather than doing one contained thing. Concretely:

- **A picker inside an already-open sheet should default to
  `D3DropdownMode.popup`** (anchored, no independent scrim) rather than
  `sheet` mode, even if that same field would use `sheet` mode when
  reached from a normal screen — the calling context, not just the list
  length, decides. Reserve nested `sheet` mode for a list genuinely too
  long for an anchored popup to work at all, and treat that as a signal
  the flow itself may need rethinking, not a routine choice.
- **A "quick add new item" affordance inside a picker (a search bar's
  "+ New" action, an empty-state "create one" prompt) should expand
  in-place within the same sheet/popup**, not push a second
  `D3BottomSheet`/`D3FormSheet`. Capture only what's needed to select the
  new item (usually just a name) — defer full editing (notes, secondary
  fields) to the record's own dedicated edit screen, reached later, not
  mid-flow. This mirrors how neither platform's picker/menu components
  spawn an unrelated modal for "create new" — they resolve it inline.
- **A confirmation dialog (discard guard, destructive-action confirm) is
  the one exception** — `D3Dialog.show` from inside a sheet's own
  `onConfirmDiscard` or a delete action is expected and fine, since it's
  answering a direct question about the sheet's own content, not
  navigating to an unrelated task. Don't generalize the "no modal inside
  a modal" rule to forbid this.

**When in doubt, prefer the shallower surface.** A popup that turns out
to need search later is a small, additive change (flip `mode` to
`sheet`); a nested sheet that turns out to feel too deep requires
restructuring an already-shipped flow, which is the more expensive
direction to be wrong in.

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

## Multi-select rows

- **The selection indicator replaces a row's existing leading widget in
  place — it is never added beside the row.** Use `D3SelectionLeading`,
  passing the row's normal leading widget (an avatar, an icon) as its
  `child` and that widget's own dimension as `size`. Entering selection
  mode then changes only what sits inside the leading slot; the card's
  width and everything inside it stay exactly where they were. The
  tempting alternative — wrapping the card in an outer `Row` with a
  `D3SelectCircle` beside it and the card in an `Expanded` — shrinks the
  card and reflows every element inside it the moment selection starts,
  which reads as a lot of simultaneous movement for what is conceptually
  one small state change.
- **A row with no leading widget to repurpose should make space for one
  rather than wrapping from outside** — pass a same-sized placeholder as
  `child`. Keeping the indicator inside the card's own bounds is the
  property that matters; repurposing an avatar is just the neatest case.
- **Selection changes only via the indicator or a long-press — never a
  tap on the row body.** Long-press starts (and extends) a selection;
  tapping the indicator adds or removes that one row. `D3SelectionLeading`
  wires this through its `onToggle` — hand it the `onAvatarTap` callback
  `D3List` already passes to `itemBuilder`.
- **A row's own `onTap` keeps working during selection.** Point the card's
  `onTap` at its normal behavior (opening the record) and leave it wired
  in both modes — don't branch it on `inSelectionMode`, and never point it
  at the selection toggle. This is a deliberate departure from the common
  platform convention where a body tap toggles: a tap that silently drops
  a selection the user has been assembling is the more costly surprise,
  and the indicator gives them an unambiguous target for changing it.

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
- **In a `D3FormSheet`, put the confirming action in the header** via
  `primaryAction: D3FormSheetAction(label: 'Save', ...)` rather than a
  full-width button at the bottom of the form body. Cancel then moves to
  the header's leading side automatically, giving every form sheet the
  same leading/trailing shape `D3Screen` already uses. Use `enabled` to
  gate it on a valid form and `isLoading` while the save is in flight;
  the action does **not** close the sheet itself, so call
  `D3FormSheet.pop` once the save succeeds and a failed save can leave
  the form open with the user's input intact.
- **Required fields:** mark visually (e.g. `D3TextField`'s built-in
  required/label handling) rather than relying on a submit-time error
  alone to communicate that a field is mandatory.

## Read-only / locked state

- **One widget, one visual language, gated by a flag — never two
  differently-styled widgets switched by a caller-supplied boolean.**
  When a record can be "locked" or otherwise made non-editable (a
  finished/locked visit, a submitted form, an archived record), the
  same field/card/row widget should render in both states, with a
  single internal flag (e.g. `isReadOnly`) changing its *appearance*
  — not a parent choosing between two structurally different widgets
  (e.g. a plain `Text`-based summary card vs. a `D3TextField`-based
  editable card) depending on lock state. Two widgets drift: one gets
  a bug fix or a layout tweak the other doesn't, and the user sees the
  same conceptual field look and behave differently depending on a
  code path they can't see. A consuming app that starts with a
  `showEditableHeader`-style flag choosing between two structurally
  different card widgets should merge them into one, gated by
  `isReadOnly`, at the first opportunity — treat "two widgets for one
  concept, chosen by a flag" as a smell to fix on sight in any app
  sharing `d3_ui`, not a shape to introduce fresh in a new screen.
- **Read-only styling belongs in the field's own status resolution,
  not in the focus/interaction layer.** `D3TextField`/`D3DateField`
  already compute one `D3FieldStatus` (idle/focused/filled/error/
  success/disabled) that drives all their styling; a read-only field
  should resolve to `D3FieldStatus.disabled` from that same status
  getter (`isReadOnly || !isEnabled`), not by nulling out or
  disconnecting the field's `FocusNode`. Stripping the focus node to
  fake a read-only look breaks the widget's documented external-
  focus-node contract and its listener lifecycle (a node reconnected
  only in `initState` won't reattach if `isReadOnly` later flips back
  to false) — the status layer already exists for exactly this kind
  of visual-state problem, so extend it there first.
- **Field/card-level widgets take `isReadOnly`; app/domain-level
  widgets can keep their own domain name (`locked`, `isFinished`,
  `isArchived`) and translate it to `isReadOnly` at the point they
  pass it down.** `D3TextField.isReadOnly`/`D3DateField.isReadOnly`
  describe the rendering effect and should stay named that way
  regardless of *why* a field is non-editable. A screen-specific
  widget one level up (e.g. this app's `_ResultRow.locked`, wired as
  `isReadOnly: widget.locked` at its own field call sites) is fine to
  keep its domain name — it's documenting the actual trigger for
  readers of that widget, and the translation to `isReadOnly` happens
  exactly where the visual effect is applied. The smell to avoid is a
  *shared* field/card component inventing its own domain-flavored flag
  name instead of `isReadOnly`.

## Motion

- **`D3Motion` tokens are mandatory.** Never hardcode a raw
  `Duration(milliseconds: ...)` or `Curves.something` in app code — every
  animation should reference `D3Motion.fast/base/moderate/slow` and
  `D3Motion.standard/decelerate/accelerate/enter/exit` (or the
  button-specific `D3ButtonMotion` tokens), the same way spacing/color
  reference their own token sets.
- **Bias toward minimal, functional motion.** `d3_ui` targets corporate/
  form-heavy utility apps (ERP-style workflows), not consumer or
  marketing apps — animate to communicate state change (a screen
  transitioning, an item being added/removed, a button press), not for
  visual flourish. When in doubt, prefer no animation over a custom one.

---

## When this doc doesn't cover something

If a screen needs a pattern not described here (a new navigation shape, a
state this doc doesn't list, a form interaction not covered), make the
call, build it, and then consider whether the pattern is reusable enough
to add here — the same promotion instinct that governs when a component
gets added to `d3_ui` at all applies to conventions, not just components:
prove it's needed by at least one real screen before generalizing it into
a rule every consumer is expected to follow.
