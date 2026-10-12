import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

class ButtonVariantsExample extends StatelessWidget {
  const ButtonVariantsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        D3Button(label: 'Continue', onPressed: () {}),
        D3Button(
          label: 'Edit profile',
          variant: D3ButtonVariant.tonal,
          onPressed: () {},
        ),
        D3Button(
          label: 'Cancel',
          variant: D3ButtonVariant.outlined,
          onPressed: () {},
        ),
        D3Button(
          label: 'Learn more',
          variant: D3ButtonVariant.ghost,
          onPressed: () {},
        ),
        D3Button(
          label: 'Delete',
          variant: D3ButtonVariant.danger,
          leadingIcon: Icons.delete_outline_rounded,
          onPressed: () {},
        ),
      ],
    );
  }
}
