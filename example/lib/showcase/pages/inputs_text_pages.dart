import 'package:material_ui/material_ui.dart';

import '../../examples/calendar_picker/open_dialog.dart';
import '../../examples/date_field/calendar_picker.dart';
import '../../examples/date_field/variants.dart';
import '../../examples/decimal_field/variants.dart';
import '../../examples/dropdown_field/sheet_search.dart';
import '../../examples/dropdown_field/variants.dart';
import '../../examples/schema_form/basic.dart';
import '../../examples/search/search_anchor.dart';
import '../../examples/search/search_bar.dart';
import '../../examples/text_field/states.dart';
import '../../examples/text_field/variants.dart';
import '../example_card.dart';
import 'page_helpers.dart';

class TextFieldPage extends StatelessWidget {
  const TextFieldPage({super.key});

  @override
  Widget build(BuildContext context) => ExamplePage(
        title: 'D3TextField',
        summary:
            'A single or multi-line text input with a label, helper text and built-in validation states. Use it for any free-form text in a form.',
        examples: [
          exampleCard('Variants', 'text_field/variants.dart',
              const TextFieldVariantsExample(),
              description:
                  'Outlined is the default; filled suits inline or search-like fields.'),
          exampleCard('States', 'text_field/states.dart',
              const TextFieldStatesExample(),
              description:
                  'The password field validates on blur, then live once an error shows.'),
        ],
      );
}

class DateFieldPage extends StatelessWidget {
  const DateFieldPage({super.key});

  @override
  Widget build(BuildContext context) => ExamplePage(
        title: 'D3DateField',
        summary:
            'A read-only field that opens a date picker when tapped. Use it when the user must choose a single calendar date.',
        examples: [
          exampleCard('Variants', 'date_field/variants.dart',
              const DateFieldVariantsExample()),
          exampleCard(
              'Themed calendar and marked days',
              'date_field/calendar_picker.dart',
              const DateFieldCalendarExample(),
              description:
                  'Set useD3CalendarPicker to use the d3_ui calendar instead of the system picker.'),
        ],
      );
}

class DecimalFieldPage extends StatelessWidget {
  const DecimalFieldPage({super.key});

  @override
  Widget build(BuildContext context) => ExamplePage(
        title: 'D3DecimalField',
        summary:
            'A numeric input that limits the number of decimal places and can enforce a minimum and maximum. Use it for prices, weights and percentages.',
        examples: [
          exampleCard(
              'Prefix, suffix and limits',
              'decimal_field/variants.dart',
              const DecimalFieldVariantsExample()),
        ],
      );
}

class DropdownFieldPage extends StatelessWidget {
  const DropdownFieldPage({super.key});

  @override
  Widget build(BuildContext context) => ExamplePage(
        title: 'D3DropdownField',
        summary:
            'A field that picks one value from a list. A popup menu suits short lists; a bottom sheet with search suits long ones.',
        examples: [
          exampleCard('Popup menu', 'dropdown_field/variants.dart',
              const DropdownFieldVariantsExample()),
          exampleCard(
              'Bottom sheet with search',
              'dropdown_field/sheet_search.dart',
              const DropdownFieldSheetExample(),
              description:
                  'Use mode: D3DropdownMode.sheet for longer or API-driven lists.'),
        ],
      );
}

class CalendarPickerPage extends StatelessWidget {
  const CalendarPickerPage({super.key});

  @override
  Widget build(BuildContext context) => ExamplePage(
        title: 'showD3CalendarPicker',
        summary:
            'A themed calendar dialog that returns the chosen date. Use it on its own from a button, or through D3DateField.',
        examples: [
          exampleCard('Open from a button', 'calendar_picker/open_dialog.dart',
              const CalendarPickerExample(),
              description:
                  'The second button limits the range to today onward and marks three days.'),
        ],
      );
}

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) => ExamplePage(
        title: 'D3SearchBar and D3SearchAnchor',
        summary:
            'D3SearchBar is a plain search input. D3SearchAnchor is a bar that opens a full search view with results and optional filter chips. Use the anchor when results need their own screen.',
        examples: [
          exampleCard(
              'Search bar', 'search/search_bar.dart', const SearchBarExample(),
              description:
                  'A read-only bar works as a tap target that opens a search page.'),
          exampleCard('Search anchor with filters', 'search/search_anchor.dart',
              const SearchAnchorExample(),
              description:
                  'Tap the bar to open the search view. Use D3SearchAnchor.remote for results fetched from an API.'),
        ],
      );
}

class SchemaFormPage extends StatelessWidget {
  const SchemaFormPage({super.key});

  @override
  Widget build(BuildContext context) => ExamplePage(
        title: 'SchemaForm',
        summary:
            'Renders a whole form from a data description: each field has a type, label and validation rules. Use it when forms come from a server or share the same shape.',
        examples: [
          exampleCard('Form from a schema', 'schema_form/basic.dart',
              const SchemaFormExample(),
              description:
                  'validateFieldValue checks each field against its rules when Save is pressed.'),
        ],
      );
}
