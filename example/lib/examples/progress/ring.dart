import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// Circular progress: determinate with centre text, indeterminate, sizes.
class ProgressRingExample extends StatelessWidget {
  const ProgressRingExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 24,
      runSpacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        D3ProgressRing(value: 0.65, size: 80, thickness: 8, showValue: true),
        D3ProgressRing(
          value: 0.4,
          size: 72,
          variant: D3ProgressVariant.success,
          child: Icon(Icons.download_rounded),
        ),
        D3ProgressRing(value: null, label: 'Loading'),
        D3ProgressRing(value: null, size: 24, thickness: 3),
        D3ProgressRing(value: 0.9, size: 32, thickness: 4),
      ],
    );
  }
}
