import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// Toggle the chips: a selected chip shows a check mark, so the state does not
/// rely on colour alone.
class ChipFiltersExample extends StatefulWidget {
  const ChipFiltersExample({super.key});

  @override
  State<ChipFiltersExample> createState() => _ChipFiltersExampleState();
}

class _ChipFiltersExampleState extends State<ChipFiltersExample> {
  final Set<String> _selected = {'Action', 'Romance'};

  @override
  Widget build(BuildContext context) {
    const genres = [
      'Action',
      'Romance',
      'Sci-fi',
      'Fantasy',
      'Horror',
      'Comedy'
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final genre in genres)
          D3Chip(
            label: genre,
            selected: _selected.contains(genre),
            onTap: () => setState(() {
              _selected.contains(genre)
                  ? _selected.remove(genre)
                  : _selected.add(genre);
            }),
          ),
      ],
    );
  }
}
