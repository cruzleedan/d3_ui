import 'package:material_ui/material_ui.dart';

import '../../examples/bottom_sheet/basic.dart';
import '../../examples/bottom_sheet/discard_guard.dart';
import '../../examples/bottom_sheet/snap_points.dart';
import '../../examples/checkbox/select_all.dart';
import '../../examples/checkbox/states.dart';
import '../../examples/dialog/content.dart';
import '../../examples/dialog/variants.dart';
import '../../examples/filter_chip_row/variants.dart';
import '../../examples/form_sheet/basic.dart';
import '../../examples/radio/disabled.dart';
import '../../examples/radio/group.dart';
import '../../examples/segmented_control/variants.dart';
import '../../examples/toggle/states.dart';
import '../example_card.dart';
import 'page_helpers.dart';

class CheckboxPage extends StatelessWidget {
  const CheckboxPage({super.key});

  @override
  Widget build(BuildContext context) => ExamplePage(
        title: 'D3Checkbox',
        summary:
            'A checkbox with an optional label and an indeterminate state. Use it '
            'when people can pick any number of options, or to agree to something.',
        examples: [
          exampleCard(
              'States', 'checkbox/states.dart', const CheckboxStatesExample(),
              description: 'Tap the first two. The rest are fixed examples.'),
          exampleCard('Select all', 'checkbox/select_all.dart',
              const CheckboxSelectAllExample(),
              description:
                  'Pass null as the value to show a partly selected group.'),
        ],
      );
}

class RadioPage extends StatelessWidget {
  const RadioPage({super.key});

  @override
  Widget build(BuildContext context) => ExamplePage(
        title: 'D3Radio',
        summary:
            'A radio button with an optional label. Use it when exactly one '
            'option must be chosen and all options should stay visible.',
        examples: [
          exampleCard('Group', 'radio/group.dart', const RadioGroupExample()),
          exampleCard(
              'Disabled', 'radio/disabled.dart', const RadioDisabledExample()),
        ],
      );
}

class TogglePage extends StatelessWidget {
  const TogglePage({super.key});

  @override
  Widget build(BuildContext context) => ExamplePage(
        title: 'D3Toggle',
        summary:
            'An on/off switch with an optional label. Use it for a setting that '
            'takes effect immediately, without a save step.',
        examples: [
          exampleCard(
              'States', 'toggle/states.dart', const ToggleStatesExample(),
              description:
                  'Without a label, set semanticsLabel so screen readers can name it.'),
        ],
      );
}

class SegmentedControlPage extends StatelessWidget {
  const SegmentedControlPage({super.key});

  @override
  Widget build(BuildContext context) => ExamplePage(
        title: 'D3SegmentedControl',
        summary:
            'A short row of mutually exclusive options with a sliding highlight. '
            'Use it to switch a view or a range, not to navigate between pages.',
        examples: [
          exampleCard(
              'Text, icons and full width',
              'segmented_control/variants.dart',
              const SegmentedControlVariantsExample()),
        ],
      );
}

class FilterChipRowPage extends StatelessWidget {
  const FilterChipRowPage({super.key});

  @override
  Widget build(BuildContext context) => ExamplePage(
        title: 'D3FilterChipRow',
        summary:
            'A horizontally scrolling row of filter chips, single or multiple '
            'choice. Use it above a list to narrow what is shown.',
        examples: [
          exampleCard(
              'Single and multi select',
              'filter_chip_row/variants.dart',
              const FilterChipRowVariantsExample(),
              description:
                  'The second row allows several chips at once and shows icons.'),
        ],
      );
}

class BottomSheetPage extends StatelessWidget {
  const BottomSheetPage({super.key});

  @override
  Widget build(BuildContext context) => ExamplePage(
        title: 'D3BottomSheet',
        summary: 'A modal sheet that slides up from the bottom and can snap to '
            'several heights. Use it for pickers, filters and detail views.',
        examples: [
          exampleCard('Picker that returns a value', 'bottom_sheet/basic.dart',
              const BottomSheetBasicExample(),
              description:
                  'D3BottomSheet.pop closes the sheet and passes the result back.'),
          exampleCard('Snap points', 'bottom_sheet/snap_points.dart',
              const BottomSheetSnapPointsExample(),
              description: 'Drag the handle to move between half and tall.'),
          exampleCard('Discard guard', 'bottom_sheet/discard_guard.dart',
              const BottomSheetDiscardGuardExample()),
        ],
      );
}

class FormSheetPage extends StatelessWidget {
  const FormSheetPage({super.key});

  @override
  Widget build(BuildContext context) => ExamplePage(
        title: 'D3FormSheet',
        summary:
            'A bottom sheet sized to its content that stays above the keyboard. '
            'Use it for a short form with a single confirming action.',
        examples: [
          exampleCard('Form with a header action', 'form_sheet/basic.dart',
              const FormSheetBasicExample(),
              description:
                  'Save stays disabled until the name field has text.'),
        ],
      );
}

class DialogPage extends StatelessWidget {
  const DialogPage({super.key});

  @override
  Widget build(BuildContext context) => ExamplePage(
        title: 'D3Dialog',
        summary:
            'A centered dialog with an optional icon, message, custom content '
            'and actions. Use it for confirmations and short alerts.',
        examples: [
          exampleCard('Confirm, alert and plain', 'dialog/variants.dart',
              const DialogVariantsExample(),
              description:
                  'A centered icon stacks the actions; a leading icon or none keeps them inline.'),
          exampleCard('Custom content', 'dialog/content.dart',
              const DialogContentExample()),
        ],
      );
}
