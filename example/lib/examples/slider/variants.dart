import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// Sliders: plain, with steps and a value label, and disabled.
class SliderVariantsExample extends StatefulWidget {
  const SliderVariantsExample({super.key});

  @override
  State<SliderVariantsExample> createState() => _SliderVariantsExampleState();
}

class _SliderVariantsExampleState extends State<SliderVariantsExample> {
  double _plain = 0.4;
  double _steps = 3;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        D3Slider(
          value: _plain,
          label: 'Brightness',
          semanticsLabel: 'Brightness',
          onChanged: (v) => setState(() => _plain = v),
        ),
        const SizedBox(height: 16),
        D3Slider(
          value: _steps,
          min: 1,
          max: 5,
          divisions: 4,
          label: 'Text size',
          showValue: true,
          valueFormatter: (v) => 'Size ${v.round()}',
          onChanged: (v) => setState(() => _steps = v),
        ),
        const SizedBox(height: 16),
        D3Slider(
          value: 0.6,
          label: 'Disabled',
          showValue: true,
          valueFormatter: (v) => '${(v * 100).round()}%',
          enabled: false,
          onChanged: (_) {},
        ),
      ],
    );
  }
}
