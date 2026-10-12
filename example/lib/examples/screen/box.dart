import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// A D3Screen with a fixed toolbar, a title, trailing actions and a body.
class ScreenBoxExample extends StatelessWidget {
  const ScreenBoxExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 360,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        border: Border.all(color: context.d3Colors.outline),
        borderRadius: BorderRadius.circular(12),
      ),
      // A nested Navigator gives the screen its own route, so it behaves
      // like a full page without taking over the showcase.
      child: Navigator(
        onGenerateRoute: (_) => MaterialPageRoute<void>(
          builder: (_) => D3Screen(
            title: 'Profile',
            actions: [
              D3ScreenAction.icon(
                Icons.edit_outlined,
                onPressed: () {},
                semanticsLabel: 'Edit',
              ),
              D3ScreenAction.icon(
                Icons.more_vert_rounded,
                onPressed: () {},
                semanticsLabel: 'More',
              ),
            ],
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                D3InfoCard(
                  children: [
                    D3InfoRow.text(
                        icon: Icons.person_outline, text: 'Ana Reyes'),
                    D3InfoRow.text(
                      icon: Icons.mail_outline,
                      text: 'ana@example.com',
                    ),
                    D3InfoRow.text(
                      icon: Icons.place_outlined,
                      text: 'Cebu City',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
