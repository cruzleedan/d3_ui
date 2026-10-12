import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// Placeholders shown while content loads; the shimmer runs on all of them.
class SkeletonExample extends StatelessWidget {
  const SkeletonExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const D3Shimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          D3SkeletonBox(width: 180, height: 22),
          SizedBox(height: 12),
          D3SkeletonText(lines: 3),
          SizedBox(height: 16),
          D3ListTileSkeleton(),
          D3ListTileSkeleton(showSubtitle: false),
          SizedBox(height: 8),
          D3FormSkeleton(fieldCount: 2),
        ],
      ),
    );
  }
}
