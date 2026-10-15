import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// Ratings: read-only with halves, interactive, with value text, sizes, disabled.
class RatingVariantsExample extends StatefulWidget {
  const RatingVariantsExample({super.key});

  @override
  State<RatingVariantsExample> createState() => _RatingVariantsExampleState();
}

class _RatingVariantsExampleState extends State<RatingVariantsExample> {
  double _input = 3;
  double _half = 3.5;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const D3Rating(
          value: 4.5,
          label: 'Average rating',
          showValue: true,
          compact: true,
          size: 20,
        ),
        const SizedBox(height: 16),
        D3Rating(
          value: _input,
          label: 'Rate this dish',
          onChanged: (v) => setState(() => _input = v),
        ),
        const SizedBox(height: 8),
        D3Rating(
          value: _half,
          label: 'Rate with halves',
          allowHalf: true,
          allowClear: true,
          showValue: true,
          onChanged: (v) => setState(() => _half = v),
        ),
        const SizedBox(height: 16),
        const D3Rating(value: 4, size: 16, compact: true, label: 'Small'),
        const SizedBox(height: 8),
        const D3Rating(value: 4, size: 40, label: 'Large'),
        const SizedBox(height: 16),
        D3Rating(
          value: 2,
          enabled: false,
          label: 'Disabled',
          onChanged: (_) {},
        ),
      ],
    );
  }
}
