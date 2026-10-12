import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

import '../../showcase/photos.dart';

/// Compact cards with a thumbnail, a badge, a trailing price and no picture.
class ThumbnailCardExample extends StatelessWidget {
  const ThumbnailCardExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8,
      children: [
        D3ThumbnailCard(
          title: 'Citrus tart',
          imageUrl: photoUrl('citrus'),
          description: 'Lemon curd, toasted meringue and a crisp base.',
          badge: '2 for 1 on Fridays',
          trailing: const Text('P180'),
          onTap: () {},
        ),
        D3ThumbnailCard(
          title: 'Berry bowl',
          imageUrl: photoUrl('berry'),
          description: 'Seasonal berries with yoghurt.',
          footer: const Text('Contains nuts'),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () {},
        ),
        const D3ThumbnailCard(
          title: 'House salad',
          description: 'Text only: no picture, no reserved space.',
        ),
        D3ThumbnailCard(
          title: 'Search match: Citrus',
          imageUrl: photoUrl('forest'),
          highlightQuery: 'cit',
          thumbnailSize: 48,
        ),
      ],
    );
  }
}
