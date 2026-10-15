import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// A banner with a title, a compact one, and a custom icon.
class BannerLayoutsExample extends StatelessWidget {
  const BannerLayoutsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        D3Banner(
          variant: D3BannerVariant.warning,
          title: 'Storage almost full',
          message: 'Free up space or upgrade your plan to keep uploading.',
        ),
        SizedBox(height: 10),
        D3Banner(
          compact: true,
          variant: D3BannerVariant.success,
          message: 'Saved just now.',
        ),
        SizedBox(height: 10),
        D3Banner(
          icon: Icons.wifi_off_rounded,
          title: 'No connection',
          message: 'Showing the last downloaded results.',
        ),
      ],
    );
  }
}
