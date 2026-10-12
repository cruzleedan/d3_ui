import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

class ButtonSizesExample extends StatelessWidget {
  const ButtonSizesExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final size in D3ButtonSize.values)
          D3Button(
              label: size.name.toUpperCase(), size: size, onPressed: () {}),
      ],
    );
  }
}
