import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

import '../../showcase/photos.dart';

/// Initials, a picture, shapes, sizes and presence indicators.
class AvatarVariantsExample extends StatelessWidget {
  const AvatarVariantsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const D3Avatar(name: 'Ada Lovelace'),
        D3Avatar(name: 'Grace Hopper', imageUrl: photoUrl('sunset')),
        const D3Avatar(name: 'Alan Turing', shape: D3AvatarShape.square),
        const D3Avatar(
            name: 'Edsger Dijkstra', indicator: D3AvatarIndicator.online),
        const D3Avatar(
            name: 'Barbara Liskov', indicator: D3AvatarIndicator.busy),
        const D3Avatar(
            name: 'Donald Knuth', indicator: D3AvatarIndicator.offline),
      ],
    );
  }
}
