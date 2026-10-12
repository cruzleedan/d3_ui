import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// Elevated and tonal cards with a title, text, a footer and an accent bar.
class CardVariantsExample extends StatelessWidget {
  const CardVariantsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 12,
      children: [
        const D3Card(
          eyebrow: 'Guide',
          title: 'Getting started with tokens',
          subtitle: 'Design, 5 min read',
          content: Text(
            'How colour, spacing and radius tokens drive every component.',
          ),
        ),
        const D3Card(
          variant: D3CardVariant.tonal,
          eyebrow: 'Featured',
          title: 'Flat and minimal',
          content: Text('The tonal variant uses the primary container colour.'),
        ),
        D3Card(
          accentColor: context.d3Colors.primary,
          title: 'With an accent bar and footer',
          content: const Text('Tap the card or its footer action.'),
          footerAction: D3Button(
            label: 'Open',
            variant: D3ButtonVariant.ghost,
            onPressed: () {},
          ),
          footerTrailing: const Icon(Icons.chevron_right_rounded),
          onTap: () {},
        ),
      ],
    );
  }
}
