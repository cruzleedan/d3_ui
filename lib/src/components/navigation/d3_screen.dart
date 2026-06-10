import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:d3_ui/d3_ui.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Supporting types
// ─────────────────────────────────────────────────────────────────────────────

/// Controls the leading (left) slot of a [D3Screen] app bar.
///
/// The default when no value is passed is auto-detection:
/// [D3Screen] shows `.back` when `Navigator.canPop(context)` is true,
/// and nothing otherwise.
sealed class D3ScreenLeading {
  const D3ScreenLeading._();

  /// Left-pointing arrow icon. Calls `Navigator.pop()` on tap.
  static const D3ScreenLeading back = _Back();

  /// "Cancel" text button placed on the *right* side (iOS modal convention).
  /// When used, [D3Screen.actions] must be empty — a debug assertion enforces this.
  static const D3ScreenLeading cancel = _Cancel();

  /// No leading widget. Suppresses auto-detection.
  static const D3ScreenLeading none = _None();

  /// Arbitrary widget in the leading slot.
  factory D3ScreenLeading.custom(Widget widget) => _Custom(widget);
}

final class _Back extends D3ScreenLeading {
  const _Back() : super._();
}

final class _Cancel extends D3ScreenLeading {
  const _Cancel() : super._();
}

final class _None extends D3ScreenLeading {
  const _None() : super._();
}

final class _Custom extends D3ScreenLeading {
  const _Custom(this.widget) : super._();
  final Widget widget;
}

// ─────────────────────────────────────────────────────────────────────────────

/// Controls the overall layout of [D3Screen].
enum D3ScreenLayout {
  /// Fixed-height toolbar. Default. Works with any body widget.
  box,

  /// Large title that collapses into the compact toolbar as the user scrolls.
  /// Requires a [CustomScrollView] as the [D3Screen.body].
  /// [D3Screen.subtitle] and [D3Screen.sliverHeader] are only supported here.
  sliver,
}

// ─────────────────────────────────────────────────────────────────────────────

/// An action placed in the trailing slot of the app bar.
sealed class D3ScreenAction {
  const D3ScreenAction._();

  /// An icon button.
  factory D3ScreenAction.icon(
    IconData icon, {
    required VoidCallback onPressed,
    String? semanticsLabel,
  }) =>
      _IconAction(
          icon: icon, onPressed: onPressed, semanticsLabel: semanticsLabel);

  /// A text button (e.g. "Save", "Done").
  factory D3ScreenAction.text(
    String label, {
    required VoidCallback onPressed,
  }) =>
      _TextAction(label: label, onPressed: onPressed);

  /// An arbitrary widget in the trailing slot (e.g. a status indicator).
  factory D3ScreenAction.widget(Widget child) => _WidgetAction(child);
}

final class _WidgetAction extends D3ScreenAction {
  const _WidgetAction(this.child) : super._();
  final Widget child;
}

final class _IconAction extends D3ScreenAction {
  const _IconAction({
    required this.icon,
    required this.onPressed,
    this.semanticsLabel,
  }) : super._();
  final IconData icon;
  final VoidCallback onPressed;
  final String? semanticsLabel;
}

final class _TextAction extends D3ScreenAction {
  const _TextAction({required this.label, required this.onPressed}) : super._();
  final String label;
  final VoidCallback onPressed;
}

// ─────────────────────────────────────────────────────────────────────────────
// D3Screen
// ─────────────────────────────────────────────────────────────────────────────

/// Scaffold wrapper that standardises app-bar style, leading behaviour,
/// and sliver/box layout across the app.
///
/// ## Box (default)
/// ```dart
/// D3Screen(
///   title: 'Profile',
///   body: ListView(...),
/// )
/// ```
///
/// ## Sliver — large collapsing title
/// ```dart
/// D3Screen(
///   title: 'Contacts',
///   subtitle: '12 people',
///   layout: D3ScreenLayout.sliver,
///   sliverHeader: D3SearchBar(hint: 'Search…'),
///   body: CustomScrollView(
///     slivers: [
///       SliverList.builder(...),
///     ],
///   ),
/// )
/// ```
///
/// ## Modal sheet
/// ```dart
/// D3Screen(
///   title: 'Edit profile',
///   leading: D3ScreenLeading.cancel,
///   actions: [D3ScreenAction.text('Save', onPressed: _save)],
///   body: ...,
/// )
/// ```
class D3Screen extends StatelessWidget {
  D3Screen({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions = const [],
    this.layout = D3ScreenLayout.box,
    this.sliverHeader,
    this.tabBar,
    this.headerSlot,
    required this.body,
    this.titleBarOverride,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
  }) : assert(
          !(leading == D3ScreenLeading.cancel && actions.isNotEmpty),
          'D3Screen: actions must be empty when using D3ScreenLeading.cancel — '
          'cancel occupies the trailing slot.',
        );

  final String title;

  /// Optional subtitle shown beneath the large title in sliver layout only.
  final String? subtitle;

  /// Leading slot override. When null the component auto-detects:
  /// shows a back arrow when [Navigator.canPop] is true, nothing otherwise.
  final D3ScreenLeading? leading;

  /// Trailing actions. Rendered right-to-left (first item is outermost right).
  /// Must be empty when [leading] is [D3ScreenLeading.cancel].
  final List<D3ScreenAction> actions;

  /// [D3ScreenLayout.box] (default) or [D3ScreenLayout.sliver].
  final D3ScreenLayout layout;

  /// Widget pinned just below the large title in sliver layout.
  /// Ignored in box layout.
  final Widget? sliverHeader;

  /// Optional tab bar rendered below the compact toolbar (box layout only).
  /// Typically a [TabBar]. Ignored in sliver layout.
  final PreferredSizeWidget? tabBar;

  /// Optional widget pinned between the title bar and the body (box layout only).
  /// Retains its height at all times — use [AnimatedOpacity] inside to fade
  /// content without causing layout shifts.
  final Widget? headerSlot;

  final Widget body;

  /// When set, replaces the title bar with this widget using a crossfade.
  /// The height stays identical to the normal title bar so the body never moves.
  final Widget? titleBarOverride;

  /// Passed directly to [Scaffold.floatingActionButton].
  final Widget? floatingActionButton;

  /// Passed directly to [Scaffold.floatingActionButtonLocation].
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  final Widget? bottomNavigationBar;

  /// Defaults to [D3ColorTokens.surface].
  final Color? backgroundColor;

  final bool resizeToAvoidBottomInset;

  // ── Resolvers ─────────────────────────────────────────────────────────────

  D3ScreenLeading _resolveLeading(BuildContext context) {
    if (leading != null) return leading!;
    if (Navigator.canPop(context)) return D3ScreenLeading.back;
    return D3ScreenLeading.none;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    final bg = backgroundColor ?? colors.surface;
    final resolvedLeading = _resolveLeading(context);
    final isCancel = resolvedLeading == D3ScreenLeading.cancel;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _overlayStyle(context),
      child: Scaffold(
        backgroundColor: bg,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
        bottomNavigationBar: bottomNavigationBar,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
          child: switch (layout) {
            D3ScreenLayout.box => _BoxLayout(
                title: title,
                leading: resolvedLeading,
                isCancel: isCancel,
                actions: actions,
                tabBar: tabBar,
                headerSlot: headerSlot,
                body: body,
                colors: colors,
                titleBarOverride: titleBarOverride,
              ),
            D3ScreenLayout.sliver => _SliverLayout(
                title: title,
                subtitle: subtitle,
                leading: resolvedLeading,
                isCancel: isCancel,
                actions: actions,
                sliverHeader: sliverHeader,
                body: body,
                colors: colors,
              ),
          },
        ),
      ),
    );
  }

  SystemUiOverlayStyle _overlayStyle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
          )
        : SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
          );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Box layout
// ─────────────────────────────────────────────────────────────────────────────

class _BoxLayout extends StatelessWidget {
  const _BoxLayout({
    required this.title,
    required this.leading,
    required this.isCancel,
    required this.actions,
    required this.body,
    required this.colors,
    this.tabBar,
    this.headerSlot,
    this.titleBarOverride,
  });

  final String title;
  final D3ScreenLeading leading;
  final bool isCancel;
  final List<D3ScreenAction> actions;
  final Widget body;
  final D3ColorTokens colors;
  final PreferredSizeWidget? tabBar;
  final Widget? headerSlot;
  final Widget? titleBarOverride;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final normalBar = _CompactBar(
      title: title,
      leading: leading,
      isCancel: isCancel,
      actions: actions,
      colors: colors,
      showBorder: true,
    );

    return Column(
      children: [
        AnimatedSwitcher(
          duration: D3Motion.moderate,
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: child,
          ),
          child: titleBarOverride != null
              ? _TitleBarShell(
                  key: const ValueKey('override'),
                  topPadding: topPadding,
                  colors: colors,
                  child: titleBarOverride!,
                )
              : KeyedSubtree(
                  key: const ValueKey('normal'),
                  child: normalBar,
                ),
        ),
        if (tabBar != null) tabBar!,
        if (headerSlot != null) headerSlot!,
        Expanded(child: body),
      ],
    );
  }
}

/// Wraps an override widget in the same shell as [_CompactBar] so dimensions
/// match exactly — same background, same status-bar top padding, same 48dp height.
class _TitleBarShell extends StatelessWidget {
  const _TitleBarShell({
    super.key,
    required this.topPadding,
    required this.colors,
    required this.child,
  });

  final double topPadding;
  final D3ColorTokens colors;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        border: Border(
          bottom: BorderSide(
            color: colors.outline.withValues(alpha: 0.15),
            width: 0.5,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: SizedBox(height: 48, child: child),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sliver layout
// ─────────────────────────────────────────────────────────────────────────────

class _SliverLayout extends StatefulWidget {
  const _SliverLayout({
    required this.title,
    this.subtitle,
    required this.leading,
    required this.isCancel,
    required this.actions,
    this.sliverHeader,
    required this.body,
    required this.colors,
  });

  final String title;
  final String? subtitle;
  final D3ScreenLeading leading;
  final bool isCancel;
  final List<D3ScreenAction> actions;
  final Widget? sliverHeader;
  final Widget body;
  final D3ColorTokens colors;

  @override
  State<_SliverLayout> createState() => _SliverLayoutState();
}

class _SliverLayoutState extends State<_SliverLayout> {
  // Tracks how far the large title has scrolled out.
  // 0.0 = fully visible, 1.0 = fully collapsed.
  final _scrollController = ScrollController();

  // ValueNotifier lets _CompactBar and the hero Opacity rebuild independently
  // without triggering a full Column/CustomScrollView rebuild on every scroll.
  final _collapseProgress = ValueNotifier<double>(0.0);

  static const double _largeTitleHeight = 72.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _collapseProgress.dispose();
    super.dispose();
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    final progress = (offset / _largeTitleHeight).clamp(0.0, 1.0);
    if ((progress - _collapseProgress.value).abs() > 0.01) {
      _collapseProgress.value = progress;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extract slivers from a provided CustomScrollView body, or wrap.
    final List<Widget> bodySlivers = switch (widget.body) {
      CustomScrollView csv => csv.slivers,
      _ => [SliverToBoxAdapter(child: widget.body)],
    };

    return Column(
      children: [
        // ── Compact toolbar ───────────────────────────────────────────────
        ValueListenableBuilder<double>(
          valueListenable: _collapseProgress,
          builder: (context, progress, _) => _CompactBar(
            title: widget.title,
            leading: widget.leading,
            isCancel: widget.isCancel,
            actions: widget.actions,
            colors: widget.colors,
            showBorder: progress >= 1.0,
            titleOpacity: progress,
          ),
        ),

        // ── Scrollable area ───────────────────────────────────────────────
        Expanded(
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Large title hero
              SliverToBoxAdapter(
                child: ValueListenableBuilder<double>(
                  valueListenable: _collapseProgress,
                  builder: (context, progress, child) => Opacity(
                    opacity: (1.0 - progress * 1.5).clamp(0.0, 1.0),
                    child: child,
                  ),
                  child: _LargeTitleHero(
                    title: widget.title,
                    subtitle: widget.subtitle,
                    colors: widget.colors,
                  ),
                ),
              ),

              // Pinned sliverHeader (e.g. D3SearchBar)
              if (widget.sliverHeader != null)
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _PinnedHeaderDelegate(
                    child: widget.sliverHeader!,
                    colors: widget.colors,
                  ),
                ),

              // Body slivers
              ...bodySlivers,
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Compact toolbar
// ─────────────────────────────────────────────────────────────────────────────

class _CompactBar extends StatelessWidget {
  const _CompactBar({
    required this.title,
    required this.leading,
    required this.isCancel,
    required this.actions,
    required this.colors,
    required this.showBorder,
    this.titleOpacity = 1.0,
  });

  final String title;
  final D3ScreenLeading leading;
  final bool isCancel;
  final List<D3ScreenAction> actions;
  final D3ColorTokens colors;
  final bool showBorder;

  /// 0.0 = hidden (sliver not yet collapsed), 1.0 = fully visible.
  final double titleOpacity;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return AnimatedContainer(
      duration: D3Motion.fast,
      curve: D3Motion.standard,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          bottom: BorderSide(
            color: showBorder
                ? colors.outline.withValues(alpha: 0.15)
                : Colors.transparent,
            width: 0.5,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: SizedBox(
          height: 48,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ── Center title ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 56),
                child: AnimatedOpacity(
                  opacity: titleOpacity,
                  duration: D3Motion.base,
                  curve: D3Motion.standard,
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: D3TypeScale.titleLgSize,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface,
                      height: D3TypeFace.tight,
                    ),
                  ),
                ),
              ),

              // ── Leading ───────────────────────────────────────────────────
              if (!isCancel)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: _LeadingWidget(leading: leading, colors: colors),
                  ),
                ),

              // ── Trailing (actions or cancel) ──────────────────────────────
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: isCancel
                      ? _CancelButton(colors: colors)
                      : _ActionsRow(actions: actions, colors: colors),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Leading widget
// ─────────────────────────────────────────────────────────────────────────────

class _LeadingWidget extends StatelessWidget {
  const _LeadingWidget({required this.leading, required this.colors});

  final D3ScreenLeading leading;
  final D3ColorTokens colors;

  @override
  Widget build(BuildContext context) {
    return switch (leading) {
      _Back() => _BarIconButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onPressed: () => Navigator.of(context).pop(),
          colors: colors,
          semanticsLabel: 'Back',
        ),
      _None() => const SizedBox.shrink(),
      _Custom(:final widget) => widget,
      // cancel is handled at the trailing slot — leading is empty
      _Cancel() => const SizedBox.shrink(),
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Trailing widgets
// ─────────────────────────────────────────────────────────────────────────────

class _CancelButton extends StatelessWidget {
  const _CancelButton({required this.colors});
  final D3ColorTokens colors;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Cancel',
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Text(
            'Cancel',
            style: TextStyle(
              fontSize: D3TypeScale.titleMdSize,
              fontWeight: FontWeight.w400,
              color: colors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionsRow extends StatelessWidget {
  const _ActionsRow({required this.actions, required this.colors});

  final List<D3ScreenAction> actions;
  final D3ColorTokens colors;

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children:
          actions.map((a) => _ActionWidget(action: a, colors: colors)).toList(),
    );
  }
}

class _ActionWidget extends StatelessWidget {
  const _ActionWidget({required this.action, required this.colors});

  final D3ScreenAction action;
  final D3ColorTokens colors;

  @override
  Widget build(BuildContext context) {
    return switch (action) {
      _IconAction(:final icon, :final onPressed, :final semanticsLabel) =>
        _BarIconButton(
          icon: icon,
          onPressed: onPressed,
          colors: colors,
          semanticsLabel: semanticsLabel,
        ),
      _TextAction(:final label, :final onPressed) => Semantics(
          button: true,
          child: GestureDetector(
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: D3TypeScale.titleMdSize,
                  fontWeight: FontWeight.w500,
                  color: colors.primary,
                ),
              ),
            ),
          ),
        ),
      _WidgetAction(:final child) => child,
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared icon button
// ─────────────────────────────────────────────────────────────────────────────

class _BarIconButton extends StatelessWidget {
  const _BarIconButton({
    required this.icon,
    required this.onPressed,
    required this.colors,
    this.semanticsLabel,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final D3ColorTokens colors;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Icon(
            icon,
            size: 22,
            color: colors.onSurface,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Large title hero (sliver only)
// ─────────────────────────────────────────────────────────────────────────────

class _LargeTitleHero extends StatelessWidget {
  const _LargeTitleHero({
    required this.title,
    this.subtitle,
    required this.colors,
  });

  final String title;
  final String? subtitle;
  final D3ColorTokens colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        D3Spacing.s16,
        D3Spacing.s8,
        D3Spacing.s16,
        D3Spacing.s12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: D3TypeScale.displaySmSize,
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
              height: D3TypeFace.tight,
              letterSpacing: -0.5,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 3),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: D3TypeScale.bodyMdSize,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pinned header delegate (sliver only)
// ─────────────────────────────────────────────────────────────────────────────

class _PinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  _PinnedHeaderDelegate({required this.child, required this.colors});

  final Widget child;
  final D3ColorTokens colors;

  static const double _height = 56.0;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      height: _height,
      color: colors.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: D3Spacing.s16,
        vertical: D3Spacing.s8,
      ),
      child: child,
    );
  }

  @override
  bool shouldRebuild(_PinnedHeaderDelegate old) =>
      old.child != child || old.colors != colors;
}
