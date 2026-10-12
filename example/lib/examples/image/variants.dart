import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

import '../../showcase/photos.dart';

/// A network image with a fixed shape, and what it shows when it fails.
class ImageExample extends StatelessWidget {
  const ImageExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        D3Image(url: photoUrl('ocean'), width: 160, aspectRatio: 3 / 2),
        D3Image(
          url: photoUrl('forest'),
          width: 120,
          height: 120,
          borderRadius: D3Radius.circularFull,
        ),
        const D3Image(url: null, width: 160, aspectRatio: 3 / 2),
      ],
    );
  }
}
