import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// Linear progress: determinate with a Start button, indeterminate, variants.
class ProgressBarExample extends StatefulWidget {
  const ProgressBarExample({super.key});

  @override
  State<ProgressBarExample> createState() => _ProgressBarExampleState();
}

class _ProgressBarExampleState extends State<ProgressBarExample>
    with SingleTickerProviderStateMixin {
  late final AnimationController _run = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  );

  @override
  void dispose() {
    _run.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedBuilder(
          animation: _run,
          builder: (context, _) => D3ProgressBar(
            value: _run.value,
            label: 'Uploading photos',
            showValue: true,
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: D3Button(
            label: 'Start',
            size: D3ButtonSize.sm,
            onPressed: () => _run.forward(from: 0),
          ),
        ),
        const SizedBox(height: 24),
        const D3ProgressBar(value: null, label: 'Loading'),
        const SizedBox(height: 24),
        const D3ProgressBar(value: 0.8, variant: D3ProgressVariant.success),
        const SizedBox(height: 12),
        const D3ProgressBar(value: 0.5, variant: D3ProgressVariant.warning),
        const SizedBox(height: 12),
        const D3ProgressBar(
          value: 0.25,
          variant: D3ProgressVariant.error,
          label: 'Storage almost full',
          showValue: true,
        ),
      ],
    );
  }
}
