import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// A sheet you can drag between a half and a near full-screen height.
class BottomSheetSnapPointsExample extends StatelessWidget {
  const BottomSheetSnapPointsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return D3Button(
      label: 'Open resizable sheet',
      variant: D3ButtonVariant.outlined,
      onPressed: () => D3BottomSheet.show<void>(
        context,
        title: 'Filters',
        snapPoints: const [D3SnapPoint.half, D3SnapPoint.expanded],
        headerAction: Builder(
          builder: (sheetContext) => D3HyperlinkButton(
            label: 'Reset',
            onPressed: () => D3BottomSheet.pop(sheetContext),
          ),
        ),
        child: ListView.builder(
          itemCount: 20,
          itemBuilder: (_, i) =>
              ListTile(title: Text('Filter option ${i + 1}')),
        ),
      ),
    );
  }
}
