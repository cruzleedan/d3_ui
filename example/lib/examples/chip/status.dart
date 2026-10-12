import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// Status badges drawn from the theme's status colours (`context.d3Status`):
/// switch the brand and they change with it.
class ChipStatusExample extends StatelessWidget {
  const ChipStatusExample({super.key});

  @override
  Widget build(BuildContext context) {
    final status = context.d3Status;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _badge('Published', status.success),
        _badge('Paused', status.warning),
        _badge('Cancelled', status.destructive),
        _badge('Draft', status.neutral),
      ],
    );
  }

  Widget _badge(String label, D3StatusColor color) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.tint,
        borderRadius: D3Radius.circularFull,
        border: Border.all(color: color.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: color.text,
          ),
        ),
      ),
    );
  }
}
