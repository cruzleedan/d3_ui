import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

import '../../showcase/photos.dart';

/// A picture-led card for a grid, with tags and a badge, and its skeleton. The
/// card fills the space it is given, so give it a size (a grid cell does).
class PosterCardExample extends StatelessWidget {
  const PosterCardExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        SizedBox(
          width: 150,
          height: 225,
          child: D3PosterCard(
            imageUrl: photoUrl('sunset'),
            title: 'Golden hour',
            subtitle: 'Rooftop bar',
            tags: const ['Drinks', 'View'],
            onTap: () => D3Toast.info(context, title: 'Golden hour'),
          ),
        ),
        SizedBox(
          width: 150,
          height: 225,
          child: D3PosterCard(
            imageUrl: photoUrl('berry'),
            title: 'Berry bakery',
            subtitle: 'Cakes and tarts',
            badge: const D3Chip(label: 'New', variant: D3ChipVariant.filled),
            onTap: () => D3Toast.info(context, title: 'Berry bakery'),
          ),
        ),
        const SizedBox(width: 150, height: 225, child: D3PosterCardSkeleton()),
      ],
    );
  }
}
