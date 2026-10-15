import 'package:d3_ui_example/showcase/page_model.dart';
import 'package:d3_ui_example/showcase/registry.dart';
import 'package:d3_ui_example/showcase/search/search_index.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

ShowcasePage page(
  String id,
  String title, {
  String summary = 'Thing.',
  ShowcaseGroup group = ShowcaseGroup.display,
}) =>
    ShowcasePage(
      id: id,
      title: title,
      group: group,
      icon: Icons.circle,
      summary: summary,
      builder: (_) => const SizedBox(),
    );

List<String> ids(List<SearchResult> results) => [
      for (final r in results) r.page.id,
    ];

void main() {
  group('ranking tiers', () {
    final pages = [
      page('total', 'Total assets'), // 8 fuzzy
      page('sum', 'Summary', summary: 'Shows a toast now.'), // 7 summary
      page('msg', 'Message'), // 6 keyword contains
      page('alert', 'Alert'), // 5 keyword prefix
      page('mine', 'Mytoast'), // 4 contains
      page('hot', 'Hot toast'), // 3 word start
      page('toaster', 'Toaster'), // 2 prefix
      page('toast', 'Toast'), // 1 exact
    ];
    List<String> kw(String id) => switch (id) {
          'alert' => ['toast notification'],
          'msg' => ['hot toast'],
          _ => const [],
        };

    test('every tier, best first', () {
      final results = searchPages('toast', pages, keywords: kw);
      expect(ids(results), [
        'toast',
        'toaster',
        'hot',
        'mine',
        'alert',
        'msg',
        'sum',
        'total',
      ]);
      final scores = [for (final r in results) r.score];
      expect(scores, [...scores]..sort((a, b) => b.compareTo(a)));
      expect(scores.toSet().length, 8);
    });

    test('a keyword match reports the keyword', () {
      final results = searchPages('toast', pages, keywords: kw);
      expect(
        results.firstWhere((r) => r.page.id == 'alert').matchedKeyword,
        'toast notification',
      );
      expect(results.first.matchedKeyword, isNull);
    });

    test('case does not matter', () {
      expect(ids(searchPages('TOAST', pages, keywords: kw)).first, 'toast');
    });
  });

  group('title matches', () {
    final pages = [
      page('sheet', 'Bottom sheet'),
      page('toggle', 'Toggle'),
    ];

    test('substring and prefix', () {
      expect(
        searchPages('sheet', pages).single.titleMatches,
        [const TextRange(start: 7, end: 12)],
      );
      expect(
        searchPages('bot', pages).single.titleMatches,
        [const TextRange(start: 0, end: 3)],
      );
    });

    test('separators in the query and the title are ignored', () {
      for (final q in [
        'bottomsheet',
        'bottom-sheet',
        'bottom_sheet',
        ' BOTTOM Sheet '
      ]) {
        final results = searchPages(q, pages);
        expect(ids(results), ['sheet'], reason: q);
        expect(results.single.score, 800, reason: q);
        expect(
          results.single.titleMatches,
          [const TextRange(start: 0, end: 12)],
          reason: q,
        );
      }
    });

    test('fuzzy matches highlight the characters', () {
      final result = searchPages('tggle', pages).single;
      expect(result.page.id, 'toggle');
      expect(result.titleMatches, [
        const TextRange(start: 0, end: 1),
        const TextRange(start: 2, end: 6),
      ]);
    });
  });

  group('multi-word', () {
    final pages = [
      page('text', 'Text field'),
      page('sheet', 'Bottom sheet'),
      page('toast', 'Toast'),
    ];

    test('every word must match', () {
      expect(ids(searchPages('text field', pages)), ['text']);
      expect(ids(searchPages('field text', pages)), ['text']);
      expect(searchPages('toast zzz', pages), isEmpty);
    });

    test('the tier is the worst word, titleMatches are merged', () {
      final result = searchPages('field te', pages).single;
      // "field" is a word start (3), "te" a prefix (2): the worst is 3.
      expect(result.score, 600);
      expect(result.titleMatches, [
        const TextRange(start: 0, end: 2),
        const TextRange(start: 5, end: 10),
      ]);
    });

    test('words may match the title, keywords or summary', () {
      final result = searchPages(
        'sheet drawer',
        pages,
        keywords: (id) => id == 'sheet' ? ['drawer'] : const [],
      ).single;
      expect(result.page.id, 'sheet');
      expect(result.score, 400);

      final bySummary = searchPages('toast brief', [
        page('toast', 'Toast', summary: 'A brief message.'),
      ]);
      expect(bySummary.single.score, 200);
    });
  });

  group('fuzzy', () {
    final pages = [page('toggle', 'Toggle')];

    test('needs at least 3 characters', () {
      expect(searchPages('tg', pages), isEmpty);
      expect(ids(searchPages('tgl', pages)), ['toggle']);
      expect(searchPages('tgl', pages).single.score, 100);
    });

    test('characters must be in order', () {
      expect(searchPages('lgt', pages), isEmpty);
    });
  });

  group('result list', () {
    test('an empty query returns nothing', () {
      final pages = [page('a', 'A')];
      expect(searchPages('', pages), isEmpty);
      expect(searchPages('   ', pages), isEmpty);
      expect(searchPages('- _', pages), isEmpty);
    });

    test('limit', () {
      final pages = [for (var i = 0; i < 40; i++) page('i$i', 'Item $i')];
      expect(searchPages('item', pages), hasLength(30));
      expect(searchPages('item', pages, limit: 5), hasLength(5));
    });

    test('ties are alphabetical by title', () {
      final pages = [
        page('z', 'Zeta card'),
        page('a', 'Alpha card'),
        page('m', 'mid card'),
      ];
      expect(ids(searchPages('card', pages)), ['a', 'm', 'z']);
    });
  });

  group('the real registry', () {
    test('every page has keywords, and none are for a missing page', () {
      final known = {for (final p in showcasePages) p.id};
      for (final p in showcasePages) {
        expect(keywordsFor(p.id), isNotEmpty, reason: p.id);
      }
      expect(known.containsAll(keywordPageIds), isTrue);
    });

    test('searching a title finds that page first', () {
      for (final p in showcasePages) {
        final results = searchPages(p.title, showcasePages);
        expect(results, isNotEmpty, reason: p.title);
        expect(results.first.page.id, p.id, reason: p.title);
      }
    });

    test('searching by a keyword finds the page', () {
      expect(ids(searchPages('snackbar', showcasePages)), contains('toast'));
      expect(ids(searchPages('switch', showcasePages)), contains('toggle'));
    });
  });
}
