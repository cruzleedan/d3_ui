import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

import '../../patterns/places_app.dart';
import '../example_card.dart';
import '../scope.dart';

/// The sizes the Places app can be shown at. The app follows the width it is
/// given, so each one picks a different Material layout.
enum _Frame {
  phone('Phone', Icons.smartphone_outlined, 390, 844),
  tablet('Tablet', Icons.tablet_mac_outlined, 700, 940),
  desktop('Desktop', Icons.desktop_windows_outlined, 1100, 720);

  const _Frame(this.label, this.icon, this.width, this.height);
  final String label;
  final IconData icon;

  /// A typical device's size in logical pixels: a 19.5:9 phone, a portrait
  /// tablet and a landscape window. The page scrolls if it is taller than the
  /// window.
  final double width;
  final double height;
}

/// Patterns: the components working together, as one small app that adapts to
/// the window (compact, medium and expanded layouts). Also the page the
/// portfolio embeds (`?page=patterns&embed=1`), where it fills the frame.
class PatternsPage extends StatefulWidget {
  const PatternsPage({super.key});

  @override
  State<PatternsPage> createState() => _PatternsPageState();
}

class _PatternsPageState extends State<PatternsPage> {
  _Frame _frame = _Frame.phone;

  @override
  Widget build(BuildContext context) {
    if (ShowcaseScope.of(context).embed) return const PlacesApp();

    final colors = context.d3Colors;
    final size = MediaQuery.sizeOf(context);
    final onPhone = size.width < 460;
    // The frame is as wide as chosen, or as wide as the page allows.
    final available = size.width - (size.width >= 900 ? 292 : 0) - 40;
    final frameWidth = onPhone
        ? size.width
        : _frame.width.clamp(300.0, available < 300 ? 300.0 : available);
    // The device's own proportions; on a phone, whatever is left of the screen.
    final frameHeight =
        onPhone ? (size.height - 330).clamp(520.0, 844.0) : _frame.height;
    final shown = D3WindowSizeClass.fromWidth(frameWidth);
    final bezel = _frame == _Frame.phone ? 26.0 : 10.0;

    return ListView(
      padding: EdgeInsets.fromLTRB(onPhone ? 0 : 20, 24, onPhone ? 0 : 20, 40),
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: onPhone ? 20 : 0),
          child: const PageHeader(
            title: 'Places',
            summary:
                'A small app with made-up data, built only from d3_ui parts, and '
                'laid out the way Material asks for each window size: a bottom bar '
                'on a phone, a rail on a tablet, and a rail with list and detail '
                'side by side on a desktop. It has a search anchor with filters, a '
                'loading state, a details sheet, a form sheet, swipe to remove '
                'with a confirm dialog and an undo toast, and settings.',
          ),
        ),
        const SizedBox(height: 16),
        if (!onPhone)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Wrap(
              spacing: 16,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Wide enough for the three labels: left to itself the control
                // takes only what is left of the row.
                SizedBox(
                  width: 360,
                  child: D3SegmentedControl<_Frame>(
                    expand: true,
                    segments: [
                      for (final f in _Frame.values)
                        D3Segment(value: f, label: f.label, icon: f.icon),
                    ],
                    selected: _frame,
                    onChanged: (f) => setState(() => _frame = f),
                  ),
                ),
                Text(
                  '${shown.name} layout, ${frameWidth.round()} px wide',
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        Center(
          // A bezel around the app, so its edge reads against the page.
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            width: frameWidth + (onPhone ? 0 : 20),
            padding: EdgeInsets.all(onPhone ? 0 : 10),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(onPhone ? 0 : bezel + 10),
              border: Border.all(color: colors.outline.withValues(alpha: 0.5)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(onPhone ? 0 : bezel),
              child: SizedBox(
                height: frameHeight,
                child:
                    ColoredBox(color: colors.surface, child: const PlacesApp()),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
