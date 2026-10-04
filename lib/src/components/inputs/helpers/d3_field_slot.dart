import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

// Shared custom-slot precedence and styling. Field owners place the result
// inside their prefix padding or ordered suffix row.
Widget? buildD3FieldSlot({
  required D3InputTokens tokens,
  required D3ColorTokens colors,
  Widget? child,
  IconData? icon,
  String? text,
}) {
  if (child != null) return child;
  if (icon != null) {
    return Icon(icon, size: tokens.iconSize, color: colors.onSurfaceVariant);
  }
  if (text != null) {
    return Text(
      text,
      style: TextStyle(
        fontSize: tokens.textSize,
        fontWeight: FontWeight.w600,
        color: colors.onSurfaceVariant,
      ),
    );
  }
  return null;
}
