import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

class ButtonLinksExample extends StatelessWidget {
  const ButtonLinksExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Already have an account? ',
          style: TextStyle(color: context.d3Colors.onSurfaceVariant),
        ),
        D3HyperlinkButton(label: 'Sign in', onPressed: () {}),
      ],
    );
  }
}
