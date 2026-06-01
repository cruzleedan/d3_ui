import 'package:flutter/material.dart';
import 'package:d3_ui/d3_ui.dart';

// ─────────────────────────────────────────────────────────────────────────────
// D3ListController
// ─────────────────────────────────────────────────────────────────────────────

/// Programmatic controller for [D3List].
///
/// Attach to a list via the [D3List.controller] parameter and use the exposed
/// methods to drive behaviour from outside the widget tree.
///
/// ```dart
/// final _controller = D3ListController();
///
/// // Trigger a refresh (e.g. after a push notification arrives)
/// _controller.refresh();
///
/// // Jump to the top after adding an item
/// _controller.scrollToTop();
///
/// // Scroll to a specific item index
/// _controller.scrollToIndex(12);
/// ```
///
/// Dispose the controller when it is no longer needed:
/// ```dart
/// @override
/// void dispose() {
///   _controller.dispose();
///   super.dispose();
/// }
/// ```
class D3ListController {
  _D3ListActions? _actions;

  // Called by _D3ListState on initState.
  void _attach(_D3ListActions actions) {
    assert(
      _actions == null,
      'D3ListController is already attached to a D3List.',
    );
    _actions = actions;
  }

  // Called by _D3ListState on dispose.
  void _detach() => _actions = null;

  /// Programmatically trigger a pull-to-refresh.
  /// No-op when [D3List.onRefresh] is null or the list is not mounted.
  void refresh() => _actions?.refresh();

  /// Programmatically trigger the load-more callback.
  /// No-op when [D3List.onLoadMore] is null, [D3List.hasMore] is false,
  /// or the list is not mounted.
  void loadMore() => _actions?.loadMore();

  /// Animate the list to [index].
  ///
  /// Because [D3List] may insert section headers between items, [index] refers
  /// to the data item index (not the underlying [ListView] child index). The
  /// controller maps it to the correct scroll position automatically.
  void scrollToIndex(
    int index, {
    Duration duration = D3Motion.moderate,
    Curve curve = D3Motion.standard,
  }) =>
      _actions?.scrollToIndex(index, duration: duration, curve: curve);

  /// Animate the scroll position to the top of the list.
  void scrollToTop({
    Duration duration = D3Motion.moderate,
    Curve curve = D3Motion.decelerate,
  }) =>
      _actions?.scrollToTop(duration: duration, curve: curve);

  /// Animate the scroll position to the bottom of the list.
  void scrollToBottom({
    Duration duration = D3Motion.moderate,
    Curve curve = D3Motion.decelerate,
  }) =>
      _actions?.scrollToBottom(duration: duration, curve: curve);

  /// Release resources. Call this in your widget's [State.dispose].
  void dispose() => _actions = null;
}

// Internal interface — keeps the controller decoupled from the state class.
abstract interface class _D3ListActions {
  void refresh();
  void loadMore();
  void scrollToIndex(
    int index, {
    required Duration duration,
    required Curve curve,
  });
  void scrollToTop({required Duration duration, required Curve curve});
  void scrollToBottom({required Duration duration, required Curve curve});
}

// ─────────────────────────────────────────────────────────────────────────────
// D3List
// ─────────────────────────────────────────────────────────────────────────────

/// A generic scrollable list built on [ListView.builder] with built-in support
/// for pull-to-refresh, infinite scroll, section headers, empty states, and
/// initial loading.
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
/// **With controller:**
/// ```dart
/// final _ctrl = D3ListController();
///
/// D3List<Contact>(
///   controller: _ctrl,
///   items: _contacts,
///   itemBuilder: (context, contact, index) => D3ListTile(title: contact.name),
///   onRefresh: _fetchContacts,
/// )
///
/// // Elsewhere:
/// _ctrl.refresh();
/// _ctrl.scrollToTop();
/// ```
///
/// **With sections:**
/// ```dart
/// D3List<Contact>(
///   items: _sortedContacts,
///   itemBuilder: (context, contact, index) => D3ListTile(title: contact.name),
///   sectionBuilder: (context, contact, index) =>
///       contact.name[0].toUpperCase(),
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
  });

  /// The data items to render.
  final List<T> items;

  /// Builder called for each item. Typically returns a [D3ListTile].
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// Optional controller for programmatic refresh, load-more, and scrolling.
  final D3ListController? controller;

  /// Called when the user pulls to refresh. Pass null to disable.
  final Future<void> Function()? onRefresh;

  /// Called when the user scrolls near the bottom. Pass null to disable
  /// infinite scroll.
  final Future<void> Function()? onLoadMore;

  /// Set to false once there are no more pages to load. Hides the bottom
  /// spinner and stops triggering [onLoadMore].
  final bool hasMore;

  /// When true and [items] is empty, shows a centred loading spinner instead
  /// of the empty state. Use for the initial page load.
  final bool isLoading;

  /// Widget shown when [items] is empty and [isLoading] is false.
  /// Defaults to a generic [D3EmptyState].
  final Widget? emptyState;

  /// When provided, called for each item to produce a section header string.
  /// A header row is inserted above the first item in each new section.
  /// Return null to skip the header for that item.
  final String? Function(BuildContext context, T item, int index)?
      sectionBuilder;

  /// Custom separator between items. Defaults to a hairline [Divider].
  final Widget Function(BuildContext context, int index)? separatorBuilder;

  /// Distance from the bottom (in pixels) at which [onLoadMore] fires.
  /// Defaults to 200.
  final double loadMoreThreshold;

  /// Padding around the list content.
  final EdgeInsetsGeometry? padding;

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
    // Trigger load-more if the initial items don't fill the viewport.
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkFillViewport());
  }

  @override
  void didUpdateWidget(D3List<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach();
      widget.controller?._attach(this);
    }
    // Re-check after items update (e.g. first page just arrived).
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

  // ── Scroll listener ────────────────────────────────────────────────────────

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    final nearBottom =
        pos.pixels >= pos.maxScrollExtent - widget.loadMoreThreshold;
    if (nearBottom && widget.hasMore && !_isLoadingMore) {
      _triggerLoadMore();
    }
  }

  /// Fires load-more when all items fit on screen without needing to scroll.
  void _checkFillViewport() {
    if (!mounted || !_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.maxScrollExtent == 0 && widget.hasMore && !_isLoadingMore) {
      _triggerLoadMore();
    }
  }

  // ── _D3ListActions ─────────────────────────────────────────────────────────

  @override
  void refresh() {
    if (widget.onRefresh == null) return;
    _refreshKey.currentState?.show();
  }

  @override
  void loadMore() {
    if (widget.onLoadMore == null || !widget.hasMore || _isLoadingMore) return;
    _triggerLoadMore();
  }

  @override
  void scrollToIndex(
    int index, {
    required Duration duration,
    required Curve curve,
  }) {
    if (!_scrollController.hasClients) return;
    // Estimate item height by computing the average extent. Falls back to a
    // fixed estimate when not enough items are rendered.
    final pos = _scrollController.position;
    final itemCount = widget.items.length;
    if (itemCount == 0) return;
    final estimated = pos.maxScrollExtent / itemCount;
    final target = (estimated * index).clamp(0.0, pos.maxScrollExtent);
    _scrollController.animateTo(target, duration: duration, curve: curve);
  }

  @override
  void scrollToTop({required Duration duration, required Curve curve}) {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(0, duration: duration, curve: curve);
  }

  @override
  void scrollToBottom({required Duration duration, required Curve curve}) {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: duration,
      curve: curve,
    );
  }

  // ── Internal helpers ───────────────────────────────────────────────────────

  Future<void> _triggerLoadMore() async {
    if (_isLoadingMore || widget.onLoadMore == null) return;
    setState(() => _isLoadingMore = true);
    try {
      await widget.onLoadMore!();
    } finally {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;

    // ── Initial loading state ────────────────────────────────────────────────
    if (widget.isLoading && widget.items.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: colors.primary,
        ),
      );
    }

    // ── Empty state ──────────────────────────────────────────────────────────
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

    // ── Build flat or sectioned child list ───────────────────────────────────
    final children = _buildChildren(context);

    // Append load-more footer only while actively fetching the next page.
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

      // Section header
      if (widget.sectionBuilder != null) {
        final section = widget.sectionBuilder!(context, item, i);
        if (section != null && section != lastSection) {
          children.add(_SectionHeader(label: section));
          lastSection = section;
        }
      }

      // Separator (skip before first item and after section headers)
      if (i > 0 && widget.sectionBuilder == null) {
        children.add(
          widget.separatorBuilder != null
              ? widget.separatorBuilder!(context, i)
              : const _DefaultSeparator(),
        );
      }

      children.add(widget.itemBuilder(context, item, i));
    }

    return children;
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
        D3Spacing.s16,
        D3Spacing.s10,
        D3Spacing.s16,
        D3Spacing.s4,
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
