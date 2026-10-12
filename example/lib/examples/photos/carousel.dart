import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

import '../../showcase/photos.dart';

/// Swipe through a few photos; tap one to open the full-screen viewer.
class PhotoCarouselExample extends StatelessWidget {
  const PhotoCarouselExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: D3PhotoCarousel(
          photoPaths: allPhotoUrls.take(4).toList(),
          itemLabel: 'Dish photo',
        ),
      ),
    );
  }
}
