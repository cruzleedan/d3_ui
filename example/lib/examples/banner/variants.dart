import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// The four banner tones, one with an action and one you can dismiss.
class BannerVariantsExample extends StatefulWidget {
  const BannerVariantsExample({super.key});

  @override
  State<BannerVariantsExample> createState() => _BannerVariantsExampleState();
}

class _BannerVariantsExampleState extends State<BannerVariantsExample> {
  bool _showTip = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const D3Banner(message: 'Your trial ends in 3 days.'),
        const SizedBox(height: 10),
        const D3Banner(
          variant: D3BannerVariant.success,
          message: 'Backup finished. Everything is saved.',
        ),
        const SizedBox(height: 10),
        D3Banner(
          variant: D3BannerVariant.warning,
          message: 'You are offline. Changes will sync later.',
          action: D3BannerAction(label: 'Retry', onPressed: () {}),
        ),
        const SizedBox(height: 10),
        const D3Banner(
          variant: D3BannerVariant.error,
          message: 'Payment failed. Update your card to keep access.',
        ),
        const SizedBox(height: 10),
        if (_showTip)
          D3Banner(
            message: 'Tip: swipe a row to delete it.',
            onDismiss: () => setState(() => _showTip = false),
          )
        else
          Align(
            alignment: Alignment.centerLeft,
            child: D3Button(
              label: 'Bring the tip back',
              variant: D3ButtonVariant.outlined,
              onPressed: () => setState(() => _showTip = true),
            ),
          ),
      ],
    );
  }
}
