import 'package:d3_ui/d3_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('leading icon takes a colour and a spoken label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: D3AppTheme.light(),
        home: const Scaffold(
          body: D3TicketCard(
            title: 'Free Gyoza',
            leading: Icons.warning_amber_rounded,
            leadingColor: Color(0xFFF59E0B),
            leadingSemanticsLabel: 'Contains a filtered allergen',
          ),
        ),
      ),
    );
    final icon = tester.widget<Icon>(find.byIcon(Icons.warning_amber_rounded));
    expect(icon.color, const Color(0xFFF59E0B));
    expect(icon.semanticLabel, 'Contains a filtered allergen');
  });
}
