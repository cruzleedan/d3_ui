import 'package:material_ui/material_ui.dart';

import '../../examples/avatar/sizes_group.dart';
import '../../examples/avatar/variants.dart';
import '../../examples/empty_state/variants.dart';
import '../../examples/expandable_section/variants.dart';
import '../../examples/image/variants.dart';
import '../../examples/list/select_circle.dart';
import '../../examples/list/variants.dart';
import '../../examples/photos/carousel.dart';
import '../../examples/photos/gallery.dart';
import '../../examples/photos/viewer.dart';
import '../../examples/poster_card/variants.dart';
import '../../examples/section_header/variants.dart';
import '../../examples/skeleton/variants.dart';
import '../../examples/toast/action.dart';
import '../../examples/toast/variants.dart';
import '../example_card.dart';
import 'page_helpers.dart';

class AvatarPage extends StatelessWidget {
  const AvatarPage({super.key});

  @override
  Widget build(BuildContext context) => ExamplePage(
        title: 'D3Avatar',
        summary:
            'A person or place as a picture, or initials when there is no picture. '
            'Optional presence dot; a group collapses extra people into a count.',
        examples: [
          exampleCard('Initials, picture, shape and presence',
              'avatar/variants.dart', const AvatarVariantsExample()),
          exampleCard('Sizes and groups', 'avatar/sizes_group.dart',
              const AvatarSizesExample()),
        ],
      );
}

class ImagePage extends StatelessWidget {
  const ImagePage({super.key});

  @override
  Widget build(BuildContext context) => ExamplePage(
        title: 'D3Image',
        summary:
            'A network image with a fixed shape, a loading placeholder and a quiet '
            'error state, so a broken link never breaks the layout.',
        examples: [
          exampleCard('Shapes and the error state', 'image/variants.dart',
              const ImageExample(),
              description:
                  'The last one has no URL, so it shows the error icon.'),
        ],
      );
}

class PosterCardPage extends StatelessWidget {
  const PosterCardPage({super.key});

  @override
  Widget build(BuildContext context) => ExamplePage(
        title: 'D3PosterCard',
        summary:
            'A picture-led card for grids: image, title, subtitle, tags and an '
            'optional badge. Comes with a matching skeleton.',
        examples: [
          exampleCard('Cards and skeleton', 'poster_card/variants.dart',
              const PosterCardExample()),
        ],
      );
}

class PhotosPage extends StatelessWidget {
  const PhotosPage({super.key});

  @override
  Widget build(BuildContext context) => ExamplePage(
        title: 'Photos',
        summary:
            'D3PhotoCarousel, D3PhotoGallery and D3ImageViewer: show a few photos, '
            'manage a set, and open them full screen.',
        examples: [
          exampleCard('D3PhotoCarousel', 'photos/carousel.dart',
              const PhotoCarouselExample(),
              description: 'Swipe, or tap a photo to open it.'),
          exampleCard('D3PhotoGallery', 'photos/gallery.dart',
              const PhotoGalleryExample(),
              description: 'Add a photo, or remove one.'),
          exampleCard('D3ImageViewer', 'photos/viewer.dart',
              const ImageViewerExample()),
        ],
      );
}

class SkeletonPage extends StatelessWidget {
  const SkeletonPage({super.key});

  @override
  Widget build(BuildContext context) => ExamplePage(
        title: 'Skeleton',
        summary:
            'Grey placeholders that hold a screen\'s shape while it loads, so the '
            'content does not jump when it arrives.',
        examples: [
          exampleCard('Boxes, text, rows and forms', 'skeleton/variants.dart',
              const SkeletonExample()),
        ],
      );
}

class EmptyStatePage extends StatelessWidget {
  const EmptyStatePage({super.key});

  @override
  Widget build(BuildContext context) => ExamplePage(
        title: 'D3EmptyState',
        summary:
            'What to show when there is nothing to show: why it is empty, and what '
            'the person can do about it.',
        examples: [
          exampleCard('Standard and compact', 'empty_state/variants.dart',
              const EmptyStateExample()),
        ],
      );
}

class SectionHeaderPage extends StatelessWidget {
  const SectionHeaderPage({super.key});

  @override
  Widget build(BuildContext context) => ExamplePage(
        title: 'D3SectionHeader',
        summary:
            'A label for a group of rows, with an optional count and action.',
        examples: [
          exampleCard('Label, count and action', 'section_header/variants.dart',
              const SectionHeaderExample()),
        ],
      );
}

class ExpandableSectionPage extends StatelessWidget {
  const ExpandableSectionPage({super.key});

  @override
  Widget build(BuildContext context) => ExamplePage(
        title: 'D3ExpandableSection',
        summary:
            'A titled block that opens and closes, for details most people skip.',
        examples: [
          exampleCard('Open and closed', 'expandable_section/variants.dart',
              const ExpandableSectionExample()),
        ],
      );
}

class ListPage extends StatelessWidget {
  const ListPage({super.key});

  @override
  Widget build(BuildContext context) => ExamplePage(
        title: 'D3List',
        summary: 'A scrolling list with sections, pull to refresh, paging and '
            'multi-select, so each screen does not rebuild them.',
        examples: [
          exampleCard('Sections and selection', 'list/variants.dart',
              const ListExample(),
              description: 'Long-press a row to start selecting.'),
          exampleCard('D3SelectCircle', 'list/select_circle.dart',
              const SelectCircleExample(),
              description: 'The circle on its own, at two sizes.'),
        ],
      );
}

class ToastPage extends StatelessWidget {
  const ToastPage({super.key});

  @override
  Widget build(BuildContext context) => ExamplePage(
        title: 'D3Toast',
        summary:
            'A short message that appears and goes away by itself. Use it to '
            'confirm something; do not use it for anything the person must read.',
        examples: [
          exampleCard(
              'Kinds', 'toast/variants.dart', const ToastVariantsExample(),
              description: 'Tap each one; it appears at the bottom.'),
          exampleCard(
              'With an action', 'toast/action.dart', const ToastActionExample(),
              description: 'Stays until dismissed.'),
        ],
      );
}
