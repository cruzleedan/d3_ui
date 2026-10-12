import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// Outlined and filled text fields with a hint, helper text and icons.
class TextFieldVariantsExample extends StatelessWidget {
  const TextFieldVariantsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      spacing: 16,
      children: [
        D3TextField(
          label: 'Full name',
          hintText: 'Ada Lovelace',
          prefixIcon: Icons.person_outline_rounded,
        ),
        D3TextField(
          label: 'Email',
          helperText: 'We only use this to send receipts.',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.mail_outline_rounded,
        ),
        D3TextField(
          label: 'Username',
          variant: D3InputVariant.filled,
          initialValue: 'ada_l',
        ),
        D3TextField(
          label: 'Bio',
          hintText: 'A few words about you',
          maxLines: 3,
          maxLength: 120,
        ),
      ],
    );
  }
}
