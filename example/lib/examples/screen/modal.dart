import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// A D3Screen styled as a modal: Cancel on the left, Save on the right.
class ScreenModalExample extends StatelessWidget {
  const ScreenModalExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        border: Border.all(color: context.d3Colors.outline),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Navigator(
        onGenerateRoute: (_) => MaterialPageRoute<void>(
          builder: (_) => D3Screen(
            title: 'Edit profile',
            leading: D3ScreenLeading.cancel,
            actions: [D3ScreenAction.text('Save', onPressed: () {})],
            body: const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Form fields go here.'),
            ),
          ),
        ),
      ),
    );
  }
}
