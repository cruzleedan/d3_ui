import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// A search bar that reports the query, and a read-only one that acts as a tap target.
class SearchBarExample extends StatefulWidget {
  const SearchBarExample({super.key});

  @override
  State<SearchBarExample> createState() => _SearchBarExampleState();
}

class _SearchBarExampleState extends State<SearchBarExample> {
  String _query = '';
  String _tapped = 'Not tapped yet';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        D3SearchBar(
          hint: 'Search recipes',
          padding: EdgeInsets.zero,
          onChanged: (q) => setState(() => _query = q),
        ),
        Text(_query.isEmpty ? 'Type to search' : 'Query: $_query'),
        const SizedBox(height: 8),
        D3SearchBar(
          hint: 'Tap to open a search page',
          readOnly: true,
          padding: EdgeInsets.zero,
          onTap: () => setState(() => _tapped = 'Tapped'),
        ),
        Text(_tapped),
      ],
    );
  }
}
