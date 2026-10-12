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
import '../../examples/expanding_fab/basic.dart';
import '../../examples/scrim_button/basic.dart';
import '../../examples/split_button/sizes_disabled.dart';
import '../../examples/split_button/variants.dart';
import '../example_card.dart';
import 'page_helpers.dart';

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
        exampleCard(
          'Variants',
          'button/variants.dart',
          const ButtonVariantsExample(),
          description:
              'Filled for the main action, tonal and outlined for secondary ones, ghost for the quietest, danger for destructive.',
        ),
        exampleCard('Sizes', 'button/sizes.dart', const ButtonSizesExample()),
        exampleCard(
          'With icons',
          'button/icons.dart',
          const ButtonIconsExample(),
          description: 'Leading or trailing icons, and icon-only buttons.',
        ),
        exampleCard(
          'Loading, success and disabled',
          'button/states.dart',
          const ButtonStatesExample(),
          description: 'Tap Save: the button runs the state machine itself.',
        ),
        exampleCard(
          'D3HyperlinkButton',
          'button/links.dart',
          const ButtonLinksExample(),
          description: 'A link inside a sentence.',
        ),
      ],
    );
  }
}

/// D3SplitButton.
class SplitButtonPage extends StatelessWidget {
  const SplitButtonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ExamplePage(
      title: 'D3SplitButton',
      summary:
          'A main action plus a menu of related ones. Use it when one action is '
          'the usual choice and a few others are close by.',
      examples: [
        exampleCard(
          'Variants',
          'split_button/variants.dart',
          const SplitButtonVariantsExample(),
          description:
              'Items can have icons; a destructive item is tinted. Tap the arrow for the menu.',
        ),
        exampleCard(
          'Sizes and disabled',
          'split_button/sizes_disabled.dart',
          const SplitButtonSizesExample(),
        ),
      ],
    );
  }
}

/// D3ExpandingFab.
class ExpandingFabPage extends StatelessWidget {
  const ExpandingFabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ExamplePage(
      title: 'D3ExpandingFab',
      summary:
          'A floating button that fans out a short list of actions. Put it in a '
          'Scaffold\'s floatingActionButton slot.',
      examples: [
        exampleCard(
          'Two actions',
          'expanding_fab/basic.dart',
          const ExpandingFabExample(),
          description: 'Tap the plus.',
        ),
      ],
    );
  }
}

/// D3ScrimIconButton.
class ScrimButtonPage extends StatelessWidget {
  const ScrimButtonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ExamplePage(
      title: 'D3ScrimIconButton',
      summary:
          'A round icon button on a dark scrim, so it stays readable on top of a '
          'photo whatever the picture is.',
      examples: [
        exampleCard(
          'On a picture',
          'scrim_button/basic.dart',
          const ScrimButtonExample(),
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
        exampleCard(
            'Variants', 'chip/variants.dart', const ChipVariantsExample()),
        exampleCard(
          'Filter chips',
          'chip/filters.dart',
          const ChipFiltersExample(),
          description: 'Tap to toggle.',
        ),
        exampleCard(
          'Status badges from the theme',
          'chip/status.dart',
          const ChipStatusExample(),
          description:
              'Colours come from context.d3Status, so a brand sets them.',
        ),
        exampleCard(
          'D3StatusChip',
          'chip/watch_status.dart',
          const ChipWatchStatusExample(),
        ),
      ],
    );
  }
}
