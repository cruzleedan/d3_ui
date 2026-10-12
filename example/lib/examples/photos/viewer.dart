import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

import '../../showcase/photos.dart';

/// The full-screen viewer: pinch to zoom, swipe between photos, drag down to close.
class ImageViewerExample extends StatelessWidget {
  const ImageViewerExample({super.key});

  @override
  Widget build(BuildContext context) {
    return D3Button(
      label: 'Open the viewer',
      variant: D3ButtonVariant.outlined,
      leadingIcon: Icons.photo_library_outlined,
      onPressed: () => D3ImageViewer.push<void>(
        context,
        title: const Text('Photos'),
        images: [for (final u in allPhotoUrls) D3ImageSource.network(u)],
      ),
    );
  }
}
