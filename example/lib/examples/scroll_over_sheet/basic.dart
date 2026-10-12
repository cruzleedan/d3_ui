import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

import '../../showcase/photos.dart';

/// A hero page that a sheet slides up over, with a top bar that fades in.
class ScrollOverSheetExample extends StatelessWidget {
  const ScrollOverSheetExample({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    return Container(
      height: 420,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        border: Border.all(color: colors.outline),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Navigator(
        onGenerateRoute: (_) => MaterialPageRoute<void>(
          builder: (_) => Scaffold(
            body: D3ScrollOverSheetScaffold(
              topBarContentHeight: 56,
              page: D3Image(
                url: photoUrl('sunset'),
                height: 220,
                width: double.infinity,
                borderRadius: BorderRadius.zero,
              ),
              topBar: (context, state) => Container(
                height: state.barHeight,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                color: colors.surface.withValues(alpha: state.progress),
                child: Opacity(
                  opacity: state.progress,
                  child: const Text(
                    'Harbour Fish',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              sheet: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    for (var i = 1; i <= 8; i++)
                      D3ListTile(
                        leading: const Icon(Icons.set_meal_outlined),
                        title: 'Menu item $i',
                        subtitle: 'Scroll to slide the sheet over the photo',
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
