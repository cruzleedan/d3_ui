import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

import '../../showcase/photos.dart';

/// A card with a picture across the top, tappable as a whole.
class CardMediaExample extends StatelessWidget {
  const CardMediaExample({super.key});

  @override
  Widget build(BuildContext context) {
    return D3Card(
      media: D3Image(
        url: photoUrl('ocean'),
        width: double.infinity,
        borderRadius: BorderRadius.zero,
      ),
      mediaHeight: 160,
      eyebrow: 'New',
      title: 'Harbour Fish',
      subtitle: 'Seafood, 1.2 km away',
      onTap: () {},
    );
  }
}
