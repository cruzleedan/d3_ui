import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// Tooltips on icon buttons and text, and an info tip beside a label.
class TooltipBasicExample extends StatelessWidget {
  const TooltipBasicExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            D3Tooltip(
              message: 'Add to favourites',
              child: IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () {},
              ),
            ),
            D3Tooltip(
              message: 'Share this item with someone else',
              child: IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () {},
              ),
            ),
          ],
        ),
        const D3Tooltip(
          message: 'Hover, focus or long-press the text to read this.',
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('Long-press this text'),
          ),
        ),
        const Row(
          children: [
            Text('Display name'),
            D3InfoTip(
              title: 'Display name',
              message: 'Shown to other people. You can change it any time.',
            ),
          ],
        ),
      ],
    );
  }
}
