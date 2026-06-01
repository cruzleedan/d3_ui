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
/// Use the named constructor that matches where your data lives:
///
/// ---
///
/// **[D3SearchAnchor.local] — data already in memory**
///
/// The search page opens with all `items` visible immediately and filters
/// them synchronously as the user types. No network request, no spinner.
/// Ideal for contacts, settings, notes, or any pre-loaded dataset.
///
/// ```dart
/// D3SearchAnchor<Contact>.local(
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
/// )
/// ```
///
/// ---
///
/// **[D3SearchAnchor.remote] — data fetched from an API**
///
/// The search page opens with `initialItems` visible (same list the user
/// was already looking at — no blank screen). Typing debounces and calls
/// `onSearch`; the results replace the initial list until the query is
/// cleared. Ideal for large server-side datasets with pagination.
///
/// ```dart
/// D3SearchAnchor<Product>.remote(
///   initialItems: _products,
///   onSearch: (query) async => await _api.search(query),
///   resultBuilder: (context, results, query) => D3List<Product>(
///     items: results,
///     onLoadMore: _loadMore,
///     hasMore: _hasMore,
///     itemBuilder: (context, product, _) => D3ListTile(title: product.name),
///   ),
/// )
/// ```
class D3SearchAnchor<T> extends StatefulWidget {
  // ── .local ─────────────────────────────────────────────────────────────────

  /// Creates a search anchor backed by an already-loaded list.
  ///
  /// [items] is shown immediately on open and filtered synchronously via
  /// [filterItems] as the user types.
  // ignore: prefer_const_constructors_in_immutables
  D3SearchAnchor.local({
    super.key,
    required List<T> items,
    required List<T> Function(List<T> items, String query) filterItems,
    required Widget Function(
            BuildContext context, List<T> results, String query)
        resultBuilder,
    this.hint = 'Search…',
    this.emptyState,
    this.controller,
    this.padding,
  })  : _initialItems = items,
        _filterItems = filterItems,
        _onSearch = null,
        _debounce = Duration.zero,
        _resultBuilder = resultBuilder;

  // ── .remote ────────────────────────────────────────────────────────────────

  /// Creates a search anchor that fetches results from a remote source.
  ///
  /// [initialItems] is shown on open and after the user clears their query,
  /// keeping the screen populated at all times. Typing debounces and calls
  /// [onSearch]; results replace [initialItems] until the query is cleared.
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
  })  : _initialItems = initialItems,
        _filterItems = null,
        _onSearch = onSearch,
        _debounce = debounce,
        _resultBuilder = resultBuilder;

  // ── Shared fields ──────────────────────────────────────────────────────────

  final String hint;
  final Widget? emptyState;
  final D3SearchController? controller;

  /// Padding around the collapsed bar. Defaults to zero.
  final EdgeInsetsGeometry? padding;

  // Internal — not exposed on constructors
  final List<T> _initialItems;
  final List<T> Function(List<T>, String)? _filterItems;
  final Future<List<T>?> Function(String)? _onSearch;
  final Duration _debounce;
  final Widget Function(BuildContext, List<T>, String) _resultBuilder;

  bool get _isLocal => _filterItems != null;

  // ── Static highlight helper ────────────────────────────────────────────────

  /// Returns a [TextSpan] with occurrences of [query] bolded in [highlightColor].
  ///
  /// ```dart
  /// RichText(
  ///   text: D3SearchAnchor.highlight(
  ///     text: contact.name,
  ///     query: query,
  ///     highlightColor: context.d3Colors.primary,
  ///   ),
  /// )
  /// ```
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
  State<D3SearchAnchor<T>> createState() => _D3SearchAnchorState<T>();
}

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

class _D3SearchAnchorState<T> extends State<D3SearchAnchor<T>>
    implements _D3SearchAnchorActions {
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(this);
  }

  @override
  void didUpdateWidget(D3SearchAnchor<T> oldWidget) {
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
            child: _D3SearchPage<T>(
              hint: widget.hint,
              initialItems: widget._initialItems,
              filterItems: widget._filterItems,
              onSearch: widget._onSearch,
              isLocal: widget._isLocal,
              resultBuilder: widget._resultBuilder,
              emptyState: widget.emptyState,
              debounce: widget._debounce,
              initialQuery: initialQuery,
            ),
          ),
        )
        .whenComplete(() => _isOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding ?? EdgeInsets.zero,
      child: D3SearchBar(
        hint: widget.hint,
        readOnly: true,
        onTap: () => _push(),
      ),
    );
  }
}

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

class _D3SearchPage<T> extends StatefulWidget {
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
  });

  final String hint;
  final List<T> initialItems;
  final List<T> Function(List<T>, String)? filterItems;
  final Future<List<T>?> Function(String)? onSearch;
  final bool isLocal;
  final Widget Function(BuildContext, List<T>, String) resultBuilder;
  final Widget? emptyState;
  final Duration debounce;
  final String initialQuery;

  @override
  State<_D3SearchPage<T>> createState() => _D3SearchPageState<T>();
}

class _D3SearchPageState<T> extends State<_D3SearchPage<T>> {
  late final TextEditingController _textController;
  final _focusNode = FocusNode();

  late List<T> _results;
  bool _isSearching = false;
  String _query = '';
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialQuery);
    _query = widget.initialQuery;
    // Both modes start with initialItems — no blank screen in either case.
    _results = List<T>.from(widget.initialItems);
    _textController.addListener(_onTextChanged);

    if (widget.initialQuery.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _applyQuery(widget.initialQuery),
      );
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

  // ── Text changes ───────────────────────────────────────────────────────────

  void _onTextChanged() {
    final q = _textController.text.trim();
    if (q == _query) return;
    _query = q;
    _debounceTimer?.cancel();
    _applyQuery(q);
  }

  void _applyQuery(String query) {
    if (query.isEmpty) {
      // Both modes: restore initial list when cleared
      setState(() {
        _results = List<T>.from(widget.initialItems);
        _isSearching = false;
      });
      return;
    }

    if (widget.isLocal) {
      // Local: synchronous filter
      setState(() {
        _results = widget.filterItems!(widget.initialItems, query);
      });
    } else {
      // Remote: debounced async fetch
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

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
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

            const Divider(height: 0, thickness: 0.5),

            // Content
            Expanded(child: _buildContent(colors)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(D3ColorTokens colors) {
    // Remote: show spinner while fetching
    if (!widget.isLocal && _isSearching) {
      return Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: colors.primary,
        ),
      );
    }

    // Empty results (after filtering or remote fetch)
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
