import 'package:material_ui/material_ui.dart';

import '../inputs/helpers/d3_tap_target.dart';

/// A round icon button on a translucent dark scrim, legible over both a photo
/// and a plain surface — for controls that float above scrolling content
/// (back, favorite, share).
///
/// [semanticsLabel] is required: the button has no visible text.
class D3ScrimIconButton extends StatelessWidget {
  const D3ScrimIconButton({
    super.key,
    required this.icon,
    required this.semanticsLabel,
    required this.onTap,
    this.iconColor = Colors.white,
    this.scrimColor,
    this.size = 36,
  });

  final IconData icon;
  final String semanticsLabel;
  final VoidCallback onTap;
  final Color iconColor;

  /// The circle behind the icon. Defaults to black at 35% — right over a
  /// photo, but a muddy grey on a light surface, where callers should pass a
  /// subtle tint (and a dark [iconColor]).
  final Color? scrimColor;

  /// Diameter of the scrim circle.
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      button: true,
      // The circle is its own size (36 by default); the tap region is 48 x 48.
      child: D3PaddedTapTarget(
        child: Material(
          color: scrimColor ?? Colors.black.withValues(alpha: 0.35),
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            customBorder: const CircleBorder(),
            splashColor: Colors.white.withValues(alpha: 0.24),
            highlightColor: Colors.white.withValues(alpha: 0.12),
            onTap: onTap,
            child: SizedBox(
              width: size,
              height: size,
              child: Center(
                child: Icon(icon, size: size * 0.55, color: iconColor),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
