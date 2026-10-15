import 'package:d3_ui/d3_ui.dart';
import 'package:d3_ui/src/components/inputs/d3_time_field.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: D3AppTheme.light(),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  const t = TimeOfDay(hour: 9, minute: 30);

  testWidgets('shows label, hint and formatted value', (tester) async {
    await tester.pumpWidget(
      _wrap(const D3TimeField(label: 'Start', hintText: 'Pick')),
    );
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Pick'), findsOneWidget);
    await tester.pumpWidget(
      _wrap(const D3TimeField(label: 'Start', initialValue: t, use24h: false)),
    );
    expect(find.text('9:30 AM'), findsOneWidget);
    await tester.pumpWidget(
      _wrap(const D3TimeField(label: 'Start', initialValue: t, use24h: true)),
    );
    expect(find.text('09:30'), findsOneWidget);
  });

  testWidgets('displayFormat overrides text', (tester) async {
    await tester.pumpWidget(
      _wrap(
        D3TimeField(
          label: 'Start',
          initialValue: t,
          displayFormat: (x) => 'h${x.hour}',
        ),
      ),
    );
    expect(find.text('h9'), findsOneWidget);
  });

  testWidgets('tap opens picker, Done calls onChanged and updates text', (
    tester,
  ) async {
    TimeOfDay? got;
    await tester.pumpWidget(
      _wrap(
        D3TimeField(
          label: 'Start',
          initialValue: t,
          use24h: false,
          onChanged: (v) => got = v,
        ),
      ),
    );
    await tester.tap(find.byType(InkWell));
    await tester.pumpAndSettle();
    expect(find.text('Done'), findsOneWidget);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(got, t);
    expect(find.text('9:30 AM'), findsOneWidget);
  });

  testWidgets('Cancel does not call onChanged', (tester) async {
    var called = false;
    await tester.pumpWidget(
      _wrap(D3TimeField(label: 'Start', onChanged: (_) => called = true)),
    );
    await tester.tap(find.byType(InkWell));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(called, isFalse);
  });

  testWidgets('disabled and read-only do not open the picker', (tester) async {
    await tester.pumpWidget(
      _wrap(const D3TimeField(label: 'Start', isEnabled: false)),
    );
    await tester.tap(find.byType(InkWell), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.text('Done'), findsNothing);
    await tester.pumpWidget(
      _wrap(const D3TimeField(label: 'Start', isReadOnly: true)),
    );
    await tester.tap(find.byType(InkWell), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.text('Done'), findsNothing);
  });

  testWidgets('shows errorText in place of helperText', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const D3TimeField(label: 'Start', helperText: 'h', errorText: 'Bad'),
      ),
    );
    expect(find.text('Bad'), findsOneWidget);
    expect(find.text('h'), findsNothing);
  });
}
