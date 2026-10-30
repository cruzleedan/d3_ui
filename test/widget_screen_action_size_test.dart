import 'package:d3_ui/d3_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('icon actions in the app bar are at least 48 dp square', (
    t,
  ) async {
    await t.pumpWidget(
      MaterialApp(
        theme: D3AppTheme.light(),
        home: D3Screen(
          title: 'Title',
          actions: [
            D3ScreenAction.icon(
              Icons.share,
              semanticsLabel: 'Share',
              onPressed: () {},
            ),
            D3ScreenAction.icon(
              Icons.settings,
              semanticsLabel: 'Settings',
              onPressed: () {},
            ),
          ],
          body: const SizedBox(),
        ),
      ),
    );
    for (final label in ['Share', 'Settings']) {
      final size = t.getSize(find.bySemanticsLabel(label));
      expect(size.width, greaterThanOrEqualTo(48), reason: label);
      expect(size.height, greaterThanOrEqualTo(48), reason: label);
    }
  });
}
