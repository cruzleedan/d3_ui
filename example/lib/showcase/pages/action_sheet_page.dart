import 'package:material_ui/material_ui.dart';

import '../../examples/action_sheet/basic.dart';
import '../../examples/action_sheet/selection.dart';
import '../example_card.dart';
import 'page_helpers.dart';

class ActionSheetPage extends StatelessWidget {
  const ActionSheetPage({super.key});

  @override
  Widget build(BuildContext context) => ExamplePage(
        title: 'D3ActionSheet',
        summary:
            'A bottom sheet of actions for mobile choices where a dialog serves '
            'poorly. Rows are thumb-sized, destructive actions are marked, and '
            'Cancel sits apart at the bottom.',
        examples: [
          exampleCard('Basic', 'action_sheet/basic.dart',
              const ActionSheetBasicExample(),
              description:
                  'Pop with a result from onPressedWithContext; Cancel returns null.'),
          exampleCard('Selection', 'action_sheet/selection.dart',
              const ActionSheetSelectionExample(),
              description: 'A title, a message and a checked current choice.'),
        ],
      );
}
