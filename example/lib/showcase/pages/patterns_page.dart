import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

import '../../patterns/places_app.dart';
import '../example_card.dart';
import '../scope.dart';

/// Patterns: the components working together, as one small app. Also the page
/// the portfolio embeds (`?page=patterns&embed=1`).
class PatternsPage extends StatelessWidget {
  const PatternsPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (ShowcaseScope.of(context).embed) return const PlacesApp();

    final colors = context.d3Colors;
    final size = MediaQuery.sizeOf(context);
    // A phone-sized frame on wide screens; the whole width on a phone.
    final frameWidth = size.width < 460 ? size.width : 390.0;
    final frameHeight = (size.height - 300).clamp(520.0, 720.0);

    return ListView(
      padding: EdgeInsets.fromLTRB(
        size.width < 460 ? 0 : 20,
        24,
        size.width < 460 ? 0 : 20,
        40,
      ),
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width < 460 ? 20 : 0),
          child: const PageHeader(
            title: 'Places',
            summary:
                'A small app with made-up data, built only from d3_ui parts: '
                'search and filter chips, a list with a loading state, a details '
                'sheet, a form sheet, swipe to remove with a confirm dialog and '
                'an undo toast, a bottom nav bar and settings. Try it.',
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: Container(
            width: frameWidth,
            height: frameHeight,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(size.width < 460 ? 0 : 28),
              border: Border.all(color: colors.outline, width: 2),
            ),
            child: const PlacesApp(),
          ),
        ),
      ],
    );
  }
}
