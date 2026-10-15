import 'package:d3_ui/d3_ui.dart';
import 'package:d3_ui/src/components/sheets/d3_time_picker.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

TimeOfDay? _result;
bool _returned = false;

Widget _app({
  TimeOfDay? initial,
  bool? use24h,
  int interval = 1,
  Size size = const Size(400, 800),
  double scale = 1,
  ThemeMode mode = ThemeMode.light,
}) {
  return MaterialApp(
    theme: D3AppTheme.light(),
    darkTheme: D3AppTheme.dark(),
    themeMode: mode,
    builder: (context, child) => MediaQuery(
      data: MediaQueryData(size: size, textScaler: TextScaler.linear(scale)),
      child: child!,
    ),
    home: Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () async {
              _result = await showD3TimePicker(
                context,
                initialTime: initial,
                use24h: use24h,
                minuteInterval: interval,
              );
              _returned = true;
            },
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
}

Future<void> _open(WidgetTester tester, Widget app) async {
  _result = null;
  _returned = false;
  await tester.pumpWidget(app);
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

String _preview(WidgetTester tester) =>
    tester.widget<Text>(find.byKey(const ValueKey('d3-time-preview'))).data!;

Future<void> _increase(WidgetTester tester, String wheelKey) async {
  final node = tester.getSemantics(find.byKey(ValueKey(wheelKey)));
  // ignore: deprecated_member_use
  tester.binding.pipelineOwner.semanticsOwner!.performAction(
    node.id,
    SemanticsAction.increase,
  );
  await tester.pumpAndSettle();
}

void main() {
  const t = TimeOfDay(hour: 9, minute: 30);

  group('d3FormatTime', () {
    test('12-hour', () {
      expect(d3FormatTime(t), '9:30 AM');
      expect(d3FormatTime(const TimeOfDay(hour: 0, minute: 0)), '12:00 AM');
      expect(d3FormatTime(const TimeOfDay(hour: 12, minute: 5)), '12:05 PM');
      expect(d3FormatTime(const TimeOfDay(hour: 23, minute: 59)), '11:59 PM');
    });
    test('24-hour', () {
      expect(d3FormatTime(t, use24h: true), '09:30');
      expect(
        d3FormatTime(const TimeOfDay(hour: 21, minute: 5), use24h: true),
        '21:05',
      );
    });
  });

  group('showD3TimePicker', () {
    testWidgets('opens at the initial time and Done returns it', (
      tester,
    ) async {
      await _open(tester, _app(initial: t, use24h: false));
      expect(_preview(tester), '9:30 AM');
      expect(find.text('Select time'), findsWidgets);
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(_result, t);
    });

    testWidgets('semantics increase changes the preview', (tester) async {
      final handle = tester.ensureSemantics();
      await _open(tester, _app(initial: t, use24h: false));
      await _increase(tester, 'd3-wheel-hour');
      expect(_preview(tester), '10:30 AM');
      await _increase(tester, 'd3-wheel-minute');
      expect(_preview(tester), '10:31 AM');
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(_result, const TimeOfDay(hour: 10, minute: 31));
      handle.dispose();
    });

    testWidgets('dragging a wheel changes the value', (tester) async {
      await _open(tester, _app(initial: t, use24h: false));
      await tester.fling(
        find.byKey(const ValueKey('d3-wheel-hour')),
        const Offset(0, -150),
        200,
      );
      await tester.pumpAndSettle();
      expect(_preview(tester), isNot('9:30 AM'));
    });

    testWidgets('wheels expose label and adjustable actions', (tester) async {
      final handle = tester.ensureSemantics();
      await _open(tester, _app(initial: t, use24h: false));
      final node = tester.getSemantics(
        find.byKey(const ValueKey('d3-wheel-hour')),
      );
      expect(node.label, 'Hour');
      expect(node.value, '9');
      expect(
        node.getSemanticsData().hasAction(SemanticsAction.increase),
        isTrue,
      );
      expect(
        node.getSemanticsData().hasAction(SemanticsAction.decrease),
        isTrue,
      );
      handle.dispose();
    });

    testWidgets('Cancel returns null', (tester) async {
      await _open(tester, _app(initial: t));
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(_returned, isTrue);
      expect(_result, isNull);
    });

    testWidgets('tap outside returns null', (tester) async {
      await _open(tester, _app(initial: t));
      await tester.tapAt(const Offset(200, 20));
      await tester.pumpAndSettle();
      expect(_returned, isTrue);
      expect(_result, isNull);
    });

    testWidgets('minute interval 15 offers 0/15/30/45 and snaps initial', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _open(
        tester,
        _app(initial: const TimeOfDay(hour: 9, minute: 22), interval: 15),
      );
      expect(_preview(tester), '9:15 AM');
      await _increase(tester, 'd3-wheel-minute');
      expect(_preview(tester), '9:30 AM');
      await _increase(tester, 'd3-wheel-minute');
      await _increase(tester, 'd3-wheel-minute');
      expect(_preview(tester), '9:45 AM');
      await _increase(tester, 'd3-wheel-minute'); // last item, stays
      expect(_preview(tester), '9:45 AM');
      handle.dispose();
    });

    testWidgets('24h hides AM/PM', (tester) async {
      await _open(
        tester,
        _app(initial: const TimeOfDay(hour: 17, minute: 5), use24h: true),
      );
      expect(find.byKey(const ValueKey('d3-wheel-period')), findsNothing);
      expect(_preview(tester), '17:05');
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(_result, const TimeOfDay(hour: 17, minute: 5));
    });

    testWidgets('12h maps 12 AM to 0:00 and 12 PM to 12:00', (tester) async {
      final handle = tester.ensureSemantics();
      await _open(
        tester,
        _app(initial: const TimeOfDay(hour: 0, minute: 0), use24h: false),
      );
      expect(_preview(tester), '12:00 AM');
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(_result, const TimeOfDay(hour: 0, minute: 0));

      await _open(
        tester,
        _app(initial: const TimeOfDay(hour: 0, minute: 0), use24h: false),
      );
      await _increase(tester, 'd3-wheel-period');
      expect(_preview(tester), '12:00 PM');
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(_result, const TimeOfDay(hour: 12, minute: 0));
      handle.dispose();
    });

    testWidgets('wheel rows are at least 48dp', (tester) async {
      await _open(tester, _app(initial: t, use24h: false));
      final h = tester.getSize(
        find.byKey(const ValueKey('d3-wheel-band')).first,
      );
      expect(h.height, greaterThanOrEqualTo(48));
      expect(
        tester.getSize(find.widgetWithText(FilledButton, 'Done')).height,
        greaterThanOrEqualTo(48),
      );
      expect(
        tester.getSize(find.widgetWithText(OutlinedButton, 'Cancel')).height,
        greaterThanOrEqualTo(48),
      );
    });

    testWidgets('no overflow at 320x568 and text scale 1.5', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await _open(
        tester,
        _app(initial: t, use24h: false, size: const Size(320, 568), scale: 1.5),
      );
      expect(tester.takeException(), isNull);
      final band = tester.getSize(
        find.byKey(const ValueKey('d3-wheel-band')).first,
      );
      expect(band.height, greaterThan(48));
      expect(find.text('Done'), findsOneWidget);
    });

    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('selected text contrast meets 4.5:1 ($mode)', (tester) async {
        await _open(tester, _app(initial: t, use24h: false, mode: mode));
        final context = tester.element(
          find.byKey(const ValueKey('d3-wheel-band')).first,
        );
        final c = context.d3Colors;
        final surface = c.surfaceContainerLow;
        final band = Color.alphaBlend(c.primaryContainer, surface);
        final sel = tester.widget<Text>(find.text('9').first).style!.color!;
        expect(d3ContrastRatio(sel, band), greaterThanOrEqualTo(4.5));
        final preview = tester
            .widget<Text>(find.byKey(const ValueKey('d3-time-preview')))
            .style!
            .color!;
        expect(d3ContrastRatio(preview, surface), greaterThanOrEqualTo(4.5));
      });
    }
  });
}
