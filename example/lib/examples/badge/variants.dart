import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// Count, dot and label badges in each colour.
class BadgeVariantsExample extends StatelessWidget {
  const BadgeVariantsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 16,
      runSpacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        D3Badge.count(3, semanticsLabel: '3 notifications'),
        D3Badge.count(42),
        D3Badge.count(150),
        D3Badge.count(7, variant: D3BadgeVariant.primary),
        D3Badge.count(0, showZero: true, variant: D3BadgeVariant.neutral),
        D3Badge.dot(semanticsLabel: 'Unread'),
        D3Badge.dot(variant: D3BadgeVariant.success, semanticsLabel: 'Online'),
        D3Badge.label('New'),
        D3Badge.label('Paid', variant: D3BadgeVariant.success),
        D3Badge.label('Due soon', variant: D3BadgeVariant.warning),
        D3Badge.label('Overdue', variant: D3BadgeVariant.error),
        D3Badge.label('Draft', variant: D3BadgeVariant.neutral),
      ],
    );
  }
}
