import 'package:material_ui/material_ui.dart';

import '../../examples/progress/bar.dart';
import '../../examples/progress/ring.dart';
import '../../examples/quantity_stepper/variants.dart';
import '../../examples/slider/variants.dart';
import '../example_card.dart';
import 'page_helpers.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) => ExamplePage(
        title: 'D3ProgressBar and D3ProgressRing',
        summary:
            'Show how far a task has got. Pass a value from 0 to 1, or null '
            'when the amount is unknown. Animations stop under reduced motion.',
        examples: [
          exampleCard('Bar', 'progress/bar.dart', const ProgressBarExample(),
              description: 'Press Start to run the determinate bar.'),
          exampleCard('Ring', 'progress/ring.dart', const ProgressRingExample(),
              description: 'Put text or an icon in the centre.'),
        ],
      );
}

class SliderPage extends StatelessWidget {
  const SliderPage({super.key});

  @override
  Widget build(BuildContext context) => ExamplePage(
        title: 'D3Slider',
        summary:
            'Pick a value from a range by dragging. The whole 48dp row is the '
            'drag area. Add divisions for steps with a haptic tick.',
        examples: [
          exampleCard(
              'Variants', 'slider/variants.dart', const SliderVariantsExample(),
              description:
                  'Drag to see the value bubble. Arrow keys also work.'),
        ],
      );
}

class QuantityStepperPage extends StatelessWidget {
  const QuantityStepperPage({super.key});

  @override
  Widget build(BuildContext context) => ExamplePage(
        title: 'D3QuantityStepper',
        summary:
            'Minus, value and plus for choosing a small whole number. Press '
            'and hold a button to repeat. Buttons dim at the limits.',
        examples: [
          exampleCard('Variants', 'quantity_stepper/variants.dart',
              const QuantityStepperExample(),
              description: 'The last one updates a price as you change it.'),
        ],
      );
}
