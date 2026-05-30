import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:d3_ui/d3_ui.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: D3AppTheme.light(),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('D3Toggle', () {
    testWidgets('renders in on state', (tester) async {
      await tester.pumpWidget(_wrap(
        D3Toggle(value: true, onChanged: (_) {}),
      ));
      expect(find.byType(D3Toggle), findsOneWidget);
    });

    testWidgets('renders in off state', (tester) async {
      await tester.pumpWidget(_wrap(
        D3Toggle(value: false, onChanged: (_) {}),
      ));
      expect(find.byType(D3Toggle), findsOneWidget);
    });

    testWidgets('calls onChanged when tapped', (tester) async {
      bool? lastValue;
      await tester.pumpWidget(_wrap(
        D3Toggle(value: false, onChanged: (v) => lastValue = v),
      ));
      await tester.tap(find.byType(D3Toggle));
      await tester.pump();
      expect(lastValue, isTrue);
    });

    testWidgets('disabled when onChanged is null', (tester) async {
      await tester.pumpWidget(_wrap(
        const D3Toggle(value: false, onChanged: null),
      ));
      // Should render without error
      expect(find.byType(D3Toggle), findsOneWidget);
    });
  });

  group('D3Checkbox', () {
    testWidgets('renders checked state', (tester) async {
      await tester.pumpWidget(_wrap(
        D3Checkbox(value: true, onChanged: (_) {}),
      ));
      expect(find.byType(D3Checkbox), findsOneWidget);
    });

    testWidgets('renders unchecked state', (tester) async {
      await tester.pumpWidget(_wrap(
        D3Checkbox(value: false, onChanged: (_) {}),
      ));
      expect(find.byType(D3Checkbox), findsOneWidget);
    });

    testWidgets('calls onChanged when tapped', (tester) async {
      bool? result;
      await tester.pumpWidget(_wrap(
        D3Checkbox(value: false, onChanged: (v) => result = v),
      ));
      await tester.tap(find.byType(D3Checkbox));
      await tester.pump();
      expect(result, isTrue);
    });
  });

  group('D3Chip', () {
    testWidgets('renders label', (tester) async {
      await tester.pumpWidget(_wrap(
        const D3Chip(label: 'Flutter'),
      ));
      expect(find.text('Flutter'), findsOneWidget);
    });

    testWidgets('all chip variants render without error', (tester) async {
      for (final variant in D3ChipVariant.values) {
        await tester.pumpWidget(_wrap(
          D3Chip(label: variant.name, variant: variant),
        ));
        await tester.pump();
      }
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        D3Chip(label: 'Tap', onTap: () => tapped = true),
      ));
      await tester.tap(find.text('Tap'));
      expect(tapped, isTrue);
    });
  });

  group('D3SegmentedControl', () {
    const segments = [
      D3Segment(value: 'a', label: 'List'),
      D3Segment(value: 'b', label: 'Grid'),
      D3Segment(value: 'c', label: 'Map'),
    ];

    testWidgets('renders all segment labels', (tester) async {
      await tester.pumpWidget(_wrap(
        D3SegmentedControl(
          segments: segments,
          selected: 'a',
          onChanged: (_) {},
        ),
      ));
      expect(find.text('List'), findsOneWidget);
      expect(find.text('Grid'), findsOneWidget);
      expect(find.text('Map'), findsOneWidget);
    });

    testWidgets('calls onChanged when a segment is tapped', (tester) async {
      String? selected;
      await tester.pumpWidget(_wrap(
        D3SegmentedControl(
          segments: segments,
          selected: 'a',
          onChanged: (v) => selected = v,
        ),
      ));
      await tester.tap(find.text('Grid'));
      await tester.pump();
      expect(selected, 'b');
    });
  });

  group('D3Radio', () {
    testWidgets('renders selected state', (tester) async {
      await tester.pumpWidget(_wrap(
        D3Radio<String>(
          value: 'a',
          groupValue: 'a',
          onChanged: (_) {},
        ),
      ));
      expect(find.byType(D3Radio<String>), findsOneWidget);
    });

    testWidgets('renders unselected state', (tester) async {
      await tester.pumpWidget(_wrap(
        D3Radio<String>(
          value: 'a',
          groupValue: 'b',
          onChanged: (_) {},
        ),
      ));
      expect(find.byType(D3Radio<String>), findsOneWidget);
    });

    testWidgets('calls onChanged when tapped', (tester) async {
      String? result;
      await tester.pumpWidget(_wrap(
        D3Radio<String>(
          value: 'a',
          groupValue: 'b',
          onChanged: (v) => result = v,
        ),
      ));
      await tester.tap(find.byType(D3Radio<String>));
      await tester.pump();
      expect(result, 'a');
    });
  });
}
