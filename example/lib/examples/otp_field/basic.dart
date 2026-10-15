import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// A 6-digit code field that echoes the entry; 000000 shows an error.
class OtpFieldBasicExample extends StatefulWidget {
  const OtpFieldBasicExample({super.key});

  @override
  State<OtpFieldBasicExample> createState() => _OtpFieldBasicExampleState();
}

class _OtpFieldBasicExampleState extends State<OtpFieldBasicExample> {
  String _entered = '';
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        D3OtpField(
          errorText: _error,
          onChanged: (v) => setState(() {
            _entered = v;
            _error = null;
          }),
          onCompleted: (v) => setState(() {
            _error = v == '000000' ? 'That code is not right' : null;
          }),
        ),
        const SizedBox(height: 16),
        Text('Entered: ${_entered.isEmpty ? '(nothing)' : _entered}'),
      ],
    );
  }
}
