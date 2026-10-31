import 'package:d3_ui/d3_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets(
    'icon actions in the app bar are 48 dp and leave the title alone',
    (t) async {
      await t.pumpWidget(
        MaterialApp(
          theme: D3AppTheme.light(),
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => D3Screen(
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
              ),
              child: const Text('go'),
            ),
          ),
        ),
      );
      await t.tap(find.text('go'));
      await t.pumpAndSettle();

      // The change must not push the bar's other parts around: the title stays
      // visible and the back button stays a square instead of stretching.
      expect(find.text('Title'), findsOneWidget);
      for (final label in ['Share', 'Settings', 'Back']) {
        final size = t.getSize(find.bySemanticsLabel(label));
        expect(size.width, greaterThanOrEqualTo(48), reason: label);
        expect(
          size.width,
          lessThanOrEqualTo(60),
          reason: '$label must not stretch',
        );
        expect(size.height, greaterThanOrEqualTo(48), reason: label);
      }
    },
  );
}
