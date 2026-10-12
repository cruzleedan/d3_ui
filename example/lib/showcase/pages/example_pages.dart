import 'package:material_ui/material_ui.dart';

import '../../examples/button/icons.dart';
import '../../examples/button/links.dart';
import '../../examples/button/sizes.dart';
import '../../examples/button/states.dart';
import '../../examples/button/variants.dart';
import '../../examples/chip/filters.dart';
import '../../examples/chip/status.dart';
import '../../examples/chip/variants.dart';
import '../../examples/chip/watch_status.dart';
import '../example_card.dart';
import '../generated/example_sources.g.dart';

String? _src(String path) => exampleSources[path];

/// D3Button and D3HyperlinkButton.
class ButtonPage extends StatelessWidget {
  const ButtonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ExamplePage(
      title: 'D3Button',
      summary:
          'The one button: five variants, five sizes, icons, and a built-in loading '
          'and success state. Use it for every action; use D3HyperlinkButton inline in text.',
      examples: [
        ExampleCard(
          title: 'Variants',
          description:
              'Filled for the main action, tonal and outlined for secondary ones, ghost for the quietest, danger for destructive.',
          source: _src('button/variants.dart'),
          child: const ButtonVariantsExample(),
        ),
        ExampleCard(
          title: 'Sizes',
          source: _src('button/sizes.dart'),
          child: const ButtonSizesExample(),
        ),
        ExampleCard(
          title: 'With icons',
          description: 'Leading or trailing icons, and icon-only buttons.',
          source: _src('button/icons.dart'),
          child: const ButtonIconsExample(),
        ),
        ExampleCard(
          title: 'Loading, success and disabled',
          description: 'Tap Save: the button runs the state machine itself.',
          source: _src('button/states.dart'),
          child: const ButtonStatesExample(),
        ),
        ExampleCard(
          title: 'D3HyperlinkButton',
          description: 'A link inside a sentence.',
          source: _src('button/links.dart'),
          child: const ButtonLinksExample(),
        ),
      ],
    );
  }
}

/// D3Chip and D3StatusChip.
class ChipPage extends StatelessWidget {
  const ChipPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ExamplePage(
      title: 'D3Chip',
      summary:
          'A compact label for filters, tags and status. A selected chip shows a '
          'check mark, so it never relies on colour alone.',
      examples: [
        ExampleCard(
          title: 'Variants',
          source: _src('chip/variants.dart'),
          child: const ChipVariantsExample(),
        ),
        ExampleCard(
          title: 'Filter chips',
          description: 'Tap to toggle.',
          source: _src('chip/filters.dart'),
          child: const ChipFiltersExample(),
        ),
        ExampleCard(
          title: 'Status badges from the theme',
          description:
              'Colours come from context.d3Status, so a brand sets them.',
          source: _src('chip/status.dart'),
          child: const ChipStatusExample(),
        ),
        ExampleCard(
          title: 'D3StatusChip',
          source: _src('chip/watch_status.dart'),
          child: const ChipWatchStatusExample(),
        ),
      ],
    );
  }
}
