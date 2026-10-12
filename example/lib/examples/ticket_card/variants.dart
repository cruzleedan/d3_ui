import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// Coupon-shaped cards with a notch and tear line, in a wrapping row.
class TicketCardExample extends StatelessWidget {
  const TicketCardExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        D3TicketCard(
          title: 'Latte and a slice of cake',
          primaryLine: 'P199 only',
          secondaryLine: 'Until 30 Nov',
          onTap: () {},
        ),
        D3TicketCard(
          title: '20% off dinner',
          leading: Icons.local_offer_outlined,
          primaryLine: 'Mon to Thu',
          secondaryLine: 'Dine in only',
          onTap: () {},
        ),
        D3TicketCard(
          title: 'Expires today',
          leading: Icons.warning_amber_rounded,
          leadingColor: context.d3Colors.error,
          primaryLine: 'Free dessert',
          width: 220,
        ),
      ],
    );
  }
}
