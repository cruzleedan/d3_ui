import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:d3_ui/d3_ui.dart';

// ─────────────────────────────────────────────────────────────────────────────
// D3ListController
// ─────────────────────────────────────────────────────────────────────────────

/// Programmatic controller for [D3List].
///
/// ```dart
/// final _ctrl = D3ListController();
///
/// _ctrl.refresh();       // trigger pull-to-refresh
/// _ctrl.scrollToTop();   // animate to top
/// _ctrl.scrollToIndex(5);
/// _ctrl.clearSelection();
/// ```
///
/// Dispose in [State.dispose]:
/// ```dart
/// _ctrl.dispose();
/// ```
class D3ListController {
  _D3ListActions? _actions;

  void _attach(_D3ListActions actions) {
    assert(_actions == null, 'D3ListController is already attached to a D3List.');
    _actions = actions;
  }

  void _detach() => _actions = null;

  void refresh() => _actions?.refresh();
  void loadMore() => _actions?.loadMore();

  void scrollToIndex(
    int index, {
    Duration duration = D3Motion.moderate,
    Curve curve = D3Motion.standard,
  }) =>
      _actions?.scrollToIndex(index, duration: duration, curve: curve);

  void scrollToTop({
    Duration duration = D3Motion.moderate,
    Curve curve = D3Motion.decelerate,
  }) =>
      _actions?.scrollToTop(duration: duration, curve: curve);

  void scrollToBottom({
    Duration duration = D3Motion.moderate,
    Curve curve = D3Motion.decelerate,
  }) =>
      _actions?.scrollToBottom(duration: duration, curve: curve);

  /// Programmatically clear all selections.
  void clearSelection() => _actions?.clearSelection();

  void dispose() => _actions = null;
}

abstract interface class _D3ListActions {
  void refresh();
  void loadMore();
  void scrollToIndex(int index, {required Duration duration, required Curve curve});
  void scrollToTop({required Duration duration, required Curve curve});
  void scrollToBottom({required Duration duration, required Curve curve});
  void clearSelection();
}

// ─────────────────────────────────────────────────────────────────────────────
// D3List
// ─────────────────────────────────────────────────────────────────────────────

/// A generic scrollable list with pull-to-refresh, infinite scroll, section
/// headers, empty states, initial loading, and optional multi-selection mode.
///
/// **Basic usage:**
/// ```dart
/// D3List<Contact>(
///   items: _contacts,
///   itemBuilder: (context, contact, index) => D3ListTile(
///     title: contact.name,
///     subtitle: contact.email,
///     onTap: () => _open(contact),
///   ),
///   onRefresh: _fetchContacts,
///   onLoadMore: _fetchMore,
///   hasMore: _hasMorePages,
/// )
/// ```
///
/// **Selection mode (Gmail-style):**
///
/// Long-press any item to enter selection mode. Subsequent taps toggle
/// individual items. A checkmark animates in on the left of each item.
/// The list calls [onSelectionChanged] on every change; the parent
/// decides what to show in the contextual action bar.
///
/// ```dart
/// D3List<Email>(
///   items: _emails,
///   itemBuilder: (context, email, index) => D3ListTile(title: email.subject),
///   selectable: true,
///   getItemId: (email) => email.id,
///   selectedIds: _selectedIds,
///   onSelectionChanged: (ids) => setState(() => _selectedIds = ids),
/// )
/// ```
class D3List<T> extends StatefulWidget {
  const D3List({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.controller,
    this.onRefresh,
    this.onLoadMore,
    this.hasMore = false,
    this.isLoading = false,
    this.emptyState,
    this.sectionBuilder,
    this.separatorBuilder,
    this.loadMoreThreshold = 200.0,
    this.padding,
    // Selection
    this.selectable = false,
    this.getItemId,
    this.selectedIds = const {},
    this.onSelectionChanged,
  }) : assert(
          !selectable || getItemId != null,
          'D3List: getItemId is required when selectable is true.',
        );

  final List<T> items;
  final Widget Function(
    BuildContext context,
    T item,
    int index, {
    bool isSelected,
    bool inSelectionMode,
    VoidCallback? onAvatarTap,
  }) itemBuilder;
  final D3ListController? controller;
  final Future<void> Function()? onRefresh;
  final Future<void> Function()? onLoadMore;
  final bool hasMore;
  final bool isLoading;
  final Widget? emptyState;
  final String? Function(BuildContext context, T item, int index)? sectionBuilder;
  final Widget Function(BuildContext context, int index)? separatorBuilder;
  final double loadMoreThreshold;
  final EdgeInsetsGeometry? padding;

  /// When true, long-press enters selection mode and taps toggle items.
  final bool selectable;

  /// Returns a stable unique ID for an item. Required when [selectable] is true.
  final String Function(T item)? getItemId;

  /// The currently selected item IDs. Controlled — the parent owns this set.
  final Set<String> selectedIds;

  /// Called with the new selected set on every toggle.
  final ValueChanged<Set<String>>? onSelectionChanged;

  bool get _inSelectionMode => selectable && selectedIds.isNotEmpty;

  @override
  State<D3List<T>> createState() => _D3ListState<T>();
}

class _D3ListState<T> extends State<D3List<T>> implements _D3ListActions {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();

  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(this);
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkFillViewport());
  }

  @override
  void didUpdateWidget(D3List<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach();
      widget.controller?._attach(this);
    }
    if (oldWidget.items != widget.items) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkFillViewport());
    }
  }

  @override
  void dispose() {
    widget.controller?._detach();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // ── Scroll ─────────────────────────────────────────────────────────────────

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - widget.loadMoreThreshold &&
        widget.hasMore &&
        !_isLoadingMore) {
      _triggerLoadMore();
    }
  }

  void _checkFillViewport() {
    if (!mounted || !_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.maxScrollExtent == 0 && widget.hasMore && !_isLoadingMore) {
      _triggerLoadMore();
    }
  }

  Future<void> _triggerLoadMore() async {
    if (_isLoadingMore || widget.onLoadMore == null) return;
    setState(() => _isLoadingMore = true);
    try {
      await widget.onLoadMore!();
    } finally {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  // ── _D3ListActions ─────────────────────────────────────────────────────────

  @override
  void refresh() => _refreshKey.currentState?.show();

  @override
  void loadMore() {
    if (!widget.hasMore || _isLoadingMore) return;
    _triggerLoadMore();
  }

  @override
  void scrollToIndex(int index, {required Duration duration, required Curve curve}) {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    final count = widget.items.length;
    if (count == 0) return;
    final estimated = pos.maxScrollExtent / count;
    final target = (estimated * index).clamp(0.0, pos.maxScrollExtent);
    _scrollController.animateTo(target, duration: duration, curve: curve);
  }

  @override
  void scrollToTop({required Duration duration, required Curve curve}) {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0, duration: duration, curve: curve);
    }
  }

  @override
  void scrollToBottom({required Duration duration, required Curve curve}) {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: duration,
        curve: curve,
      );
    }
  }

  @override
  void clearSelection() {
    widget.onSelectionChanged?.call({});
  }

  // ── Selection ──────────────────────────────────────────────────────────────

  void _onLongPress(T item) {
    if (!widget.selectable) return;
    final id = widget.getItemId!(item);
    HapticFeedback.mediumImpact();
    final next = Set<String>.from(widget.selectedIds)..add(id);
    widget.onSelectionChanged?.call(next);
  }

  void _onTap(T item) {
    if (!widget._inSelectionMode) return;
    final id = widget.getItemId!(item);
    HapticFeedback.selectionClick();
    final next = Set<String>.from(widget.selectedIds);
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    widget.onSelectionChanged?.call(next);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;

    if (widget.isLoading && widget.items.isEmpty) {
      return Center(
        child: CircularProgressIndicator(strokeWidth: 2.5, color: colors.primary),
      );
    }

    if (widget.items.isEmpty) {
      final empty = widget.emptyState ??
          const D3EmptyState(
            icon: Icons.inbox_outlined,
            title: 'Nothing here yet',
            message: 'Items will appear here once they are added.',
          );
      return widget.onRefresh != null
          ? RefreshIndicator(
              key: _refreshKey,
              color: colors.primary,
              onRefresh: widget.onRefresh!,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.6,
                  child: Center(child: empty),
                ),
              ),
            )
          : Center(child: empty);
    }

    final children = _buildChildren(context);
    if (_isLoadingMore) {
      children.add(_LoadMoreFooter(color: colors.primary));
    }

    Widget list = ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: widget.padding ?? EdgeInsets.zero,
      itemCount: children.length,
      itemBuilder: (context, i) => children[i],
    );

    if (widget.onRefresh != null) {
      list = RefreshIndicator(
        key: _refreshKey,
        color: colors.primary,
        onRefresh: widget.onRefresh!,
        child: list,
      );
    }

    return list;
  }

  List<Widget> _buildChildren(BuildContext context) {
    final children = <Widget>[];
    String? lastSection;

    for (int i = 0; i < widget.items.length; i++) {
      final item = widget.items[i];

      if (widget.sectionBuilder != null) {
        final section = widget.sectionBuilder!(context, item, i);
        if (section != null && section != lastSection) {
          children.add(_SectionHeader(label: section));
          lastSection = section;
        }
      }

      if (i > 0 && widget.sectionBuilder == null) {
        children.add(
          widget.separatorBuilder != null
              ? widget.separatorBuilder!(context, i)
              : const _DefaultSeparator(),
        );
      }

      if (widget.selectable) {
        final id = widget.getItemId!(item);
        final isSelected = widget.selectedIds.contains(id);
        final built = widget.itemBuilder(
          context, item, i,
          isSelected: isSelected,
          inSelectionMode: widget._inSelectionMode,
          onAvatarTap: widget._inSelectionMode ? () => _onTap(item) : null,
        );
        children.add(
          _SelectableWrapper(
            key: ValueKey(id),
            isSelected: isSelected,
            inSelectionMode: widget._inSelectionMode,
            onTap: () => _onTap(item),
            onLongPress: () => _onLongPress(item),
            child: built,
          ),
        );
      } else {
        final built = widget.itemBuilder(
          context, item, i,
          isSelected: false,
          inSelectionMode: false,
          onAvatarTap: null,
        );
        children.add(built);
      }
    }

    return children;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SelectableWrapper
// Wraps an item with a leading animated checkbox and selection highlight.
// ─────────────────────────────────────────────────────────────────────────────

class _SelectableWrapper extends StatefulWidget {
  const _SelectableWrapper({
    super.key,
    required this.isSelected,
    required this.inSelectionMode,
    required this.onTap,
    required this.onLongPress,
    required this.child,
  });

  final bool isSelected;
  final bool inSelectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final Widget child;

  @override
  State<_SelectableWrapper> createState() => _SelectableWrapperState();
}

class _SelectableWrapperState extends State<_SelectableWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: D3ButtonMotion.pressDown,
      reverseDuration: D3ButtonMotion.pressUp,
    );
    _pressScale = Tween<double>(
      begin: 1.0,
      end: D3ButtonMotion.pressScale,
    ).animate(CurvedAnimation(
      parent: _pressCtrl,
      curve: D3ButtonMotion.pressDownCurve,
      reverseCurve: D3ButtonMotion.pressUpCurve,
    ));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.inSelectionMode ? widget.onTap : null,
      onLongPressStart: (_) {
        if (!widget.inSelectionMode) _pressCtrl.forward();
      },
      onLongPress: () {
        _pressCtrl.reverse();
        widget.onLongPress();
      },
      onLongPressCancel: () => _pressCtrl.reverse(),
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _pressScale,
        child: widget.child,
      ),
    );
  }

  bool get isSelected => widget.isSelected;
}

/// A circular check indicator used as a leading widget in selectable list items.
///
/// Drop it directly into any card's leading slot. Toggle [filled] to animate
/// between the empty ring (not selected) and filled check (selected) states
/// using [AnimatedSwitcher] in the parent.
class D3SelectCircle extends StatelessWidget {
  const D3SelectCircle({super.key, required this.filled, required this.colors});
  final bool filled;
  final D3ColorTokens colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? colors.primary : Colors.transparent,
        border: Border.all(
          color: filled ? colors.primary : colors.outline,
          width: 1.5,
        ),
      ),
      child: filled
          ? Icon(Icons.check_rounded, size: 16, color: colors.onPrimary)
          : null,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        D3Spacing.s16, D3Spacing.s10, D3Spacing.s16, D3Spacing.s4,
      ),
      color: colors.onSurface.withValues(alpha: 0.03),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: colors.onSurfaceVariant,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _DefaultSeparator extends StatelessWidget {
  const _DefaultSeparator();

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    return Divider(
      height: 0,
      thickness: 0.5,
      indent: D3Spacing.s16,
      color: colors.outline.withValues(alpha: 0.2),
    );
  }
}

class _LoadMoreFooter extends StatelessWidget {
  const _LoadMoreFooter({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: D3Spacing.s20),
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: color),
        ),
      ),
    );
  }
}
