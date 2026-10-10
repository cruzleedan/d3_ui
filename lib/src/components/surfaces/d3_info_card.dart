import 'package:material_ui/material_ui.dart';
import 'package:d3_ui/d3_ui.dart';

/// An outlined container for a few icon + text facts ([D3InfoRow]s), e.g. an
/// address, a cuisine and opening hours.
class D3InfoCard extends StatelessWidget {
  const D3InfoCard({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.all(D3Spacing.s8),
    this.spacing = D3Spacing.s8,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  /// Vertical gap between [children].
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        border: Border.all(color: context.d3Colors.outline),
        borderRadius: BorderRadius.circular(D3Radius.lg),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing,
        children: children,
      ),
    );
  }
}

/// One row of a [D3InfoCard]: a leading [icon] and an expanding [child].
class D3InfoRow extends StatelessWidget {
  const D3InfoRow({super.key, required this.icon, required this.child});

  /// Convenience for plain text content.
  D3InfoRow.text({super.key, required this.icon, required String text})
    : child = Text(text);

  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24),
        const SizedBox(width: D3Spacing.s4),
        Expanded(child: child),
      ],
    );
  }
}
