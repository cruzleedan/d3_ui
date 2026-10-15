import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// Quantity steppers: default, with a maximum, compact, disabled, and a price.
class QuantityStepperExample extends StatefulWidget {
  const QuantityStepperExample({super.key});

  @override
  State<QuantityStepperExample> createState() => _QuantityStepperExampleState();
}

class _QuantityStepperExampleState extends State<QuantityStepperExample> {
  int _basic = 1;
  int _limited = 2;
  int _compact = 1;
  int _items = 3;

  @override
  Widget build(BuildContext context) {
    final total = (_items * 4.5).toStringAsFixed(2);
    return Wrap(
      spacing: 24,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        D3QuantityStepper(
          value: _basic,
          label: 'Quantity',
          onChanged: (v) => setState(() => _basic = v),
        ),
        D3QuantityStepper(
          value: _limited,
          min: 1,
          max: 5,
          label: 'Tickets, 1 to 5',
          onChanged: (v) => setState(() => _limited = v),
        ),
        D3QuantityStepper(
          value: _compact,
          compact: true,
          label: 'Compact quantity',
          onChanged: (v) => setState(() => _compact = v),
        ),
        const D3QuantityStepper(
          value: 2,
          label: 'Disabled quantity',
          onChanged: null,
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            D3QuantityStepper(
              value: _items,
              min: 1,
              label: 'Coffees',
              onChanged: (v) => setState(() => _items = v),
            ),
            const SizedBox(width: 12),
            Text('\$$total'),
          ],
        ),
      ],
    );
  }
}
