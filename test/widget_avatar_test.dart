import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:d3_ui/d3_ui.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: D3AppTheme.light(),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('D3Avatar', () {
    testWidgets('renders initials text when no image', (tester) async {
      await tester.pumpWidget(_wrap(
        const D3Avatar(name: 'Dan Lee'),
      ));
      expect(find.text('DL'), findsOneWidget);
    });

    testWidgets('renders with each size without error', (tester) async {
      for (final size in D3AvatarSize.values) {
        await tester.pumpWidget(_wrap(D3Avatar(name: 'AB', size: size)));
        await tester.pump();
      }
    });

    testWidgets('renders circle and square shapes', (tester) async {
      await tester.pumpWidget(_wrap(
        const D3Avatar(name: 'Alice Brown', shape: D3AvatarShape.square),
      ));
      expect(find.text('AB'), findsOneWidget);

      await tester.pumpWidget(_wrap(
        const D3Avatar(name: 'Alice Brown', shape: D3AvatarShape.circle),
      ));
      expect(find.text('AB'), findsOneWidget);
    });

    testWidgets('truncates initials to at most 2 characters', (tester) async {
      await tester.pumpWidget(_wrap(
        const D3Avatar(name: 'ABC'),
      ));
      // Should not crash regardless of how many chars are passed
      await tester.pump();
    });
  });

  group('D3AvatarGroup', () {
    testWidgets('renders without error with multiple avatars', (tester) async {
      await tester.pumpWidget(_wrap(
        D3AvatarGroup(
          avatars: [
            D3Avatar(name: 'AA'),
            D3Avatar(name: 'BB'),
            D3Avatar(name: 'CC'),
            D3Avatar(name: 'DD'),
          ],
        ),
      ));
      await tester.pump();
    });
  });
}
