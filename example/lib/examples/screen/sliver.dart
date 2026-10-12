import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// A D3Screen in sliver layout: a large title that collapses on scroll.
class ScreenSliverExample extends StatelessWidget {
  const ScreenSliverExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 360,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        border: Border.all(color: context.d3Colors.outline),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Navigator(
        onGenerateRoute: (_) => MaterialPageRoute<void>(
          builder: (_) => D3Screen(
            title: 'Contacts',
            subtitle: '24 people',
            layout: D3ScreenLayout.sliver,
            body: CustomScrollView(
              slivers: [
                SliverList.builder(
                  itemCount: 24,
                  itemBuilder: (context, i) => D3ListTile(
                    leading: const D3Avatar(name: 'Contact'),
                    title: 'Contact ${i + 1}',
                    subtitle: 'Scroll to collapse the title',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
