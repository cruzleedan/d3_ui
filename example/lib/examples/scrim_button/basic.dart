import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// A round icon button with a dark scrim, for use on top of photos.
class ScrimButtonExample extends StatelessWidget {
  const ScrimButtonExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        borderRadius: context.d3Shape.circularMd,
        gradient: const LinearGradient(
          colors: [Color(0xFFE9A15B), Color(0xFF5B7BE9)],
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          D3ScrimIconButton(
            icon: Icons.arrow_back_rounded,
            semanticsLabel: 'Back',
            onTap: () => D3Toast.info(context, title: 'Back'),
          ),
          const Spacer(),
          D3ScrimIconButton(
            icon: Icons.favorite_border_rounded,
            semanticsLabel: 'Save',
            onTap: () => D3Toast.info(context, title: 'Saved'),
          ),
          const SizedBox(width: 8),
          D3ScrimIconButton(
            icon: Icons.ios_share_rounded,
            semanticsLabel: 'Share',
            size: 44,
            onTap: () => D3Toast.info(context, title: 'Share'),
          ),
        ],
      ),
    );
  }
}
