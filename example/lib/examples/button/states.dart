import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// Tap Save to see the loading, success and idle states.
class ButtonStatesExample extends StatefulWidget {
  const ButtonStatesExample({super.key});

  @override
  State<ButtonStatesExample> createState() => _ButtonStatesExampleState();
}

class _ButtonStatesExampleState extends State<ButtonStatesExample> {
  D3ButtonState _state = D3ButtonState.idle;

  Future<void> _save() async {
    setState(() => _state = D3ButtonState.loading);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _state = D3ButtonState.success);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _state = D3ButtonState.idle);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 320,
          child: D3Button(
            label: 'Save changes',
            leadingIcon: Icons.save_outlined,
            isFullWidth: true,
            size: D3ButtonSize.lg,
            buttonState: _state,
            loadingLabel: 'Saving…',
            onPressed: _save,
          ),
        ),
        const SizedBox(height: 14),
        const Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            D3Button(label: 'Disabled', onPressed: null),
            D3Button(
              label: 'Disabled tonal',
              variant: D3ButtonVariant.tonal,
              onPressed: null,
            ),
            D3Button(
              label: 'Disabled outlined',
              variant: D3ButtonVariant.outlined,
              onPressed: null,
            ),
          ],
        ),
      ],
    );
  }
}
