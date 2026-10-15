import 'package:material_ui/material_ui.dart';
import 'package:d3_ui/d3_ui.dart';

/// The label above a d3 field. It wraps instead of overflowing when the text is
/// long or the system text size is large; the required asterisk stays with the
/// last word.
class D3FieldLabel extends StatelessWidget {
  const D3FieldLabel({
    super.key,
    required this.label,
    required this.isRequired,
    required this.fontSize,
  });

  final String label;
  final bool isRequired;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    return Text.rich(
      TextSpan(
        text: label,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: colors.onSurfaceVariant,
          letterSpacing: -0.1,
        ),
        children: [
          if (isRequired)
            TextSpan(
              text: ' *',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: colors.error,
              ),
            ),
        ],
      ),
    );
  }
}
