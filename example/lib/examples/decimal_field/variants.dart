import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// Decimal fields with a currency prefix, a unit suffix, limits and states.
class DecimalFieldVariantsExample extends StatelessWidget {
  const DecimalFieldVariantsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16,
      children: [
        D3DecimalField(
            label: 'Price',
            prefixText: '\$',
            hintText: '0.00',
            onChanged: (_) {}),
        D3DecimalField(
          label: 'Weight',
          suffixText: 'kg',
          decimalPlaces: 1,
          initialValue: 72.5,
          helperText: 'One decimal place.',
          onChanged: (_) {},
        ),
        D3DecimalField(
          label: 'Discount',
          suffixText: '%',
          minValue: 0,
          maxValue: 100,
          decimalPlaces: 0,
          helperText: 'Between 0 and 100.',
          onChanged: (_) {},
        ),
        const D3DecimalField(
          label: 'Amount',
          prefixText: '\$',
          initialValue: 12,
          errorText: 'Amount must be at least \$20',
        ),
        const D3DecimalField(
          label: 'Total',
          prefixText: '\$',
          initialValue: 149.99,
          isEnabled: false,
        ),
      ],
    );
  }
}
