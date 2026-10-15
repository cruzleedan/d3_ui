import 'package:material_ui/material_ui.dart';

import '../../examples/otp_field/basic.dart';
import '../../examples/rating/variants.dart';
import '../example_card.dart';
import 'page_helpers.dart';

class RatingPage extends StatelessWidget {
  const RatingPage({super.key});

  @override
  Widget build(BuildContext context) => ExamplePage(
        title: 'D3Rating',
        summary: 'Stars for showing or choosing a rating. Each star has a 48dp '
            'touch area; tap or drag to set, arrow keys also work.',
        examples: [
          exampleCard(
              'Variants', 'rating/variants.dart', const RatingVariantsExample(),
              description: 'Read-only, interactive, halves, sizes, disabled.'),
        ],
      );
}

class OtpFieldPage extends StatelessWidget {
  const OtpFieldPage({super.key});

  @override
  Widget build(BuildContext context) => ExamplePage(
        title: 'D3OtpField',
        summary: 'A one-time-code field of separate cells over one real text '
            'field, so paste and SMS autofill work. Shrinks to fit narrow '
            'screens.',
        examples: [
          exampleCard(
              'Basic', 'otp_field/basic.dart', const OtpFieldBasicExample(),
              description: 'Enter 000000 to see the error state.'),
        ],
      );
}
