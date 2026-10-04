import 'package:d3_ui/d3_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Widget _wrap(Widget child, {double width = 320}) => MaterialApp(
  key: UniqueKey(),
  theme: D3AppTheme.light(),
  home: Scaffold(
    body: Center(
      child: SizedBox(width: width, child: child),
    ),
  ),
);

List<Offset> _corners(Rect rect) => [
  rect.topLeft + const Offset(2, 2),
  rect.topRight + const Offset(-2, 2),
  rect.bottomLeft + const Offset(2, -2),
  rect.bottomRight + const Offset(-2, -2),
];

void _minimum(Rect rect) {
  expect(rect.width, greaterThanOrEqualTo(48));
  expect(rect.height, greaterThanOrEqualTo(48));
}

Finder _gesture(Finder child) =>
    find.ancestor(of: child, matching: find.byType(GestureDetector)).first;

void main() {
  testWidgets('compact input tokens cannot shrink date/dropdown actions', (
    tester,
  ) async {
    final tokens = D3InputTokens.defaults.copyWith(minHeight: 24, paddingV: 2);
    await tester.pumpWidget(
      MaterialApp(
        theme: D3AppTheme.light(inputTokens: tokens),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 240,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const D3DateField(label: 'Date'),
                  D3DropdownField<String, String>(
                    label: 'Choice',
                    items: const ['One'],
                    itemLabel: (v) => v,
                    itemValue: (v) => v,
                    mode: D3DropdownMode.sheet,
                  ),
                  const D3TextField(
                    label: 'Help',
                    tooltip: 'Details',
                    obscureText: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    _minimum(
      tester.getRect(
        find
            .ancestor(
              of: find.byIcon(Icons.calendar_today_outlined),
              matching: find.byType(InkWell),
            )
            .first,
      ),
    );
    _minimum(tester.getRect(_gesture(find.byIcon(Icons.unfold_more_rounded))));
    _minimum(tester.getRect(_gesture(find.byIcon(Icons.visibility_outlined))));
    _minimum(tester.getRect(_gesture(find.text('Help'))));
    expect(tester.takeException(), isNull);
  });

  final selections = <String, Widget Function(VoidCallback?, String?)>{
    'checkbox': (tap, label) => D3Checkbox(
      value: false,
      label: label,
      onChanged: tap == null ? null : (_) => tap(),
    ),
    'radio': (tap, label) => D3Radio<String>(
      value: 'a',
      groupValue: 'b',
      label: label,
      onChanged: tap == null ? null : (_) => tap(),
    ),
    'toggle': (tap, label) => D3Toggle(
      value: false,
      label: label,
      onChanged: tap == null ? null : (_) => tap(),
    ),
  };

  for (final entry in selections.entries) {
    for (final label in <String?>[null, 'Enable']) {
      testWidgets(
        '${entry.key} corners and label trigger exactly once ($label)',
        (tester) async {
          var calls = 0;
          await tester.pumpWidget(_wrap(entry.value(() => calls++, label)));
          final gestures = find.byType(GestureDetector);
          // The last gesture belongs to the control, inside any label wrapper.
          final rect = tester.getRect(gestures.last);
          _minimum(rect);
          for (final point in _corners(rect)) {
            final before = calls;
            await tester.tapAt(point);
            await tester.pumpAndSettle();
            expect(calls, before + 1);
          }
          if (label != null) {
            await tester.tap(find.text(label));
            await tester.pumpAndSettle();
            expect(calls, 5);
            // The empty area above the label belongs to the same target.
            final labelRect = tester.getRect(find.text(label));
            await tester.tapAt(Offset(labelRect.center.dx, rect.top + 2));
            await tester.pumpAndSettle();
            expect(calls, 6);
          }
          await tester.pumpWidget(_wrap(entry.value(null, label)));
          final disabled = tester.getRect(find.byType(GestureDetector).last);
          for (final point in _corners(disabled)) {
            await tester.tapAt(point);
          }
          await tester.pumpAndSettle();
          expect(calls, label == null ? 4 : 6);
        },
      );
    }
  }

  testWidgets('search clear corners work without changing bar height', (
    tester,
  ) async {
    var clears = 0;
    await tester.pumpWidget(_wrap(D3SearchBar(onClear: () => clears++)));
    final initialHeight = tester.getSize(find.byType(D3SearchBar)).height;
    for (var i = 0; i < 4; i++) {
      await tester.enterText(find.byType(TextField), 'query');
      await tester.pumpAndSettle();
      final rect = tester.getRect(_gesture(find.byIcon(Icons.close_rounded)));
      _minimum(rect);
      expect(tester.getSize(find.byType(D3SearchBar)).height, initialHeight);
      await tester.tapAt(_corners(rect)[i]);
      await tester.pumpAndSettle();
      expect(clears, i + 1);
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller!.text, isEmpty);
      expect(field.focusNode!.hasFocus, isTrue);
      expect(tester.getSize(find.byType(D3SearchBar)).height, initialHeight);
    }
  });

  testWidgets('search back button accepts all four corners', (tester) async {
    await tester.pumpWidget(
      _wrap(
        D3SearchAnchor<String, String>.local(
          items: const ['One'],
          filterItems: (items, query, filters) => items,
          resultBuilder: (context, results, query) => const Text('Results'),
        ),
      ),
    );
    for (var i = 0; i < 4; i++) {
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      final rect = tester.getRect(
        _gesture(find.byIcon(Icons.arrow_back_rounded)),
      );
      _minimum(rect);
      await tester.tapAt(_corners(rect)[i]);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.arrow_back_rounded), findsNothing);
    }
  });

  testWidgets(
    'interactive chips reserve separate targets; badges stay compact',
    (tester) async {
      var first = 0;
      var second = 0;
      await tester.pumpWidget(
        _wrap(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              D3Chip(label: 'A', onTap: () => first++),
              D3StatusChip(
                status: D3WatchStatus.watching,
                onTap: () => second++,
              ),
            ],
          ),
        ),
      );
      final targets = find.byType(InkWell);
      final left = tester.getRect(targets.at(0));
      final right = tester.getRect(targets.at(1));
      _minimum(left);
      _minimum(right);
      expect(left.overlaps(right), isFalse);
      for (final point in _corners(left)) {
        await tester.tapAt(point);
      }
      for (final point in _corners(right)) {
        await tester.tapAt(point);
      }
      expect(first, 4);
      expect(second, 4);
      await tester.pumpWidget(_wrap(const D3Chip(label: 'Badge')));
      expect(tester.getSize(find.byType(D3Chip)).height, lessThan(48));
      await tester.pumpWidget(
        _wrap(D3Chip(label: 'Disabled', enabled: false, onTap: () => first++)),
      );
      await tester.tap(find.text('Disabled'));
      expect(first, 4);
    },
  );

  testWidgets('segments remain at least 48 wide and scroll in narrow layouts', (
    tester,
  ) async {
    final selected = <String>[];
    await tester.pumpWidget(
      _wrap(
        D3SegmentedControl<String>(
          segments: const [
            D3Segment(value: 'a', label: 'A'),
            D3Segment(value: 'b', label: 'B'),
            D3Segment(value: 'c', label: 'C'),
          ],
          selected: null,
          onChanged: selected.add,
        ),
        width: 110,
      ),
    );
    for (final label in ['A', 'B', 'C']) {
      final target = _gesture(find.text(label));
      _minimum(tester.getRect(target));
      await tester.ensureVisible(target);
      await tester.pumpAndSettle();
      final rect = tester.getRect(target);
      for (final point in _corners(rect)) {
        await tester.tapAt(point);
      }
    }
    expect(selected, [
      'a',
      'a',
      'a',
      'a',
      'b',
      'b',
      'b',
      'b',
      'c',
      'c',
      'c',
      'c',
    ]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tooltip label has a full target and respects disabled state', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const D3TextField(label: 'Help', tooltip: 'Details')),
    );
    final target = _gesture(find.text('Help'));
    final rect = tester.getRect(target);
    _minimum(rect);
    for (final point in _corners(rect)) {
      await tester.tapAt(point);
      await tester.pumpAndSettle();
      expect(find.text('Details'), findsOneWidget);
      await tester.tapAt(const Offset(2, 2));
      await tester.pumpAndSettle();
      expect(find.text('Details'), findsNothing);
    }
    await tester.pumpWidget(
      _wrap(
        const D3TextField(label: 'Help', tooltip: 'Details', isEnabled: false),
      ),
    );
    await tester.tap(find.text('Help'));
    await tester.pumpAndSettle();
    expect(find.text('Details'), findsNothing);
  });

  testWidgets('date field blank corners open the picker', (tester) async {
    for (var i = 0; i < 4; i++) {
      await tester.pumpWidget(_wrap(const D3DateField(label: 'Date')));
      final target = find
          .ancestor(
            of: find.byIcon(Icons.calendar_today_outlined),
            matching: find.byType(InkWell),
          )
          .first;
      final rect = tester.getRect(target);
      _minimum(rect);
      await tester.tapAt(_corners(rect)[i]);
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsOneWidget);
    }
  });

  for (final mode in D3DropdownMode.values) {
    testWidgets('dropdown $mode blank corners open selection', (tester) async {
      for (var i = 0; i < 4; i++) {
        await tester.pumpWidget(
          _wrap(
            D3DropdownField<String, String>(
              label: 'Choice',
              items: const ['One'],
              itemLabel: (v) => v,
              itemValue: (v) => v,
              mode: mode,
            ),
          ),
        );
        final icon = find.byIcon(Icons.unfold_more_rounded);
        final target = mode == D3DropdownMode.sheet
            ? _gesture(icon)
            : find.ancestor(of: icon, matching: find.byType(InkWell)).first;
        final rect = tester.getRect(target);
        _minimum(rect);
        await tester.tapAt(_corners(rect)[i]);
        await tester.pumpAndSettle();
        expect(find.text('One'), findsOneWidget);
      }
    });
  }

  testWidgets('schema create action keeps a 48 dp target', (tester) async {
    var creates = 0;
    await tester.pumpWidget(
      _wrap(
        FieldRenderer(
          field: const FieldSchema(
            key: 'category',
            type: FieldType.dropdown,
            label: 'Category',
          ),
          value: null,
          onChanged: (_) {},
          onCreateNew: (_) async {
            creates++;
          },
        ),
      ),
    );
    await tester.tap(find.byType(D3DropdownField<FieldOption, String>));
    await tester.pumpAndSettle();
    final button = find
        .ancestor(
          of: find.byTooltip('Create new'),
          matching: find.byType(IconButton),
        )
        .first;
    final rect = tester.getRect(button);
    _minimum(rect);
    for (final point in _corners(rect)) {
      await tester.tapAt(point);
    }
    expect(creates, 4);
  });
}
