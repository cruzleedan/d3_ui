import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

class ButtonIconsExample extends StatelessWidget {
  const ButtonIconsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        D3Button(
          label: 'Share',
          leadingIcon: Icons.ios_share_rounded,
          onPressed: () {},
        ),
        D3Button(
          label: 'Export',
          trailingIcon: Icons.arrow_outward_rounded,
          variant: D3ButtonVariant.tonal,
          onPressed: () {},
        ),
        D3Button(
          label: 'Settings',
          leadingIcon: Icons.tune_rounded,
          variant: D3ButtonVariant.outlined,
          onPressed: () {},
        ),
        D3Button.icon(
            icon: Icons.add_rounded,
            semanticsLabel: 'Add item',
            onPressed: () {}),
        D3Button.icon(
          icon: Icons.bookmark_outline_rounded,
          semanticsLabel: 'Save bookmark',
          variant: D3ButtonVariant.tonal,
          onPressed: () {},
        ),
        D3Button.icon(
          icon: Icons.more_horiz_rounded,
          semanticsLabel: 'More options',
          variant: D3ButtonVariant.outlined,
          onPressed: () {},
        ),
      ],
    );
  }
}
