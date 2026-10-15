import 'package:d3_ui/d3_ui.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../page_model.dart';
import '../registry.dart';
import 'search_index.dart';

/// From this width the search is a centred palette; narrower it is a screen.
const double _wideBreakpoint = 900;
const double _paletteMaxWidth = 600;
const double _rowMinHeight = 56;
const List<String> _popularIds = [
  'button',
  'text-field',
  'dialog',
  'toast',
  'slider',
  'dropdown-field',
];

/// Opens the showcase search and returns the id of the chosen page, or null
/// when it is closed without choosing.
///
/// A centred palette over a dimmed barrier on wide screens, a full-screen
/// route on narrow ones. [recentIds] (newest first) are listed while the
/// field is empty; without any, the popular pages are.
Future<String?> showShowcaseSearch(
  BuildContext context, {
  List<String> recentIds = const [],
}) {
  final wide = MediaQuery.sizeOf(context).width >= _wideBreakpoint;
  final reduced = MediaQuery.disableAnimationsOf(context);
  if (wide) {
    return showGeneralDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close search',
      barrierColor: Colors.black54,
      transitionDuration: reduced ? Duration.zero : D3Motion.base,
      pageBuilder: (context, _, __) =>
          _SearchPalette(wide: true, recentIds: recentIds),
      transitionBuilder: (context, animation, __, child) {
        if (reduced) return child;
        final curved = CurvedAnimation(
          parent: animation,
          curve: D3Motion.standard,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
  return Navigator.of(context, rootNavigator: true).push<String>(
    PageRouteBuilder<String>(
      transitionDuration: reduced ? Duration.zero : D3Motion.base,
      reverseTransitionDuration: reduced ? Duration.zero : D3Motion.base,
      pageBuilder: (context, _, __) =>
          _SearchPalette(wide: false, recentIds: recentIds),
      transitionsBuilder: (context, animation, __, child) =>
          reduced ? child : FadeTransition(opacity: animation, child: child),
    ),
  );
}

sealed class _Item {
  const _Item();
}

class _HeaderItem extends _Item {
  const _HeaderItem(this.label);
  final String label;
}

class _RowItem extends _Item {
  const _RowItem(this.page, this.matches);
  final ShowcasePage page;
  final List<TextRange> matches;
}

class _SearchPalette extends StatefulWidget {
  const _SearchPalette({required this.wide, required this.recentIds});

  final bool wide;
  final List<String> recentIds;

  @override
  State<_SearchPalette> createState() => _SearchPaletteState();
}

class _SearchPaletteState extends State<_SearchPalette> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _scroll = ScrollController();
  final _rowKeys = <String, GlobalKey>{};

  String _query = '';
  int _highlight = 0;
  bool _done = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scroll.dispose();
    super.dispose();
  }

  // ---- Content ----------------------------------------------------------

  List<ShowcasePage> get _pages => showcasePages;

  /// The pages for an empty query: recent ones, else popular ones.
  (String, List<ShowcasePage>) _suggestions() {
    final byId = {for (final p in _pages) p.id: p};
    final recent = <ShowcasePage>[
      for (final id in widget.recentIds)
        if (byId[id] != null) byId[id]!,
    ].take(6).toList();
    if (recent.isNotEmpty) return ('Recent', recent);
    var popular = <ShowcasePage>[
      for (final id in _popularIds)
        if (byId[id] != null) byId[id]!,
    ];
    if (popular.isEmpty) {
      popular =
          _pages.where((p) => p.group != ShowcaseGroup.start).take(6).toList();
    }
    return ('Popular', popular);
  }

  List<SearchResult> get _results => searchPages(_query, _pages);

  List<_Item> _items(List<SearchResult> results) {
    if (_query.trim().isEmpty) {
      final (label, pages) = _suggestions();
      return [
        _HeaderItem(label),
        for (final p in pages) _RowItem(p, const []),
      ];
    }
    // Grouped by the page's group, the group with the best match first.
    final groups = <ShowcaseGroup, List<SearchResult>>{};
    for (final r in results) {
      groups.putIfAbsent(r.page.group, () => []).add(r);
    }
    return [
      for (final entry in groups.entries) ...[
        _HeaderItem(entry.key.label),
        for (final r in entry.value) _RowItem(r.page, r.titleMatches),
      ],
    ];
  }

  // ---- Actions ----------------------------------------------------------

  void _close([String? id]) {
    if (_done) return;
    _done = true;
    Navigator.of(context).pop(id);
  }

  void _onChanged(String value) {
    setState(() {
      _query = value;
      _highlight = 0;
    });
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  List<_RowItem> _rowsOf(List<_Item> items) =>
      items.whereType<_RowItem>().toList();

  void _open() {
    final rows = _rowsOf(_items(_results));
    if (rows.isEmpty) return;
    _close(rows[_highlight.clamp(0, rows.length - 1)].page.id);
  }

  void _move(int delta) {
    final rows = _rowsOf(_items(_results));
    if (rows.isEmpty) return;
    final next = (_highlight + delta) % rows.length;
    setState(() => _highlight = next);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (next == 0) {
        if (_scroll.hasClients) _scroll.jumpTo(0);
        return;
      }
      final context = _rowKeys[rows[next].page.id]?.currentContext;
      if (context == null) return;
      Scrollable.ensureVisible(
        context,
        duration: Duration.zero,
        alignmentPolicy: delta > 0
            ? ScrollPositionAlignmentPolicy.keepVisibleAtEnd
            : ScrollPositionAlignmentPolicy.keepVisibleAtStart,
      );
    });
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowDown) {
      _move(1);
    } else if (key == LogicalKeyboardKey.arrowUp) {
      _move(-1);
    } else if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      _open();
    } else if (key == LogicalKeyboardKey.escape) {
      _close();
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  // ---- Build ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    final results = _results;
    final items = _items(results);
    final rows = _rowsOf(items);
    final highlight = rows.isEmpty ? 0 : _highlight.clamp(0, rows.length - 1);
    final searching = _query.trim().isNotEmpty;

    final announcement = !searching
        ? ''
        : results.isEmpty
            ? 'No results'
            : '${results.length} results';

    final field = D3SearchBar(
      controller: _controller,
      focusNode: _focusNode,
      autofocus: true,
      hint: 'Search components',
      onChanged: _onChanged,
      onSubmitted: (_) => _open(),
    );

    final Widget body;
    if (searching && results.isEmpty) {
      body = Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(D3Spacing.s24),
          child: D3EmptyState(
            compact: true,
            icon: Icons.search_off_rounded,
            title: 'No components match "${_query.trim()}"',
            message: 'Try a shorter word, or a name like toast or toggle',
          ),
        ),
      );
    } else {
      var rowIndex = 0;
      body = SingleChildScrollView(
        controller: _scroll,
        padding: const EdgeInsets.symmetric(vertical: D3Spacing.s8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final item in items)
              switch (item) {
                _HeaderItem() => _SectionLabel(item.label),
                _RowItem() => () {
                    final index = rowIndex++;
                    return _ResultRow(
                      key: _rowKeys.putIfAbsent(item.page.id, GlobalKey.new),
                      page: item.page,
                      matches: item.matches,
                      highlighted: index == highlight,
                      showGroup: widget.wide,
                      onHover: () {
                        if (_highlight != index) {
                          setState(() => _highlight = index);
                        }
                      },
                      onTap: () => _close(item.page.id),
                    );
                  }(),
              },
          ],
        ),
      );
    }

    final live = Semantics(
      liveRegion: true,
      label: announcement,
      child: const SizedBox(width: 1, height: 1),
    );

    final Widget content = widget.wide
        ? _wide(context, field, body, live)
        : _narrow(context, field, body, live);

    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: _onKey,
      child: Semantics(
        scopesRoute: true,
        namesRoute: true,
        label: 'Search components',
        explicitChildNodes: true,
        child: ColoredBox(
          color: widget.wide ? Colors.transparent : colors.surface,
          child: content,
        ),
      ),
    );
  }

  Widget _wide(BuildContext context, Widget field, Widget body, Widget live) {
    final colors = context.d3Colors;
    final size = MediaQuery.sizeOf(context);
    final top = size.height * 0.12;
    final maxHeight = (size.height - top - D3Spacing.s24).clamp(160.0, 520.0);
    return Stack(
      children: [
        // A tap outside the palette closes it.
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _close(),
            child: const SizedBox.expand(),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              D3Spacing.s16,
              top,
              D3Spacing.s16,
              D3Spacing.s24,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: _paletteMaxWidth,
                maxHeight: maxHeight,
              ),
              child: Material(
                color: colors.surfaceVariant,
                surfaceTintColor: Colors.transparent,
                elevation: 12,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: context.d3Shape.circularXl,
                  side: BorderSide(
                    color: colors.outline.withValues(alpha: 0.2),
                    width: 0.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: D3Spacing.s8,
                        vertical: D3Spacing.s4,
                      ),
                      child: field,
                    ),
                    Divider(
                        height: 1, thickness: 1, color: colors.outlineVariant),
                    Flexible(child: body),
                    live,
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _narrow(BuildContext context, Widget field, Widget body, Widget live) {
    final colors = context.d3Colors;
    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: 'Close search',
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => _close(),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: D3Spacing.s12),
                    child: field,
                  ),
                ),
              ],
            ),
            Divider(height: 1, thickness: 1, color: colors.outlineVariant),
            Expanded(child: body),
            live,
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          D3Spacing.s20,
          D3Spacing.s12,
          D3Spacing.s20,
          D3Spacing.s4,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
            color: context.d3Colors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    super.key,
    required this.page,
    required this.matches,
    required this.highlighted,
    required this.showGroup,
    required this.onHover,
    required this.onTap,
  });

  final ShowcasePage page;
  final List<TextRange> matches;
  final bool highlighted;
  final bool showGroup;
  final VoidCallback onHover;
  final VoidCallback onTap;

  TextSpan _title(D3ColorTokens colors) {
    final base = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w500,
      color: colors.onSurface,
    );
    final hit = base.copyWith(
      fontWeight: FontWeight.w800,
      color: colors.primary,
    );
    final title = page.title;
    final spans = <TextSpan>[];
    var at = 0;
    for (final r in matches) {
      if (r.start < at || r.end > title.length) continue;
      if (r.start > at) spans.add(TextSpan(text: title.substring(at, r.start)));
      spans.add(TextSpan(text: title.substring(r.start, r.end), style: hit));
      at = r.end;
    }
    if (at < title.length) spans.add(TextSpan(text: title.substring(at)));
    return TextSpan(style: base, children: spans);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    final shape = context.d3Shape;
    return Semantics(
      button: true,
      selected: highlighted,
      child: MouseRegion(
        onHover: (_) => onHover(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: D3Spacing.s8),
          child: Material(
            color: highlighted
                ? colors.primary.withValues(alpha: 0.10)
                : Colors.transparent,
            borderRadius: shape.circularMd,
            child: InkWell(
              borderRadius: shape.circularMd,
              onTap: onTap,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: _rowMinHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: D3Spacing.s12,
                    vertical: D3Spacing.s8,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colors.primaryContainer,
                          borderRadius: BorderRadius.circular(D3Radius.sm),
                        ),
                        alignment: Alignment.center,
                        child: Icon(page.icon, size: 20, color: colors.primary),
                      ),
                      const SizedBox(width: D3Spacing.s12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text.rich(_title(colors)),
                            const SizedBox(height: 2),
                            Text(
                              page.summary,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (showGroup) ...[
                        const SizedBox(width: D3Spacing.s12),
                        Text(
                          page.group.label,
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
