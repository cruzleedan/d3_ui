import 'package:d3_ui/d3_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Widget _wrap(Widget child, {D3InputTokens? tokens, double width = 300}) =>
    MaterialApp(
      theme: D3AppTheme.light(inputTokens: tokens),
      home: Scaffold(
        body: Center(
          child: SizedBox(width: width, child: child),
        ),
      ),
    );

void main() {
  for (final decimal in [false, true]) {
    Widget field({
      Widget? prefix,
      Widget? suffix,
      IconData? prefixIcon,
      IconData? suffixIcon,
      String? prefixText,
      String? suffixText,
    }) => decimal
        ? D3DecimalField(
            label: 'Value',
            prefixWidget: prefix,
            suffixWidget: suffix,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            prefixText: prefixText,
            suffixText: suffixText,
          )
        : D3TextField(
            label: 'Value',
            prefixWidget: prefix,
            suffixWidget: suffix,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            prefixText: prefixText,
            suffixText: suffixText,
          );

    testWidgets(
      '${decimal ? 'decimal' : 'text'} slots share precedence and theme',
      (tester) async {
        final tokens = D3InputTokens.defaults.copyWith(
          iconSize: 24,
          textSize: 17,
          paddingH: 20,
        );
        await tester.pumpWidget(
          _wrap(
            field(
              prefix: const Text('P'),
              suffix: const Text('S'),
              prefixIcon: Icons.add,
              suffixIcon: Icons.remove,
              prefixText: 'USD',
              suffixText: 'kg',
            ),
            tokens: tokens,
          ),
        );
        expect(find.text('P'), findsOneWidget);
        expect(find.text('S'), findsOneWidget);
        expect(find.byIcon(Icons.add), findsNothing);
        expect(find.byIcon(Icons.remove), findsNothing);
        expect(find.text('USD'), findsNothing);
        expect(find.text('kg'), findsNothing);

        await tester.pumpWidget(
          _wrap(
            field(
              prefixIcon: Icons.add,
              suffixIcon: Icons.remove,
              prefixText: 'USD',
              suffixText: 'kg',
            ),
            tokens: tokens,
          ),
        );
        for (final icon in [Icons.add, Icons.remove]) {
          final rendered = tester.widget<Icon>(find.byIcon(icon));
          expect(rendered.size, 24);
          expect(
            rendered.color,
            tester.element(find.byIcon(icon)).d3Colors.onSurfaceVariant,
          );
        }
        expect(find.text('USD'), findsNothing);
        expect(find.text('kg'), findsNothing);
        expect(
          tester.getTopLeft(find.byIcon(Icons.add)).dx,
          tester.getTopLeft(find.byType(AnimatedContainer).first).dx + 21,
        );

        await tester.pumpWidget(
          _wrap(
            field(prefixText: 'USD', suffixText: 'kg'),
            tokens: tokens,
          ),
        );
        for (final text in ['USD', 'kg']) {
          final style = tester.widget<Text>(find.text(text)).style!;
          expect(style.fontSize, 17);
          expect(style.fontWeight, FontWeight.w600);
        }
        await tester.pumpWidget(_wrap(field(), tokens: tokens));
        expect(find.text('USD'), findsNothing);
        expect(find.text('kg'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'text custom suffix stays after clear, validation and password controls',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          const D3TextField(
            label: 'Password',
            obscureText: true,
            errorText: 'Invalid',
            prefixText: 'ID',
            suffixIcon: Icons.help_outline,
          ),
          width: 360,
        ),
      );
      await tester.enterText(find.byType(TextField), 'secret');
      await tester.pumpAndSettle();
      final icons = [
        Icons.close_rounded,
        Icons.warning_amber_rounded,
        Icons.visibility_outlined,
        Icons.help_outline,
      ];
      for (var i = 1; i < icons.length; i++) {
        expect(
          tester.getCenter(find.byIcon(icons[i])).dx,
          greaterThan(tester.getCenter(find.byIcon(icons[i - 1])).dx),
        );
      }
      expect(find.text('ID'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'decimal actions preserve text, selection and numeric callbacks',
    (tester) async {
      var prefixCalls = 0;
      var suffixCalls = 0;
      final values = <double>[];
      Widget field(bool enabled) => D3DecimalField(
        label: 'Amount',
        initialValue: 12.5,
        isEnabled: enabled,
        onChanged: values.add,
        prefixWidget: IconButton(
          tooltip: 'Currency',
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          onPressed: () => prefixCalls++,
          icon: const Icon(Icons.attach_money, size: 18),
        ),
        suffixWidget: IconButton(
          tooltip: 'Calculator',
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          onPressed: () => suffixCalls++,
          icon: const Icon(Icons.calculate, size: 18),
        ),
      );
      await tester.pumpWidget(_wrap(field(true), width: 240));
      await tester.enterText(find.byType(TextField), '12.34');
      final controller = tester
          .widget<TextField>(find.byType(TextField))
          .controller!;
      controller.selection = const TextSelection.collapsed(offset: 2);
      await tester.pump();
      final before = controller.value;
      for (final tooltip in ['Currency', 'Calculator']) {
        final button = find.byTooltip(tooltip);
        final rect = tester.getRect(button);
        expect(rect.width, greaterThanOrEqualTo(48));
        expect(rect.height, greaterThanOrEqualTo(48));
        for (final offset in [
          const Offset(-22, -22),
          const Offset(22, -22),
          const Offset(-22, 22),
          const Offset(22, 22),
        ]) {
          await tester.tapAt(rect.center + offset);
          await tester.pump();
          expect(controller.value, before);
        }
      }
      expect(prefixCalls, 4);
      expect(suffixCalls, 4);
      expect(values, [12.34]);
      await tester.pumpWidget(_wrap(field(false), width: 240));
      await tester.pumpAndSettle();
      // Deliberately keep callbacks on the supplied widgets: the field must
      // still block pointers and focus when disabled.
      await tester.tapAt(tester.getCenter(find.byTooltip('Currency')));
      await tester.tapAt(tester.getCenter(find.byTooltip('Calculator')));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(prefixCalls, 4);
      expect(suffixCalls, 4);
      expect(values, [12.34]);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('decimal slots rebuild without reformatting focused input', (
    tester,
  ) async {
    var useIcon = false;
    late StateSetter rebuild;
    final values = <double>[];
    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return D3DecimalField(
              label: 'Amount',
              initialValue: 2,
              prefixText: useIcon ? null : 'USD',
              suffixIcon: useIcon ? Icons.check : null,
              onChanged: values.add,
            );
          },
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), '12.3');
    final controller = tester
        .widget<TextField>(find.byType(TextField))
        .controller!;
    controller.selection = const TextSelection.collapsed(offset: 1);
    final before = controller.value;
    rebuild(() => useIcon = true);
    await tester.pump();
    expect(controller.value, before);
    expect(values, [12.3]);
  });
}
