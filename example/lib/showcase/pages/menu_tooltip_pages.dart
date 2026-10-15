import 'package:material_ui/material_ui.dart';

import '../../examples/menu/basic.dart';
import '../../examples/menu/custom_trigger.dart';
import '../../examples/tooltip/basic.dart';
import '../example_card.dart';
import 'page_helpers.dart';

/// D3Menu and D3MenuButton.
class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ExamplePage(
      title: 'D3Menu',
      summary:
          'An overflow or context menu anchored to its trigger. It flips and shifts to stay on '
          'screen, and supports keyboard navigation, destructive and selected items.',
      examples: [
        exampleCard(
          'Overflow menu',
          'menu/basic.dart',
          const MenuBasicExample(),
          description:
              'D3MenuButton with a section, a selected item, a disabled item and a destructive one.',
        ),
        exampleCard(
          'Custom trigger',
          'menu/custom_trigger.dart',
          const MenuCustomTriggerExample(),
          description:
              'Any widget can open the menu; here a sort-order picker.',
        ),
      ],
    );
  }
}

/// D3Tooltip and D3InfoTip.
class TooltipPage extends StatelessWidget {
  const TooltipPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ExamplePage(
      title: 'D3Tooltip',
      summary:
          'Short labels on hover, focus and long-press, plus D3InfoTip, a tap-to-open hint '
          'that works on touch.',
      examples: [
        exampleCard(
          'Tooltips and info tip',
          'tooltip/basic.dart',
          const TooltipBasicExample(),
          description: 'Hover, focus or long-press; tap the info icon.',
        ),
      ],
    );
  }
}
