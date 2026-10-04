import 'package:material_ui/material_ui.dart';

// Layout only: the owning control supplies its gesture/semantics behavior.
class D3TapTarget extends StatelessWidget {
  const D3TapTarget({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: kMinInteractiveDimension,
        minHeight: kMinInteractiveDimension,
      ),
      child: Center(widthFactor: 1, heightFactor: 1, child: child),
    );
  }
}
