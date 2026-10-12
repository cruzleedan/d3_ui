import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// A row that stays pinned at the top while the list scrolls beneath it.
class StickyHeaderExample extends StatelessWidget {
  const StickyHeaderExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 360,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        border: Border.all(color: context.d3Colors.outline),
        borderRadius: BorderRadius.circular(12),
      ),
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Scroll down: the Add row stays in place.'),
            ),
          ),
          D3StickyHeader(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: D3Button(
                  label: 'Add visit',
                  variant: D3ButtonVariant.tonal,
                  leadingIcon: Icons.add,
                  onPressed: () {},
                ),
              ),
            ),
          ),
          SliverList.builder(
            itemCount: 20,
            itemBuilder: (context, i) => D3ListTile(title: 'Visit ${i + 1}'),
          ),
        ],
      ),
    );
  }
}
