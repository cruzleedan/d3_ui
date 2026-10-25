import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// Error, success, required, read-only, disabled and live validation states.
class TextFieldStatesExample extends StatelessWidget {
  const TextFieldStatesExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16,
      children: [
        const D3TextField(
          label: 'Email',
          initialValue: 'ada@',
          errorText: 'Enter a valid email address',
          prefixIcon: Icons.mail_outline_rounded,
        ),
        const D3TextField(
          label: 'Username',
          initialValue: 'ada_l',
          successText: 'Username is available',
        ),
        const D3TextField(
          label: 'Delivery note',
          initialValue: 'Leave by the gate',
          warningText: 'This location is exposed to weather.',
        ),
        const D3TextField(label: 'Company', isRequired: true),
        const D3TextField(
          label: 'Member since',
          initialValue: 'March 2024',
          isReadOnly: true,
        ),
        const D3TextField(
          label: 'Account id',
          initialValue: 'acc_8d2f',
          isEnabled: false,
        ),
        D3TextField(
          label: 'Password',
          helperText: 'Type fewer than 8 characters, then leave the field.',
          obscureText: true,
          validator: (v) =>
              (v ?? '').length < 8 ? 'Use at least 8 characters' : null,
        ),
      ],
    );
  }
}
