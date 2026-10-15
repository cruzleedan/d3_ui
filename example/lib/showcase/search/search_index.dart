import 'dart:ui' show TextRange;

import '../page_model.dart';

/// Words people search by that are not in a page's title: what other design
/// systems and platforms call the same thing. Keyed by page id; every page of
/// the registry has an entry (a test checks it).
const Map<String, List<String>> _keywords = {
  'overview': ['home', 'start', 'intro', 'introduction', 'about', 'welcome'],
  'components': [
    'all components',
    'catalog',
    'catalogue',
    'index',
    'widgets',
    'library',
    'browse',
  ],
  'theme': [
    'colours',
    'colors',
    'tokens',
    'brand',
    'dark mode',
    'light mode',
    'design tokens',
    'typography',
    'radius',
    'spacing',
  ],
  'button': ['cta', 'action', 'filled', 'outlined', 'text button', 'submit'],
  'split-button': ['dropdown button', 'button menu', 'menu button', 'actions'],
  'expanding-fab': [
    'fab',
    'floating action button',
    'speed dial',
    'floating button',
    'extended fab',
  ],
  'scrim-button': [
    'icon button',
    'overlay button',
    'photo button',
    'round button',
    'close button',
  ],
  'avatar': ['profile picture', 'user', 'profile', 'initials', 'photo'],
  'chip': ['tag', 'pill', 'filter', 'label', 'token'],
  'image': ['picture', 'photo', 'network image', 'placeholder', 'thumbnail'],
  'poster-card': ['movie', 'cover', 'poster', 'artwork', 'media card', 'book'],
  'photos': ['gallery', 'grid', 'pictures', 'images', 'viewer', 'carousel'],
  'list': ['rows', 'items', 'listview', 'list view'],
  'section-header': ['heading', 'title', 'divider', 'group header', 'label'],
  'expandable-section': [
    'accordion',
    'collapse',
    'expand',
    'collapsible',
    'disclosure',
    'expansion panel',
  ],
  'skeleton': ['placeholder', 'shimmer', 'loading', 'loader', 'ghost'],
  'empty-state': ['no results', 'blank', 'nothing here', 'empty', 'zero state'],
  'toast': [
    'snackbar',
    'snack bar',
    'notification',
    'message',
    'alert',
    'undo',
  ],
  'text-field': [
    'input',
    'textbox',
    'text box',
    'form field',
    'text input',
    'entry',
    'password',
  ],
  'date-field': ['date picker', 'calendar', 'birthday', 'day', 'datepicker'],
  'decimal-field': [
    'number',
    'numeric',
    'money',
    'currency',
    'amount',
    'price',
    'number input',
  ],
  'dropdown-field': [
    'select',
    'picker',
    'combobox',
    'combo box',
    'dropdown',
    'options',
    'autocomplete',
  ],
  'search': ['search bar', 'find', 'lookup', 'filter', 'query', 'search box'],
  'schema-form': [
    'form',
    'json',
    'generated form',
    'dynamic form',
    'fields',
    'validation',
  ],
  'checkbox': ['tick', 'check', 'checked', 'select many', 'multi select'],
  'radio': ['option', 'radio button', 'choice', 'single choice', 'group'],
  'toggle': ['switch', 'on off', 'on/off', 'enable', 'setting'],
  'segmented-control': [
    'segmented button',
    'tabs',
    'switcher',
    'button group',
    'pill switch',
  ],
  'filter-chip-row': ['chips', 'filters', 'tags', 'categories', 'scroll chips'],
  'screen': ['page', 'scaffold', 'layout', 'app bar', 'appbar', 'view'],
  'list-screen': ['list page', 'scrolling list', 'feed', 'infinite scroll'],
  'scroll-over-sheet': [
    'parallax',
    'sheet over image',
    'hero',
    'collapsing header',
    'detail page',
  ],
  'nav-bar': [
    'bottom navigation',
    'tabs bar',
    'bottom bar',
    'navigation bar',
    'bottom nav',
  ],
  'nav-rail': [
    'side navigation',
    'sidebar',
    'rail',
    'navigation rail',
    'side bar',
    'side nav',
  ],
  'tab-bar': ['tabs', 'tab', 'tabbar', 'top tabs', 'tab view'],
  'sticky-header': [
    'pinned header',
    'sticky',
    'section header',
    'floating header',
  ],
  'bottom-sheet': [
    'modal sheet',
    'drawer',
    'sheet',
    'slide up',
    'half sheet',
    'popup',
  ],
  'form-sheet': ['edit sheet', 'sheet form', 'modal form', 'drawer form'],
  'dialog': [
    'modal',
    'alert',
    'popup',
    'confirm',
    'confirmation',
    'prompt',
    'alert dialog',
  ],
  'calendar-picker': [
    'date picker',
    'calendar',
    'date range',
    'month',
    'schedule',
    'pick a date',
  ],
  'card': ['container', 'panel', 'tile', 'surface', 'box'],
  'info-card': ['stat', 'callout', 'summary card', 'information', 'highlight'],
  'list-tile': ['row', 'list item', 'item', 'cell', 'listtile'],
  'slidable-row': [
    'swipe',
    'swipe to delete',
    'swipe actions',
    'dismissible',
    'slide actions',
  ],
  'thumbnail-card': ['image card', 'preview', 'media card', 'thumb', 'picture'],
  'ticket-card': [
    'coupon',
    'voucher',
    'ticket',
    'perforated',
    'deal',
    'discount',
  ],
  'patterns': ['app', 'example', 'demo', 'sample', 'full app', 'screens'],
  'banner': [
    'alert',
    'inline message',
    'callout',
    'notice',
    'info bar',
    'warning',
  ],
  'progress': [
    'spinner',
    'loading',
    'loader',
    'bar',
    'ring',
    'progress bar',
    'circular',
    'activity',
  ],
  'badge': ['count', 'notification dot', 'dot', 'indicator', 'unread', 'tag'],
  'slider': ['range', 'seek', 'scrubber', 'volume', 'range slider'],
  'quantity-stepper': [
    'stepper',
    'plus minus',
    'counter',
    'increment',
    'number input',
    'amount',
  ],
  'action-sheet': [
    'context actions',
    'share sheet',
    'actions',
    'options sheet',
    'ios sheet',
    'menu sheet',
  ],
  'rating': ['stars', 'review', 'star rating', 'score', 'feedback', 'likes'],
  'otp-field': [
    'pin',
    'verification code',
    'one time password',
    'code',
    'otp',
    'passcode',
    'sms code',
  ],
  'time-field': [
    'time picker',
    'clock',
    'hour',
    'minute',
    'timepicker',
    'time'
  ],
  'menu': [
    'popup menu',
    'overflow',
    'context menu',
    'dropdown menu',
    'more',
    'kebab',
    'actions menu',
  ],
  'tooltip': ['hint', 'hover', 'popover', 'info', 'help', 'long press'],
};

/// The extra words a page can be found by (empty for an unknown id).
List<String> keywordsFor(String pageId) => _keywords[pageId] ?? const [];

/// Every page id that has keywords; used by the tests.
Iterable<String> get keywordPageIds => _keywords.keys;

/// A page with the words it can be found by.
class SearchEntry {
  SearchEntry(this.page, [List<String>? keywords])
      : keywords = keywords ?? keywordsFor(page.id);

  final ShowcasePage page;
  final List<String> keywords;
}

/// One match: the page, how good the match is, and what to highlight.
class SearchResult {
  const SearchResult({
    required this.page,
    required this.score,
    required this.titleMatches,
    this.matchedKeyword,
  });

  final ShowcasePage page;

  /// Higher is better. Tier 1 (exact title) is 800, tier 8 (fuzzy) is 100.
  final double score;

  /// Ranges of the title to highlight.
  final List<TextRange> titleMatches;

  /// The keyword that matched, when the page was found by one.
  final String? matchedKeyword;
}

String _normalize(String s) =>
    s.toLowerCase().replaceAll(RegExp(r'[\s\-_]+'), '');

/// A normalised string with, for each of its characters, the index it came
/// from in the original.
class _Norm {
  _Norm(String original) {
    final buffer = StringBuffer();
    final lower = original.toLowerCase();
    for (var i = 0; i < lower.length; i++) {
      final c = lower[i];
      if (RegExp(r'[\s\-_]').hasMatch(c)) continue;
      buffer.write(c);
      origin.add(i);
    }
    text = buffer.toString();
  }

  late final String text;
  final List<int> origin = [];

  /// Where a word of the original starts, as an index into [text].
  late final List<int> wordStarts = _wordStarts();

  List<int> _wordStarts() {
    final starts = <int>[];
    for (var i = 0; i < text.length; i++) {
      if (i == 0 || origin[i] - origin[i - 1] > 1) starts.add(i);
    }
    return starts;
  }

  /// The original range for the normalised range [start, end).
  TextRange range(int start, int end) =>
      TextRange(start: origin[start], end: origin[end - 1] + 1);
}

class _Hit {
  const _Hit(this.tier, this.matches, [this.keyword]);

  final int tier;
  final List<TextRange> matches;
  final String? keyword;
}

/// How [term] (already normalised, no separators) matches the entry; null if
/// it does not.
_Hit? _matchTerm(String term, SearchEntry entry, _Norm title) {
  final t = title.text;
  if (t == term) return _Hit(1, [title.range(0, t.length)]);
  if (t.startsWith(term)) return _Hit(2, [title.range(0, term.length)]);
  for (final start in title.wordStarts) {
    if (t.startsWith(term, start)) {
      return _Hit(3, [title.range(start, start + term.length)]);
    }
  }
  final at = t.indexOf(term);
  if (at >= 0) return _Hit(4, [title.range(at, at + term.length)]);

  String? contains;
  for (final keyword in entry.keywords) {
    final k = _normalize(keyword);
    if (k == term || k.startsWith(term)) return _Hit(5, const [], keyword);
    if (contains == null && k.contains(term)) contains = keyword;
  }
  if (contains != null) return _Hit(6, const [], contains);

  if (entry.page.summary.toLowerCase().contains(term)) {
    return const _Hit(7, []);
  }

  if (term.length >= 3) {
    final chars = <int>[];
    var from = 0;
    for (final unit in term.codeUnits) {
      final i = t.indexOf(String.fromCharCode(unit), from);
      if (i < 0) return null;
      chars.add(i);
      from = i + 1;
    }
    return _Hit(
        8, _mergeRanges([for (final i in chars) title.range(i, i + 1)]));
  }
  return null;
}

List<TextRange> _mergeRanges(List<TextRange> ranges) {
  if (ranges.isEmpty) return const [];
  final sorted = [...ranges]..sort((a, b) => a.start.compareTo(b.start));
  final merged = <TextRange>[sorted.first];
  for (final r in sorted.skip(1)) {
    final last = merged.last;
    if (r.start <= last.end) {
      merged[merged.length - 1] = TextRange(
        start: last.start,
        end: r.end > last.end ? r.end : last.end,
      );
    } else {
      merged.add(r);
    }
  }
  return merged;
}

_Hit? _matchWords(List<String> words, SearchEntry entry, _Norm title) {
  var worst = 0;
  final matches = <TextRange>[];
  String? keyword;
  for (final word in words) {
    final hit = _matchTerm(word, entry, title);
    if (hit == null) return null;
    if (hit.tier > worst) worst = hit.tier;
    matches.addAll(hit.matches);
    keyword ??= hit.keyword;
  }
  return _Hit(worst, _mergeRanges(matches), keyword);
}

/// The pages matching [query], best first (ties alphabetical by title).
///
/// Case, spaces, hyphens and underscores do not matter. With several words
/// every word must match somewhere (title, keywords or summary) and the match
/// is as good as its worst word. [keywords] defaults to [keywordsFor].
List<SearchResult> searchPages(
  String query,
  List<ShowcasePage> pages, {
  int limit = 30,
  List<String> Function(String pageId)? keywords,
}) {
  final words = [
    for (final w in query.trim().split(RegExp(r'\s+')))
      if (_normalize(w).isNotEmpty) _normalize(w),
  ];
  if (words.isEmpty) return const [];
  final joined = words.join();

  final results = <SearchResult>[];
  for (final page in pages) {
    final entry = SearchEntry(page, (keywords ?? keywordsFor)(page.id));
    final title = _Norm(page.title);
    var hit = _matchWords(words, entry, title);
    if (words.length > 1) {
      // 'bottom sheet' is also the one word 'bottomsheet'.
      final whole = _matchTerm(joined, entry, title);
      if (whole != null && (hit == null || whole.tier <= hit.tier)) hit = whole;
    }
    if (hit == null) continue;
    results.add(
      SearchResult(
        page: page,
        score: (9 - hit.tier) * 100.0,
        titleMatches: hit.matches,
        matchedKeyword: hit.keyword,
      ),
    );
  }
  results.sort((a, b) {
    final byScore = b.score.compareTo(a.score);
    if (byScore != 0) return byScore;
    return a.page.title.toLowerCase().compareTo(b.page.title.toLowerCase());
  });
  return results.length > limit ? results.sublist(0, limit) : results;
}
