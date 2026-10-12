import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// Every size, and a group that collapses into a "+N" count.
class AvatarSizesExample extends StatelessWidget {
  const AvatarSizesExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final size in D3AvatarSize.values)
              D3Avatar(name: 'Ada Lovelace', size: size),
          ],
        ),
        const SizedBox(height: 20),
        D3AvatarGroup(
          max: 4,
          avatars: const [
            D3Avatar(name: 'Ada Lovelace'),
            D3Avatar(name: 'Grace Hopper'),
            D3Avatar(name: 'Alan Turing'),
            D3Avatar(name: 'Barbara Liskov'),
            D3Avatar(name: 'Donald Knuth'),
            D3Avatar(name: 'Edsger Dijkstra'),
          ],
        ),
      ],
    );
  }
}
