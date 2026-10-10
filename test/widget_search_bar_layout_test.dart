import 'package:d3_ui/d3_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('the search text is vertically centred and the bar is a pill', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: D3AppTheme.light(),
        home: Scaffold(
          body: Center(
            child: D3SearchBar(
              controller: TextEditingController(text: 'ramen'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final bar = tester.getRect(find.byType(D3SearchBar));
    final text = tester.getRect(find.text('ramen'));
    // A 48dp touch strip around a 40dp visible pill — not the whole screen.
    expect(bar.height, closeTo(48, 0.5));
    final pill = tester.getRect(find.byType(AnimatedContainer).first);
    expect(pill.height, closeTo(40, 0.5));
    // Pill and strip share a centre, so the text is centred in both.
    expect(pill.center.dy, closeTo(bar.center.dy, 0.5));
    expect(find.byType(DecoratedBox), findsWidgets);
    expect(
      (text.center.dy - bar.center.dy).abs(),
      lessThan(1.5),
      reason: 'text centre ${text.center.dy} vs bar centre ${bar.center.dy}',
    );

    final deco =
        tester
                .widget<AnimatedContainer>(find.byType(AnimatedContainer).first)
                .decoration!
            as BoxDecoration;
    expect(deco.borderRadius, BorderRadius.circular(D3Radius.full));
  });

  testWidgets('focus changes the fill, not an outline; taps in the strip '
      'above the pill still focus the field', (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(
      MaterialApp(
        theme: D3AppTheme.light(),
        home: Scaffold(
          body: Center(child: D3SearchBar(controller: controller)),
        ),
      ),
    );
    Color fill() =>
        (tester
                    .widget<AnimatedContainer>(
                      find.byType(AnimatedContainer).first,
                    )
                    .decoration!
                as BoxDecoration)
            .color!;
    final rest = fill();

    // 2dp above the 40dp pill is still inside the 48dp strip.
    final strip = tester.getRect(find.byType(D3SearchBar));
    await tester.tapAt(Offset(strip.center.dx, strip.top + 2));
    await tester.pumpAndSettle();

    expect(
      tester.widget<TextField>(find.byType(TextField)).focusNode!.hasFocus,
      isTrue,
    );
    expect(fill(), isNot(rest));
    expect(
      (tester
                  .widget<AnimatedContainer>(
                    find.byType(AnimatedContainer).first,
                  )
                  .decoration!
              as BoxDecoration)
          .border,
      isNull,
    );
  });
}
