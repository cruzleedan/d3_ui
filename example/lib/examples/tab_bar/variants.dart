import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// A scrollable tab bar and a fixed one that fills the width.
class TabBarExample extends StatelessWidget {
  const TabBarExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        const D3TabBar(
          tabs: [
            Tab(text: 'Pizza'),
            Tab(text: 'Burgers'),
            Tab(text: 'Sushi'),
            Tab(text: 'Salads'),
            Tab(text: 'Desserts'),
            Tab(text: 'Drinks'),
          ],
        ),
        D3TabBar(
          isScrollable: false,
          onTap: (_) {},
          tabs: const [
            Tab(text: 'Menu'),
            Tab(text: 'Reviews'),
            Tab(text: 'Info'),
          ],
        ),
      ],
    );
  }
}
