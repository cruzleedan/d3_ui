import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:d3_ui/d3_ui.dart';

// ─────────────────────────────────────────────────────────────────────────────
// D3ListScreenAction — contextual action bar entry
// ─────────────────────────────────────────────────────────────────────────────

/// A single action shown in the contextual action bar when items are selected.
class D3ListScreenAction {
  const D3ListScreenAction({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.visibleWhen,
    this.emphasized = false,
  });

  final IconData icon;
  final String label;
  final void Function(Set<String> selectedIds, VoidCallback clearSelection) onPressed;
  /// If provided, the action is only shown when this returns true.
  final bool Function(Set<String> selectedIds)? visibleWhen;

  /// When true, renders as an icon **+ visible label** pill instead of an
  /// icon-only button.
  ///
  /// Use sparingly — for the one action whose intent isn't obvious from its
  /// icon alone (e.g. "Create report" from a folder glyph could be mistaken
  /// for "open" or "move"). Most CAB actions (delete, archive, etc.) are
  /// universally recognizable from their icon and should stay icon-only to
  /// keep the bar compact.
  final bool emphasized;
}

// ─────────────────────────────────────────────────────────────────────────────
// D3ListScreen
// ─────────────────────────────────────────────────────────────────────────────

/// A fully-wired list screen template.
///
/// Composes [D3Screen] + [D3SearchAnchor] + [D3FilterChipRow] + [D3List]
/// + a contextual action bar (CAB) into one drop-in widget.
///
/// **Behaviors included out-of-the-box:**
/// - Pull-to-refresh
/// - Infinite scroll / load-more
/// - Full-screen search (Gmail-style) with optional filter chips
/// - Long-press → multi-select mode with animated checkboxes
/// - Contextual action bar that replaces the title bar when items are selected
/// - Select-all and deselect-all from the CAB
/// - Empty state, initial loading spinner
///
/// ```dart
/// D3ListScreen<ExpenseFeedItem, ExpenseFeedFilter>(
///   title: 'Expenses',
///   items: feed.items,
///   isLoading: feed.isLoading,
///   getItemId: (item) => item.id,
///   itemBuilder: (context, item, index) => _buildCard(item),
///   onRefresh: () => ref.read(feedProvider.notifier).refresh(),
///   // Search
///   searchHint: 'Search expenses & reports',
///   onSearchChanged: (query) => ref.read(feedProvider.notifier).setQuery(query),
///   // Filters
///   filterOptions: ExpenseFeedFilter.values.map((f) => D3FilterOption(
///     value: f, label: f.label, icon: f.icon,
///   )).toList(),
///   activeFilters: {feed.filter},
///   onFiltersChanged: (filters) => ref.read(feedProvider.notifier).setFilter(filters.first),
///   // CAB actions
///   selectionActions: [
///     D3ListScreenAction(
///       icon: Icons.delete_outline_rounded,
///       label: 'Delete',
///       onPressed: (ids) => _deleteMany(ids),
///     ),
///   ],
///   // Normal screen actions (visible when nothing is selected)
///   actions: [D3ScreenAction.widget(const SyncStatusIndicator())],
///   floatingActionButton: _fab,
/// )
/// ```
class D3ListScreen<T, F> extends StatefulWidget {
  const D3ListScreen({
    super.key,
    required this.title,
    required this.items,
    required this.itemBuilder,
    required this.getItemId,
    this.isLoading = false,
    this.onRefresh,
    this.onLoadMore,
    this.hasMore = false,
    this.emptyState,
    this.sectionBuilder,
    this.separatorBuilder,
    // Search
    this.searchHint = 'Search…',
    this.onSearchChanged,
    this.filterItems,
    // Filters
    this.filterOptions = const [],
    this.activeFilters = const {},
    this.defaultFilters,
    this.onFiltersChanged,
    this.multiSelectFilters = false,
    // CAB
    this.selectionActions = const [],
    // Screen chrome
    this.actions = const [],
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.padding,
  });

  // ── List data ───────────────────────────────────────────────────────────────
  final String title;
  final List<T> items;
  final Widget Function(
    BuildContext context,
    T item,
    int index, {
    bool isSelected,
    bool inSelectionMode,
    VoidCallback? onAvatarTap,
  }) itemBuilder;
  final String Function(T item) getItemId;
  final bool isLoading;
  final Future<void> Function()? onRefresh;
  final Future<void> Function()? onLoadMore;
  final bool hasMore;
  final Widget? emptyState;
  final String? Function(BuildContext context, T item, int index)? sectionBuilder;
  final Widget Function(BuildContext context, int index)? separatorBuilder;

  // ── Search ──────────────────────────────────────────────────────────────────
  final String searchHint;

  /// Called when the query changes inside the search page.
  /// Use this to filter [items] before passing them to the widget.
  final ValueChanged<String>? onSearchChanged;

  /// Filters [items] synchronously given a text query and the active filter
  /// set. Used inside the search page to keep results live as the user types
  /// or changes filter chips. When null, no in-page filtering is applied
  /// (items are shown as-is, which is only correct if [onSearchChanged] +
  /// [onFiltersChanged] already update [items] via an external state manager).
  final List<T> Function(List<T> items, String query, Set<F> activeFilters)?
      filterItems;

  // ── Filters ─────────────────────────────────────────────────────────────────
  final List<D3FilterOption<F>> filterOptions;
  final Set<F> activeFilters;
  final Set<F>? defaultFilters;
  final ValueChanged<Set<F>>? onFiltersChanged;
  final bool multiSelectFilters;

  // ── Selection / CAB ─────────────────────────────────────────────────────────
  /// Actions shown in the contextual action bar when ≥ 1 item is selected.
  /// Delete, archive, move, etc.
  final List<D3ListScreenAction> selectionActions;

  // ── Screen chrome ────────────────────────────────────────────────────────────
  /// Actions shown in the normal title bar (e.g. sync status indicator).
  final List<D3ScreenAction> actions;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final EdgeInsetsGeometry? padding;

  @override
  State<D3ListScreen<T, F>> createState() => _D3ListScreenState<T, F>();
}

class _D3ListScreenState<T, F> extends State<D3ListScreen<T, F>> {
  Set<String> _selectedIds = {};
  bool get _inSelectionMode => _selectedIds.isNotEmpty;

  final _searchCtrl = D3SearchController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSelectionChanged(Set<String> ids) {
    setState(() => _selectedIds = ids);
  }

  void _clearSelection() {
    HapticFeedback.lightImpact();
    _onSelectionChanged({});
  }

  void _selectAll() {
    HapticFeedback.lightImpact();
    final all = widget.items.map(widget.getItemId).toSet();
    _onSelectionChanged(all);
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;

    // Search anchor — hidden (zero size), opened programmatically via _searchCtrl.
    final searchAnchor = SizedBox.shrink(
      child: D3SearchAnchor<T, F>.local(
        controller: _searchCtrl,
        hint: widget.searchHint,
        items: widget.items,
        filterItems: (items, query, activeFilters) {
          widget.onSearchChanged?.call(query);
          return widget.filterItems != null
              ? widget.filterItems!(items, query, activeFilters)
              : items;
        },
        resultBuilder: (context, results, query) => D3List<T>(
          items: results,
          isLoading: widget.isLoading,
          itemBuilder: widget.itemBuilder,
          getItemId: widget.getItemId,
          selectable: true,
          selectedIds: _selectedIds,
          onSelectionChanged: _onSelectionChanged,
          emptyState: widget.emptyState,
          sectionBuilder: widget.sectionBuilder,
          separatorBuilder: widget.separatorBuilder,
          onRefresh: widget.onRefresh,
          padding: widget.padding,
        ),
        filterOptions: widget.filterOptions,
        activeFilters: widget.activeFilters,
        defaultFilters: widget.defaultFilters,
        onFiltersChanged: widget.onFiltersChanged,
        multiSelectFilters: widget.multiSelectFilters,
      ),
    );

    final list = D3List<T>(
      items: widget.items,
      isLoading: widget.isLoading,
      itemBuilder: widget.itemBuilder,
      getItemId: widget.getItemId,
      selectable: true,
      selectedIds: _selectedIds,
      onSelectionChanged: _onSelectionChanged,
      emptyState: widget.emptyState,
      sectionBuilder: widget.sectionBuilder,
      separatorBuilder: widget.separatorBuilder,
      onRefresh: widget.onRefresh,
      onLoadMore: widget.onLoadMore,
      hasMore: widget.hasMore,
      padding: widget.padding,
    );

    // CAB replaces the title bar in-place — body never moves.
    final cab = _ContextualActionBar(
      selectedCount: _selectedIds.length,
      actions: widget.selectionActions,
      selectedIds: _selectedIds,
      onClear: _clearSelection,
      colors: colors,
    );

    // Sub-header: single fixed-height row, content morphs between modes.
    // Left: select-all checkbox. Right: search icon + active filter pill.
    // Nothing changes size — zero layout shift.
    final subHeader = _SubHeaderRow<T, F>(
      inSelectionMode: _inSelectionMode,
      selectedCount: _selectedIds.length,
      totalCount: widget.items.length,
      onSelectAll: _selectAll,
      onClearAll: _clearSelection,
      onOpenSearch: widget.onSearchChanged != null ? _searchCtrl.open : null,
      filterOptions: widget.filterOptions,
      activeFilters: widget.activeFilters,
      defaultFilters: widget.defaultFilters,
      onFiltersChanged: widget.onFiltersChanged,
      colors: colors,
    );

    return D3Screen(
      title: widget.title,
      actions: widget.actions,
      floatingActionButton:
          _inSelectionMode ? null : widget.floatingActionButton,
      floatingActionButtonLocation: widget.floatingActionButtonLocation,
      bottomNavigationBar: widget.bottomNavigationBar,
      titleBarOverride: _inSelectionMode ? cab : null,
      headerSlot: subHeader,
      body: Column(
        children: [
          searchAnchor,
          Expanded(child: list),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ContextualActionBar
// ─────────────────────────────────────────────────────────────────────────────


// ─────────────────────────────────────────────────────────────────────────────
// _ContextualActionBar
// ─────────────────────────────────────────────────────────────────────────────

class _ContextualActionBar extends StatelessWidget {
  const _ContextualActionBar({
    required this.selectedCount,
    required this.actions,
    required this.selectedIds,
    required this.onClear,
    required this.colors,
  });

  final int selectedCount;
  final List<D3ListScreenAction> actions;
  final Set<String> selectedIds;
  final VoidCallback onClear;
  final D3ColorTokens colors;

  @override
  Widget build(BuildContext context) {
    return Row(
            children: [
              // Close / deselect
              _BarIconButton(
                icon: Icons.close_rounded,
                label: 'Deselect all',
                onPressed: onClear,
                color: colors.onPrimaryContainer,
              ),

              const SizedBox(width: D3Spacing.s4),

              // Count label
              Expanded(
                child: Text(
                  '$selectedCount selected',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colors.onPrimaryContainer,
                  ),
                ),
              ),

              // Caller-provided actions (hidden when visibleWhen returns false)
              for (final action in actions)
                if (action.visibleWhen == null || action.visibleWhen!(selectedIds))
                  if (action.emphasized)
                    _BarLabeledButton(
                      icon: action.icon,
                      label: action.label,
                      onPressed: () => action.onPressed(selectedIds, onClear),
                      color: colors.onPrimaryContainer,
                    )
                  else
                    _BarIconButton(
                      icon: action.icon,
                      label: action.label,
                      onPressed: () => action.onPressed(selectedIds, onClear),
                      color: colors.onPrimaryContainer,
                    ),

              const SizedBox(width: D3Spacing.s4),
            ],
          );
  }
}

class _BarIconButton extends StatelessWidget {
  const _BarIconButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        borderRadius: BorderRadius.circular(D3Radius.full),
        child: Padding(
          padding: const EdgeInsets.all(D3Spacing.s12),
          child: Icon(icon, size: 22, color: color),
        ),
      ),
    );
  }
}

/// Icon + visible label pill — used for [D3ListScreenAction.emphasized]
/// actions whose intent isn't obvious from the icon alone.
class _BarLabeledButton extends StatelessWidget {
  const _BarLabeledButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        borderRadius: BorderRadius.circular(D3Radius.full),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: D3Spacing.s4),
          padding: const EdgeInsets.symmetric(
            horizontal: D3Spacing.s12,
            vertical: D3Spacing.s8,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(D3Radius.full),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: D3Spacing.s6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
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
// _SubHeaderRow
// Fixed-height row below the title bar. Content morphs between modes:
//   Normal:    [select-all checkbox]  ───────────  [search icon] [filter pill]
//   Selection: [select-all checkbox (active)]  ───────────────────────────────
// Height never changes → zero layout shift.
// ─────────────────────────────────────────────────────────────────────────────

class _SubHeaderRow<T, F> extends StatefulWidget {
  const _SubHeaderRow({
    required this.inSelectionMode,
    required this.selectedCount,
    required this.totalCount,
    required this.onSelectAll,
    required this.onClearAll,
    required this.colors,
    this.onOpenSearch,
    this.filterOptions = const [],
    this.activeFilters = const {},
    this.defaultFilters,
    this.onFiltersChanged,
  });

  final bool inSelectionMode;
  final int selectedCount;
  final int totalCount;
  final VoidCallback onSelectAll;
  final VoidCallback onClearAll;
  final D3ColorTokens colors;
  final VoidCallback? onOpenSearch;
  final List<D3FilterOption<F>> filterOptions;
  final Set<F> activeFilters;
  final Set<F>? defaultFilters;
  final ValueChanged<Set<F>>? onFiltersChanged;

  @override
  State<_SubHeaderRow<T, F>> createState() => _SubHeaderRowState<T, F>();
}

class _SubHeaderRowState<T, F> extends State<_SubHeaderRow<T, F>> {
  final _pillKey = GlobalKey();

  bool get _allSelected =>
      widget.selectedCount == widget.totalCount && widget.totalCount > 0;

  // Returns the label of the currently active filter, or null if default.
  String? get _activeFilterLabel {
    if (widget.filterOptions.isEmpty) return null;
    if (widget.activeFilters.isEmpty) return null;
    final def = widget.defaultFilters;
    if (def != null &&
        widget.activeFilters.length == def.length &&
        widget.activeFilters.every(def.contains)) {
      return null;
    }
    final match = widget.filterOptions
        .where((o) => widget.activeFilters.contains(o.value));
    if (match.isEmpty) return null;
    return match.first.label;
  }

  void _openFilterMenu() {
    if (widget.filterOptions.isEmpty || widget.onFiltersChanged == null) return;
    final box = _pillKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final offset = box.localToGlobal(Offset.zero);
    final anchor = offset & box.size;
    final current =
        widget.activeFilters.isEmpty ? null : widget.activeFilters.first;
    final colors = widget.colors;
    showMenu<F>(
      context: context,
      useRootNavigator: false,
      position: RelativeRect.fromLTRB(
        anchor.left, anchor.bottom,
        MediaQuery.sizeOf(context).width - anchor.right, 0,
      ),
      items: widget.filterOptions
          .map((o) => PopupMenuItem<F>(
                value: o.value,
                child: Row(
                  children: [
                    if (o.value == current)
                      Icon(Icons.check_rounded, size: 16, color: colors.primary)
                    else
                      const SizedBox(width: 16),
                    const SizedBox(width: D3Spacing.s8),
                    if (o.icon != null) ...[
                      Icon(o.icon, size: 16, color: colors.onSurfaceVariant),
                      const SizedBox(width: D3Spacing.s8),
                    ],
                    Text(o.label),
                  ],
                ),
              ))
          .toList(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(D3Radius.md),
      ),
      color: colors.surface,
      elevation: 3,
    ).then((selected) {
      if (selected != null) widget.onFiltersChanged!({selected});
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final activeLabel = _activeFilterLabel;
    final isFiltered = activeLabel != null;

    // Align checkbox center with card avatar center, text with card title:
    //   card margin=16, card inner padding=12, avatar=32dp (center at 16dp)
    //   → avatar center = 16+12+16 = 44dp from screen edge
    //   → title left   = 16+12+32+12 = 72dp from screen edge
    // checkbox is 20dp wide → left inset = 44 - 10 = 34dp
    // text gap after checkbox = 72 - (34 + 20) = 18dp
    const double checkboxLeft = 34.0;
    const double textGap = 18.0;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colors.outline.withValues(alpha: 0.12),
            width: 0.5,
          ),
        ),
      ),
      child: SizedBox(
      height: 48,
      child: Row(
        children: [
          // ── Select-all (full-height tap target) ───────────────────────
          GestureDetector(
            onTap: widget.inSelectionMode
                ? (_allSelected ? widget.onClearAll : widget.onSelectAll)
                : null,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.only(
                left: checkboxLeft,
                right: D3Spacing.s16,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: D3Motion.fast,
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: _allSelected
                        ? Icon(
                            key: const ValueKey('checked'),
                            Icons.check_box_rounded,
                            size: 20,
                            color: colors.primary,
                          )
                        : Icon(
                            key: const ValueKey('unchecked'),
                            Icons.check_box_outline_blank_rounded,
                            size: 20,
                            color: widget.inSelectionMode
                                ? colors.onSurfaceVariant
                                : colors.onSurfaceVariant.withValues(alpha: 0.25),
                          ),
                  ),
                  // Label only shown in selection mode
                  if (widget.inSelectionMode) ...[
                    SizedBox(width: textGap),
                    AnimatedSwitcher(
                      duration: D3Motion.fast,
                      transitionBuilder: (child, anim) =>
                          FadeTransition(opacity: anim, child: child),
                      child: Text(
                        key: ValueKey(_allSelected ? 'deselect' : 'select'),
                        _allSelected ? 'Deselect all' : 'Select all',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const Spacer(),

          // ── Right side: fades out in selection mode ────────────────────
          AnimatedOpacity(
            opacity: widget.inSelectionMode ? 0.0 : 1.0,
            duration: D3Motion.moderate,
            child: IgnorePointer(
              ignoring: widget.inSelectionMode,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Filter pill — taps open popup menu
                  if (widget.filterOptions.isNotEmpty)
                    GestureDetector(
                      key: _pillKey,
                      onTap: _openFilterMenu,
                      behavior: HitTestBehavior.opaque,
                      child: SizedBox(
                        height: 48,
                        child: Center(
                          child: AnimatedContainer(
                            duration: D3Motion.fast,
                            padding: const EdgeInsets.symmetric(
                              horizontal: D3Spacing.s12,
                              vertical: D3Spacing.s6,
                            ),
                            decoration: BoxDecoration(
                              color: isFiltered
                                  ? colors.primary.withValues(alpha: 0.12)
                                  : colors.onSurface.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(D3Radius.full),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  activeLabel ?? widget.filterOptions.first.label,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: isFiltered
                                        ? colors.primary
                                        : colors.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(width: D3Spacing.s2),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 14,
                                  color: isFiltered
                                      ? colors.primary
                                      : colors.onSurfaceVariant,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Search icon — 48×48 tap target
                  if (widget.onOpenSearch != null)
                    const SizedBox(width: D3Spacing.s4),
                  if (widget.onOpenSearch != null)
                    GestureDetector(
                      onTap: widget.onOpenSearch,
                      behavior: HitTestBehavior.opaque,
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: Icon(
                          Icons.search_rounded,
                          size: 22,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    )); // SizedBox + DecoratedBox
  }
}
