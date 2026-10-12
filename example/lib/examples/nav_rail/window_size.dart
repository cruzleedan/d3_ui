import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// Choosing a layout from the width it is given: drag the box's edge by
/// resizing the browser, or read the class for this card's width.
class WindowSizeExample extends StatelessWidget {
  const WindowSizeExample({super.key});

  @override
  Widget build(BuildContext context) {
    return D3WindowSizeBuilder(
      builder: (context, sizeClass) {
        final text = switch (sizeClass) {
          D3WindowSizeClass.compact =>
            'Compact (under 600): bottom bar, one pane',
          D3WindowSizeClass.medium => 'Medium (600 to 839): rail, one pane',
          D3WindowSizeClass.expanded =>
            'Expanded (840 and over): rail, list and detail',
        };
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Wrap(
              spacing: 8,
              children: [
                for (final c in D3WindowSizeClass.values)
                  D3Chip(label: c.name, selected: c == sizeClass),
              ],
            ),
            Text(text),
          ],
        );
      },
    );
  }
}
