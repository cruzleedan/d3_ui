import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// An outlined card of icon + text facts about a place.
class InfoCardExample extends StatelessWidget {
  const InfoCardExample({super.key});

  @override
  Widget build(BuildContext context) {
    return D3InfoCard(
      children: [
        D3InfoRow.text(icon: Icons.place_outlined, text: '12 Harbour Road'),
        D3InfoRow.text(icon: Icons.restaurant_outlined, text: 'Seafood'),
        D3InfoRow.text(
            icon: Icons.schedule_outlined, text: 'Open 11:00 to 22:00'),
        const D3InfoRow(
          icon: Icons.star_outline_rounded,
          child: Text(
            'Rated 4.6 by 212 people',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
