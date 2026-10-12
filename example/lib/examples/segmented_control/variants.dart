import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// Segmented controls with text, icons and a full-width layout.
class SegmentedControlVariantsExample extends StatefulWidget {
  const SegmentedControlVariantsExample({super.key});

  @override
  State<SegmentedControlVariantsExample> createState() =>
      _SegmentedControlVariantsExampleState();
}

class _SegmentedControlVariantsExampleState
    extends State<SegmentedControlVariantsExample> {
  String _range = 'week';
  String _layout = 'grid';
  String _sort = 'newest';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        D3SegmentedControl<String>(
          segments: const [
            D3Segment(value: 'day', label: 'Day'),
            D3Segment(value: 'week', label: 'Week'),
            D3Segment(value: 'month', label: 'Month'),
          ],
          selected: _range,
          onChanged: (v) => setState(() => _range = v),
        ),
        const SizedBox(height: 16),
        D3SegmentedControl<String>(
          segments: const [
            D3Segment(
              value: 'grid',
              icon: Icons.grid_view_rounded,
              semanticsLabel: 'Grid',
            ),
            D3Segment(
              value: 'list',
              icon: Icons.view_list_rounded,
              semanticsLabel: 'List',
            ),
          ],
          selected: _layout,
          onChanged: (v) => setState(() => _layout = v),
        ),
        const SizedBox(height: 16),
        D3SegmentedControl<String>(
          expand: true,
          segments: const [
            D3Segment(
              value: 'newest',
              label: 'Newest',
              icon: Icons.schedule_rounded,
            ),
            D3Segment(
              value: 'popular',
              label: 'Popular',
              icon: Icons.trending_up_rounded,
            ),
          ],
          selected: _sort,
          onChanged: (v) => setState(() => _sort = v),
        ),
      ],
    );
  }
}
