import 'package:material_ui/material_ui.dart';

import '../../examples/card/media.dart';
import '../../examples/card/variants.dart';
import '../../examples/info_card/basic.dart';
import '../../examples/list_screen/basic.dart';
import '../../examples/list_tile/variants.dart';
import '../../examples/nav_bar/variants.dart';
import '../../examples/screen/box.dart';
import '../../examples/screen/modal.dart';
import '../../examples/screen/sliver.dart';
import '../../examples/scroll_over_sheet/basic.dart';
import '../../examples/slidable_row/basic.dart';
import '../../examples/sticky_header/basic.dart';
import '../../examples/tab_bar/variants.dart';
import '../../examples/thumbnail_card/variants.dart';
import '../../examples/ticket_card/variants.dart';
import '../example_card.dart';
import 'page_helpers.dart';

class ScreenPage extends StatelessWidget {
  const ScreenPage({super.key});

  @override
  Widget build(BuildContext context) => ExamplePage(
        title: 'D3Screen',
        summary:
            'A full page with a toolbar: title, back or cancel, trailing actions and a body. Use it as the base of every screen so the bars look the same everywhere.',
        examples: [
          exampleCard('Box layout', 'screen/box.dart', const ScreenBoxExample(),
              description:
                  'Shown inside a bordered box. The back arrow appears automatically when the route can be popped.'),
          exampleCard('Sliver layout', 'screen/sliver.dart',
              const ScreenSliverExample(),
              description:
                  'The title starts large and collapses into the toolbar as the list scrolls.'),
          exampleCard(
              'Modal style', 'screen/modal.dart', const ScreenModalExample()),
        ],
      );
}

class ListScreenPage extends StatelessWidget {
  const ListScreenPage({super.key});

  @override
  Widget build(BuildContext context) => ExamplePage(
        title: 'D3ListScreen',
        summary:
            'A ready-made list page with search, filter chips, pull to refresh and multi-select. Use it for any screen that is mainly a searchable list.',
        examples: [
          exampleCard('Search, filters and selection', 'list_screen/basic.dart',
              const ListScreenExample(),
              description:
                  'Tap the search icon, pick a filter, or long-press a row to select. Shown inside a bordered box with its own Navigator.'),
        ],
      );
}

class ScrollOverSheetPage extends StatelessWidget {
  const ScrollOverSheetPage({super.key});

  @override
  Widget build(BuildContext context) => ExamplePage(
        title: 'D3ScrollOverSheetScaffold',
        summary:
            'A hero page with a sheet that slides up over it as you scroll, as on a restaurant screen. Use it when a picture or summary should give way to a long list.',
        examples: [
          exampleCard('Sheet over a photo', 'scroll_over_sheet/basic.dart',
              const ScrollOverSheetExample(),
              description:
                  'The top bar fades in as the sheet covers the photo. Scroll inside the box.'),
        ],
      );
}

class NavBarPage extends StatelessWidget {
  const NavBarPage({super.key});

  @override
  Widget build(BuildContext context) => ExamplePage(
        title: 'D3NavBar',
        summary:
            'The bottom bar for switching between top-level sections, with badges and an optional centre action. Keep it to three to five items.',
        examples: [
          exampleCard('Items, badges and centre action',
              'nav_bar/variants.dart', const NavBarExample()),
        ],
      );
}

class TabBarPage extends StatelessWidget {
  const TabBarPage({super.key});

  @override
  Widget build(BuildContext context) => ExamplePage(
        title: 'D3TabBar',
        summary:
            'A row of tabs for switching between views of the same content. Scrolls when there are too many to fit.',
        examples: [
          exampleCard('Scrollable and fixed', 'tab_bar/variants.dart',
              const TabBarExample(),
              description:
                  'The bar manages its own selection unless you pass a TabController.'),
        ],
      );
}

class StickyHeaderPage extends StatelessWidget {
  const StickyHeaderPage({super.key});

  @override
  Widget build(BuildContext context) => ExamplePage(
        title: 'D3StickyHeader',
        summary:
            'A sliver that pins a row to the top while a list scrolls beneath it. Use it for a persistent action or label above a long list.',
        examples: [
          exampleCard('Pinned action row', 'sticky_header/basic.dart',
              const StickyHeaderExample(),
              description:
                  'Use it inside a CustomScrollView. Scroll inside the box.'),
        ],
      );
}

class CardPage extends StatelessWidget {
  const CardPage({super.key});

  @override
  Widget build(BuildContext context) => ExamplePage(
        title: 'D3Card',
        summary:
            'A container for a short, self-contained piece of content, with optional picture, heading, body and footer. Use it for items a person can open.',
        examples: [
          exampleCard('Variants and footer', 'card/variants.dart',
              const CardVariantsExample()),
          exampleCard(
              'With a picture', 'card/media.dart', const CardMediaExample()),
        ],
      );
}

class InfoCardPage extends StatelessWidget {
  const InfoCardPage({super.key});

  @override
  Widget build(BuildContext context) => ExamplePage(
        title: 'D3InfoCard',
        summary:
            'An outlined box of icon and text facts, such as an address and opening hours. Use it for details that are read, not tapped.',
        examples: [
          exampleCard('Facts about a place', 'info_card/basic.dart',
              const InfoCardExample(),
              description:
                  'Each row is a D3InfoRow; use the default constructor for custom content.'),
        ],
      );
}

class ListTilePage extends StatelessWidget {
  const ListTilePage({super.key});

  @override
  Widget build(BuildContext context) => ExamplePage(
        title: 'D3ListTile',
        summary:
            'A single row with a leading widget, text and a trailing widget. Use D3ListTileGroup to join several into one bordered block, as in settings.',
        examples: [
          exampleCard('Rows, states and grouping', 'list_tile/variants.dart',
              const ListTileExample()),
        ],
      );
}

class SlidableRowPage extends StatelessWidget {
  const SlidableRowPage({super.key});

  @override
  Widget build(BuildContext context) => ExamplePage(
        title: 'D3SlidableRow',
        summary:
            'Wraps a row so swiping it left reveals actions such as archive or delete. Use it for quick actions on list items.',
        examples: [
          exampleCard('Swipe actions', 'slidable_row/basic.dart',
              const SlidableRowExample(),
              description:
                  'Rows with the same groupTag close each other when one opens.'),
        ],
      );
}

class ThumbnailCardPage extends StatelessWidget {
  const ThumbnailCardPage({super.key});

  @override
  Widget build(BuildContext context) => ExamplePage(
        title: 'D3ThumbnailCard',
        summary:
            'A compact card with a small picture, a title, a description and a trailing value. Use it for menu items and search results.',
        examples: [
          exampleCard('Picture, badge, footer and search highlight',
              'thumbnail_card/variants.dart', const ThumbnailCardExample(),
              description: 'A card without an image is text only.'),
        ],
      );
}

class TicketCardPage extends StatelessWidget {
  const TicketCardPage({super.key});

  @override
  Widget build(BuildContext context) => ExamplePage(
        title: 'D3TicketCard',
        summary:
            'A coupon-shaped card with notches and a tear line. Use it for offers and vouchers.',
        examples: [
          exampleCard(
              'Coupons', 'ticket_card/variants.dart', const TicketCardExample(),
              description:
                  'Cards grow with the system text size instead of clipping.'),
        ],
      );
}
