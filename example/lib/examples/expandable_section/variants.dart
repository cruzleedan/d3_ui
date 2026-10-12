import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// A titled block that opens and closes.
class ExpandableSectionExample extends StatelessWidget {
  const ExpandableSectionExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        D3ExpandableSection(
          title: 'Opening hours',
          subtitle: 'Open now',
          leading: Icon(Icons.schedule_outlined),
          initiallyExpanded: true,
          child: Text('Mon to Fri 9:00 to 21:00\nSat and Sun 10:00 to 22:00'),
        ),
        SizedBox(height: 12),
        D3ExpandableSection(
          title: 'Allergens',
          leading: Icon(Icons.warning_amber_rounded),
          child: Text('Contains gluten, milk and eggs. May contain nuts.'),
        ),
      ],
    );
  }
}
