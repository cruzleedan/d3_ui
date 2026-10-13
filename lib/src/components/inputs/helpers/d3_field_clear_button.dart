import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// The round ✕ button in a field's suffix, with a 48 dp tap target.
///
/// Shared by the fields that offer a clear button. The owner decides when it
/// shows (see `D3ClearButtonMixin`) and what [onTap] does. Put it inside a
/// `TextFieldTapRegion` (the fields' suffix already is), so pressing it does not
/// unfocus the field first.
class D3FieldClearButton extends StatelessWidget {
  const D3FieldClearButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    return Semantics(
      button: true,
      label: 'Clear',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: kMinInteractiveDimension,
            minHeight: kMinInteractiveDimension,
          ),
          child: Center(
            widthFactor: 1,
            heightFactor: 1,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.onSurfaceVariant.withValues(alpha: 0.15),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.close_rounded,
                size: 12,
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
