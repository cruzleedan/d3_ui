import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:d3_ui/d3_ui.dart';

// ─────────────────────────────────────────────────────────────────────────────
// D3SearchController
// ─────────────────────────────────────────────────────────────────────────────

/// Programmatic controller for [D3SearchAnchor].
///
/// ```dart
/// final _ctrl = D3SearchController();
///
/// _ctrl.open();            // push the search page
/// _ctrl.close();           // pop the search page
/// _ctrl.search('dan');     // push and pre-fill a query
/// ```
class D3SearchController {
  _D3SearchAnchorActions? _actions;

  void _attach(_D3SearchAnchorActions actions) {
    assert(_actions == null, 'D3SearchController is already attached.');
    _actions = actions;
  }

  void _detach() => _actions = null;

  void open() => _actions?.open();
  void close() => _actions?.close();
  void search(String query) => _actions?.search(query);
  void dispose() => _actions = null;
}

abstract interface class _D3SearchAnchorActions {
  void open();
  void close();
  void search(String query);
}

// ─────────────────────────────────────────────────────────────────────────────
// D3SearchAnchor
// ─────────────────────────────────────────────────────────────────────────────

/// A read-only search bar that pushes a full-screen search page on tap.
///
/// Optionally embeds a [D3FilterChipRow] inside the search page, and shows
/// an active-filter badge on the collapsed bar when filters are applied.
///
/// Use the named constructor that matches where your data lives:
///
/// ---
///
/// **[D3SearchAnchor.local] — data already in memory**
///
/// ```dart
/// D3SearchAnchor<Contact, String>.local(
///   items: _contacts,
///   filterItems: (items, query) => items
///       .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
///       .toList(),
///   resultBuilder: (context, results, query) => D3List<Contact>(
///     items: results,
///     itemBuilder: (context, contact, _) => D3ListTile(
///       titleWidget: RichText(
///         text: D3SearchAnchor.highlight(
///           text: contact.name,
///           query: query,
///           highlightColor: context.d3Colors.primary,
///         ),
///       ),
///       subtitle: contact.email,
///       onTap: () => _open(contact),
///     ),
///   ),
///   filterOptions: const [
///     D3FilterOption(value: 'all',    label: 'All'),
///     D3FilterOption(value: 'recent', label: 'Recent'),
///   ],
///   activeFilters: _activeFilters,
///   onFiltersChanged: (filters) => setState(() => _activeFilters = filters),
/// )
/// ```
///
/// **[D3SearchAnchor.remote] — data fetched from an API**
///
/// ```dart
/// D3SearchAnchor<Product, String>.remote(
///   initialItems: _products,
///   onSearch: (query) async => await _api.search(query),
///   resultBuilder: (context, results, query) => D3List<Product>(
///     items: results,
///     itemBuilder: (context, product, _) => D3ListTile(title: product.name),
///   ),
/// )
/// ```
class D3SearchAnchor<T, F> extends StatefulWidget {
  // ── .local ─────────────────────────────────────────────────────────────────

  // ignore: prefer_const_constructors_in_immutables
  D3SearchAnchor.local({
    super.key,
    required List<T> items,
    required List<T> Function(List<T> items, String query, Set<F> activeFilters)
        filterItems,
    required Widget Function(
            BuildContext context, List<T> results, String query)
        resultBuilder,
    this.hint = 'Search…',
    this.emptyState,
    this.controller,
    this.padding,
    this.filterOptions = const [],
    this.activeFilters = const {},
    this.defaultFilters,
    this.onFiltersChanged,
    this.multiSelectFilters = false,
  })  : _initialItems = items,
        _filterItems = filterItems,
        _onSearch = null,
        _debounce = Duration.zero,
        _resultBuilder = resultBuilder;

  // ── .remote ────────────────────────────────────────────────────────────────

  // ignore: prefer_const_constructors_in_immutables
  D3SearchAnchor.remote({
    super.key,
    required List<T> initialItems,
    required Future<List<T>?> Function(String query) onSearch,
    required Widget Function(
            BuildContext context, List<T> results, String query)
        resultBuilder,
    this.hint = 'Search…',
    this.emptyState,
    this.controller,
    this.padding,
    Duration debounce = const Duration(milliseconds: 300),
    this.filterOptions = const [],
    this.activeFilters = const {},
    this.defaultFilters,
    this.onFiltersChanged,
    this.multiSelectFilters = false,
  })  : _initialItems = initialItems,
        _filterItems = null,
        _onSearch = onSearch,
        _debounce = debounce,
        _resultBuilder = resultBuilder;

  // ── Shared fields ──────────────────────────────────────────────────────────

  final String hint;
  final Widget? emptyState;
  final D3SearchController? controller;
  final EdgeInsetsGeometry? padding;

  /// Filter chip options shown below the search bar inside the search page.
  /// Pass an empty list (default) to disable filters.
  final List<D3FilterOption<F>> filterOptions;

  /// Currently active filter values.
  final Set<F> activeFilters;

  /// The default / "no filter applied" state. When [activeFilters] differs
  /// from this, the collapsed bar shows a tinted filter icon indicating that
  /// a non-default filter is active. Pass null to never show the indicator.
  final Set<F>? defaultFilters;

  /// Called when the user changes filter selection inside the search page.
  final ValueChanged<Set<F>>? onFiltersChanged;

  /// When true, multiple filter chips can be active at once.
  final bool multiSelectFilters;

  // Internal
  final List<T> _initialItems;
  final List<T> Function(List<T>, String, Set<F>)? _filterItems;
  final Future<List<T>?> Function(String)? _onSearch;
  final Duration _debounce;
  final Widget Function(BuildContext, List<T>, String) _resultBuilder;

  bool get _isLocal => _filterItems != null;
  bool get _hasFilters => filterOptions.isNotEmpty;

  // ── Static highlight helper ────────────────────────────────────────────────

  /// Returns a [TextSpan] with occurrences of [query] bolded in [highlightColor].
  static TextSpan highlight({
    required String text,
    required String query,
    TextStyle? style,
    TextStyle? highlightStyle,
    Color? highlightColor,
  }) {
    if (query.isEmpty) return TextSpan(text: text, style: style);

    final spans = <TextSpan>[];
    final lower = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    int start = 0;

    while (true) {
      final idx = lower.indexOf(lowerQuery, start);
      if (idx == -1) {
        spans.add(TextSpan(text: text.substring(start), style: style));
        break;
      }
      if (idx > start) {
        spans.add(TextSpan(text: text.substring(start, idx), style: style));
      }
      spans.add(TextSpan(
        text: text.substring(idx, idx + query.length),
        style: highlightStyle ??
            (style ?? const TextStyle()).copyWith(
              fontWeight: FontWeight.w600,
              color: highlightColor,
            ),
      ));
      start = idx + query.length;
    }

    return TextSpan(children: spans);
  }

  @override
  State<D3SearchAnchor<T, F>> createState() => _D3SearchAnchorState<T, F>();
}

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

class _D3SearchAnchorState<T, F> extends State<D3SearchAnchor<T, F>>
    implements _D3SearchAnchorActions {
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(this);
  }

  @override
  void didUpdateWidget(D3SearchAnchor<T, F> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach();
      widget.controller?._attach(this);
    }
  }

  @override
  void dispose() {
    widget.controller?._detach();
    super.dispose();
  }

  @override
  void open() => _push(initialQuery: '');

  @override
  void close() {
    if (_isOpen) Navigator.of(context).pop();
  }

  @override
  void search(String query) => _push(initialQuery: query);

  void _push({String initialQuery = ''}) {
    if (_isOpen || !mounted) return;
    _isOpen = true;
    HapticFeedback.selectionClick();

    Navigator.of(context)
        .push<void>(
          _SearchPageRoute(
            child: _D3SearchPage<T, F>(
              hint: widget.hint,
              initialItems: widget._initialItems,
              filterItems: widget._filterItems,
              onSearch: widget._onSearch,
              isLocal: widget._isLocal,
              resultBuilder: widget._resultBuilder,
              emptyState: widget.emptyState,
              debounce: widget._debounce,
              initialQuery: initialQuery,
              filterOptions: widget.filterOptions,
              activeFilters: widget.activeFilters,
              onFiltersChanged: widget.onFiltersChanged,
              multiSelectFilters: widget.multiSelectFilters,
            ),
          ),
        )
        .whenComplete(() => _isOpen = false);
  }

  // Non-default filter is active when activeFilters differs from defaultFilters.
  bool get _filterActive {
    if (!widget._hasFilters) return false;
    final def = widget.defaultFilters;
    if (def == null) return false;
    if (widget.activeFilters.length != def.length) return true;
    return !widget.activeFilters.every(def.contains);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    final filterActive = _filterActive;

    return Padding(
      padding: widget.padding ?? EdgeInsets.zero,
      child: D3SearchBar(
        hint: widget.hint,
        readOnly: true,
        onTap: () => _push(),
        // Shows a tinted filter icon inside the bar trailing slot when a
        // non-default filter is active — unambiguous without a number badge.
        trailingWidget: filterActive
            ? Padding(
                padding: const EdgeInsets.only(right: D3Spacing.s10),
                child: Icon(
                  Icons.filter_list_rounded,
                  size: 18,
                  color: colors.primary,
                ),
              )
            : null,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter badge
// ─────────────────────────────────────────────────────────────────────────────
// Page route
// ─────────────────────────────────────────────────────────────────────────────

class _SearchPageRoute extends PageRouteBuilder<void> {
  _SearchPageRoute({required Widget child})
      : super(
          pageBuilder: (_, __, ___) => child,
          transitionDuration: D3Motion.base,
          reverseTransitionDuration: D3Motion.fast,
          transitionsBuilder: (_, animation, __, child) {
            final curve =
                CurvedAnimation(parent: animation, curve: D3Motion.enter);
            return FadeTransition(
              opacity: curve,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.04),
                  end: Offset.zero,
                ).animate(curve),
                child: child,
              ),
            );
          },
        );
}

// ─────────────────────────────────────────────────────────────────────────────
// _D3SearchPage
// ─────────────────────────────────────────────────────────────────────────────

class _D3SearchPage<T, F> extends StatefulWidget {
  const _D3SearchPage({
    required this.hint,
    required this.initialItems,
    required this.filterItems,
    required this.onSearch,
    required this.isLocal,
    required this.resultBuilder,
    required this.emptyState,
    required this.debounce,
    required this.initialQuery,
    required this.filterOptions,
    required this.activeFilters,
    required this.onFiltersChanged,
    required this.multiSelectFilters,
  });

  final String hint;
  final List<T> initialItems;
  final List<T> Function(List<T>, String, Set<F>)? filterItems;
  final Future<List<T>?> Function(String)? onSearch;
  final bool isLocal;
  final Widget Function(BuildContext, List<T>, String) resultBuilder;
  final Widget? emptyState;
  final Duration debounce;
  final String initialQuery;
  final List<D3FilterOption<F>> filterOptions;
  final Set<F> activeFilters;
  final ValueChanged<Set<F>>? onFiltersChanged;
  final bool multiSelectFilters;

  bool get hasFilters => filterOptions.isNotEmpty;

  @override
  State<_D3SearchPage<T, F>> createState() => _D3SearchPageState<T, F>();
}

class _D3SearchPageState<T, F> extends State<_D3SearchPage<T, F>> {
  late final TextEditingController _textController;
  final _focusNode = FocusNode();

  late List<T> _results;
  bool _isSearching = false;
  String _query = '';
  Timer? _debounceTimer;

  // Local copy of active filters so chip taps are immediately reactive
  // without waiting for the parent to rebuild through the route stack.
  late Set<F> _activeFilters;

  @override
  void initState() {
    super.initState();
    _activeFilters = Set<F>.from(widget.activeFilters);
    _textController = TextEditingController(text: widget.initialQuery);
    _query = widget.initialQuery;
    _results = List<T>.from(widget.initialItems);
    _textController.addListener(_onTextChanged);

    if (widget.initialQuery.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (widget.isLocal) {
          _debounceTimer = Timer(
            const Duration(milliseconds: 150),
            () => _applyQuery(widget.initialQuery),
          );
        } else {
          _applyQuery(widget.initialQuery);
        }
      });
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final q = _textController.text.trim();
    if (q == _query) return;
    _query = q;
    _debounceTimer?.cancel();
    if (widget.isLocal) {
      _debounceTimer = Timer(
        const Duration(milliseconds: 150),
        () => _applyQuery(q),
      );
    } else {
      _applyQuery(q);
    }
  }

  void _applyQuery(String query) {
    if (widget.isLocal) {
      setState(() {
        _results = widget.filterItems!(
          widget.initialItems,
          query,
          _activeFilters,
        );
        _isSearching = false;
      });
    } else {
      if (query.isEmpty) {
        setState(() {
          _results = List<T>.from(widget.initialItems);
          _isSearching = false;
        });
        return;
      }
      setState(() => _isSearching = true);
      _debounceTimer = Timer(widget.debounce, () => _remoteSearch(query));
    }
  }

  Future<void> _remoteSearch(String query) async {
    if (!mounted) return;
    final results = await widget.onSearch!(query);
    if (!mounted) return;
    setState(() {
      if (results != null) _results = results;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ── Search bar row ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
              child: Row(
                children: [
                  Semantics(
                    button: true,
                    label: 'Back',
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.of(context).pop(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          size: 22,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: D3SearchBar(
                      controller: _textController,
                      focusNode: _focusNode,
                      hint: widget.hint,
                      autofocus: true,
                      onSubmitted: (_) {
                        if (!widget.isLocal) _remoteSearch(_query);
                      },
                    ),
                  ),
                ],
              ),
            ),

            // ── Filter chips (optional) ─────────────────────────────────
            if (widget.hasFilters) ...[
              D3FilterChipRow<F>(
                options: widget.filterOptions,
                selected: _activeFilters,
                onChanged: (next) {
                  _activeFilters = next;
                  widget.onFiltersChanged?.call(next);
                  _applyQuery(_query);
                },
                multiSelect: widget.multiSelectFilters,
                padding: const EdgeInsets.fromLTRB(
                  D3Spacing.s16, 0, D3Spacing.s16, D3Spacing.s10,
                ),
              ),
            ],

            const Divider(height: 0, thickness: 0.5),

            // ── Results ─────────────────────────────────────────────────
            Expanded(child: _buildContent(colors)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(D3ColorTokens colors) {
    if (!widget.isLocal && _isSearching) {
      return Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: colors.primary,
        ),
      );
    }

    if (_results.isEmpty) {
      return Center(
        child: widget.emptyState ??
            D3EmptyState(
              icon: Icons.search_off_rounded,
              title: _query.isEmpty
                  ? 'Nothing here yet'
                  : 'No results for "$_query"',
              message: _query.isEmpty
                  ? 'Items will appear here once added.'
                  : 'Try a different search term.',
            ),
      );
    }

    return widget.resultBuilder(context, _results, _query);
  }
}
