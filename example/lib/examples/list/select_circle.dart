import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// The selection circle on its own, for rows that have no leading widget to
/// swap it into. Tap one to toggle it.
class SelectCircleExample extends StatefulWidget {
  const SelectCircleExample({super.key});

  @override
  State<SelectCircleExample> createState() => _SelectCircleExampleState();
}

class _SelectCircleExampleState extends State<SelectCircleExample> {
  final _on = <int>{1};

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 16,
      children: [
        for (final i in [0, 1, 2])
          GestureDetector(
            onTap: () =>
                setState(() => _on.contains(i) ? _on.remove(i) : _on.add(i)),
            child: D3SelectCircle(
                filled: _on.contains(i), colors: context.d3Colors),
          ),
        D3SelectCircle(filled: true, colors: context.d3Colors, size: 40),
      ],
    );
  }
}
