import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:d3_ui/d3_ui.dart';

// ─────────────────────────────────────────────────────────────────────────────
// D3HyperlinkButton
// ─────────────────────────────────────────────────────────────────────────────

/// An inline, underlined-text tap target — for a link inside a sentence or
/// caption, distinct from [D3Button]'s box-shaped variants.
///
/// ```dart
/// Row(
///   children: [
///     Text('Already have an account? '),
///     D3HyperlinkButton(label: 'Sign in', onPressed: _goToSignIn),
///   ],
/// )
/// ```
class D3HyperlinkButton extends StatelessWidget {
  const D3HyperlinkButton({
    super.key,
    required this.label,
    this.onPressed,
    this.fontSize = D3TypeScale.bodyMdSize,
    this.semanticsLabel,
  });

  final String label;
  final VoidCallback? onPressed;

  /// Overrides the default `D3TypeScale.bodyMdSize` to match surrounding text.
  final double fontSize;

  final String? semanticsLabel;

  bool get _isInteractive => onPressed != null;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    final color = _isInteractive ? colors.primary : colors.onSurfaceVariant;

    return Semantics(
      button: true,
      enabled: _isInteractive,
      label: semanticsLabel ?? label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _isInteractive
            ? () {
                HapticFeedback.selectionClick();
                onPressed!();
              }
            : null,
        child: Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: color,
            decoration: TextDecoration.underline,
            decorationColor: color,
          ),
        ),
      ),
    );
  }
}
