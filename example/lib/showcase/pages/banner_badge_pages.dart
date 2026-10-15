import 'package:material_ui/material_ui.dart';

import '../../examples/badge/on_widgets.dart';
import '../../examples/badge/variants.dart';
import '../../examples/banner/compact_and_title.dart';
import '../../examples/banner/variants.dart';
import '../example_card.dart';
import 'page_helpers.dart';

class BannerPage extends StatelessWidget {
  const BannerPage({super.key});

  @override
  Widget build(BuildContext context) => ExamplePage(
        title: 'D3Banner',
        summary:
            'A message that stays in the page until it is fixed or dismissed. '
            'Sits between the brief D3Toast and the blocking D3Dialog.',
        examples: [
          exampleCard('Variants, action and dismiss', 'banner/variants.dart',
              const BannerVariantsExample(),
              description: 'Dismiss the last one, then bring it back.'),
          exampleCard('Title, compact and custom icon',
              'banner/compact_and_title.dart', const BannerLayoutsExample()),
        ],
      );
}

class BadgePage extends StatelessWidget {
  const BadgePage({super.key});

  @override
  Widget build(BuildContext context) => ExamplePage(
        title: 'D3Badge',
        summary: 'A count, a dot or a status pill. Overlay one on any widget '
            'without changing its size.',
        examples: [
          exampleCard('Counts, dots and labels', 'badge/variants.dart',
              const BadgeVariantsExample(),
              description: '150 shows as 99+; a zero count is hidden.'),
          exampleCard('On an icon, an avatar and a row',
              'badge/on_widgets.dart', const BadgeOnWidgetsExample()),
        ],
      );
}
