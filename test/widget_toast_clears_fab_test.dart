import 'package:d3_ui/d3_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('the toast action is not covered by a FAB', (t) async {
    var undone = false;
    t.view.physicalSize = const Size(390, 844);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      MaterialApp(
        theme: D3AppTheme.light(),
        // Nested scaffolds, as in an app shell: the messenger belongs to the
        // outer one, so the inner scaffold's FAB is not moved by the toast.
        home: Scaffold(
          body: Builder(
            builder: (context) => Scaffold(
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () {},
                label: const Text('New'),
                icon: const Icon(Icons.add),
              ),
              body: Center(
                child: TextButton(
                  onPressed: () => D3Toast.undo(
                    context,
                    title: 'Deleted',
                    onUndo: () => undone = true,
                  ),
                  child: const Text('go'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await t.tap(find.text('go'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 400));
    final toast = t.getRect(find.text('Undo'));
    final fab = t.getRect(find.byType(FloatingActionButton));
    expect(toast.overlaps(fab), isFalse);
    await t.tap(find.text('Undo'));
    expect(undone, isTrue);
  });
}
