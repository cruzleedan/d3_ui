import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

import '../../showcase/photos.dart';

/// A grid of thumbnails you can add to and remove from.
class PhotoGalleryExample extends StatefulWidget {
  const PhotoGalleryExample({super.key});

  @override
  State<PhotoGalleryExample> createState() => _PhotoGalleryExampleState();
}

class _PhotoGalleryExampleState extends State<PhotoGalleryExample> {
  late final List<String> _photos = allPhotoUrls.take(3).toList();

  void _add() {
    final next = allPhotoUrls[_photos.length % photoNames.length];
    setState(() => _photos.add(next));
  }

  @override
  Widget build(BuildContext context) {
    return D3PhotoGallery(
      photoPaths: _photos,
      itemLabel: 'Photo',
      onAdd: _add,
      onRemove: (i) => setState(() => _photos.removeAt(i)),
    );
  }
}
