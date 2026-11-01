import 'package:d3_ui/d3_ui.dart';
import 'package:flutter/cupertino.dart' show CupertinoSlidingSegmentedControl;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  for (final entry in {
    'light': D3AppTheme.light(),
    'dark': D3AppTheme.dark(),
  }.entries) {
    testWidgets(
      '${entry.key}: the selected segment is an opaque fill, label at 4.5:1',
      (t) async {
        await t.pumpWidget(
          MaterialApp(
            theme: entry.value,
            home: Scaffold(
              body: D3SegmentedControl<String>(
                selected: 'b',
                onChanged: (_) {},
                segments: const [
                  D3Segment(value: 'a', label: 'High'),
                  D3Segment(value: 'b', label: 'Balanced'),
                  D3Segment(value: 'c', label: 'Low'),
                ],
              ),
            ),
          ),
        );
        final control = t.widget<CupertinoSlidingSegmentedControl<String>>(
          find.byType(CupertinoSlidingSegmentedControl<String>),
        );
        final thumb = control.thumbColor;
        expect(
          thumb.a,
          1.0,
          reason: 'translucent, the thumb shadow shows through',
        );

        final colors = entry.key == 'light'
            ? D3ColorTokens.light
            : D3ColorTokens.dark;
        expect(
          d3ContrastRatio(colors.onPrimaryContainer, thumb),
          greaterThanOrEqualTo(4.5),
        );
      },
    );
  }
}
