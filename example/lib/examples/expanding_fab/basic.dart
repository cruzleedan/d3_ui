import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// A floating button that fans out a few actions. In an app it sits in the
/// Scaffold's floatingActionButton slot; here it is in the corner of a box.
class ExpandingFabExample extends StatelessWidget {
  const ExpandingFabExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: Align(
        alignment: Alignment.centerRight,
        child: D3ExpandingFab(
          actions: [
            D3FabAction(
              icon: Icons.edit_outlined,
              label: 'Write review',
              onPressed: () => D3Toast.info(context, title: 'Write review'),
            ),
            D3FabAction(
              icon: Icons.photo_camera_outlined,
              label: 'Add photo',
              onPressed: () => D3Toast.info(context, title: 'Add photo'),
            ),
          ],
        ),
      ),
    );
  }
}
