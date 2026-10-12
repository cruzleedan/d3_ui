import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// A long list in a bottom sheet with a search box.
class DropdownFieldSheetExample extends StatelessWidget {
  const DropdownFieldSheetExample({super.key});

  static const _countries = [
    'Argentina',
    'Australia',
    'Brazil',
    'Canada',
    'Chile',
    'Denmark',
    'Egypt',
    'Finland',
    'Germany',
    'Ghana',
    'India',
    'Japan',
    'Kenya',
    'Mexico',
    'Norway',
    'Peru',
    'Philippines',
    'Portugal',
    'Spain',
    'Vietnam',
  ];

  @override
  Widget build(BuildContext context) {
    return D3DropdownField<String, String>(
      label: 'Country',
      items: _countries,
      itemLabel: (c) => c,
      itemValue: (c) => c,
      mode: D3DropdownMode.sheet,
      searchable: true,
      searchHint: 'Search countries',
      hintText: 'Select a country',
      onChanged: (_) {},
    );
  }
}
