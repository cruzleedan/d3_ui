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
    // A real bar: ~52dp tall, not the whole screen.
    expect(bar.height, inInclusiveRange(48, 60));
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
}
