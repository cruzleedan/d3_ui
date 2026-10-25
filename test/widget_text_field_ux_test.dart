import 'package:d3_ui/d3_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Widget wrap(
  Widget field, {
  bool dark = false,
  double scale = 1,
  bool reducedMotion = false,
  TextDirection direction = TextDirection.ltr,
  D3InputTokens? tokens,
}) => MaterialApp(
  key: UniqueKey(),
  theme: dark
      ? D3AppTheme.dark(inputTokens: tokens)
      : D3AppTheme.light(inputTokens: tokens),
  home: Scaffold(
    body: Center(
      child: MediaQuery(
        data: MediaQueryData(
          textScaler: TextScaler.linear(scale),
          disableAnimations: reducedMotion,
        ),
        child: Directionality(
          textDirection: direction,
          child: SizedBox(width: 320, child: field),
        ),
      ),
    ),
  ),
);
Finder paint() => find
    .descendant(
      of: find.byType(D3TextField),
      matching: find.byType(AnimatedContainer),
    )
    .first;
BoxDecoration decoration(WidgetTester t) =>
    t.widget<AnimatedContainer>(paint()).decoration! as BoxDecoration;
Finder action(IconData icon) => find
    .ancestor(of: find.byIcon(icon), matching: find.byType(IconButton))
    .first;

void main() {
  for (final compact in [false, true]) {
    testWidgets('stable geometry and action corner taps compact=$compact', (
      t,
    ) async {
      await t.pumpWidget(
        wrap(
          D3TextField(
            label: 'Password',
            isCompact: compact,
            obscureText: true,
            initialValue: 'secret',
          ),
        ),
      );
      final before = t.getRect(paint());
      expect(before.height, compact ? 40 : 50);
      for (final offset in [
        const Offset(-22, -22),
        const Offset(22, -22),
        const Offset(-22, 22),
        const Offset(22, 22),
      ]) {
        final rect = t.getRect(action(Icons.visibility_outlined));
        expect(rect.size, const Size(48, 48));
        await t.tapAt(rect.center + offset);
        await t.pumpAndSettle();
        expect(
          t.widget<TextField>(find.byType(TextField)).obscureText,
          isFalse,
        );
        await t.tapAt(rect.center + offset);
        await t.pumpAndSettle();
      }
      // The invisible compact strip belongs to the field, not a neighbor.
      final focus = t.widget<TextField>(find.byType(TextField)).focusNode!;
      for (final y in [
        before.top - (compact ? 2 : -2),
        before.bottom + (compact ? 2 : -2),
      ]) {
        focus.unfocus();
        await t.pumpAndSettle();
        await t.tapAt(Offset(before.left + 3, y));
        await t.pumpAndSettle();
        expect(focus.hasFocus, isTrue);
        expect(t.getRect(paint()), before);
      }
      for (final offset in [
        const Offset(-22, -22),
        const Offset(22, -22),
        const Offset(-22, 22),
        const Offset(22, 22),
      ]) {
        await t.enterText(find.byType(TextField), 'secret');
        await t.pumpAndSettle();
        final clear = t.getRect(action(Icons.close_rounded));
        final reveal = t.getRect(action(Icons.visibility_outlined));
        expect(clear.size, const Size(48, 48));
        expect(clear.overlaps(reveal), isFalse);
        await t.tapAt(clear.center + offset);
        await t.pumpAndSettle();
        expect(
          t.widget<TextField>(find.byType(TextField)).controller!.text,
          isEmpty,
        );
        expect(focus.hasFocus, isTrue);
        expect(t.getRect(paint()), before);
      }
    });
  }

  testWidgets('disabled reveal is inert; read-only reveal remains available', (
    t,
  ) async {
    final semantics = t.ensureSemantics();
    for (final enabled in [false, true]) {
      await t.pumpWidget(
        wrap(
          D3TextField(
            label: 'Secret',
            obscureText: true,
            initialValue: 'secret',
            isEnabled: enabled,
            isReadOnly: true,
          ),
        ),
      );
      final button = action(Icons.visibility_outlined);
      expect(
        t.getSemantics(button).getSemanticsData().flagsCollection.isButton,
        isTrue,
      );
      expect(
        t.getSemantics(button).getSemanticsData().label,
        contains('Show password'),
      );
      await t.tap(button);
      await t.pumpAndSettle();
      expect(t.widget<TextField>(find.byType(TextField)).obscureText, !enabled);
      expect(find.byIcon(Icons.close_rounded), findsNothing);
    }
    semantics.dispose();
  });

  testWidgets('keyboard can clear then reveal without losing field actions', (
    t,
  ) async {
    await t.pumpWidget(
      wrap(
        const D3TextField(
          label: 'Secret',
          obscureText: true,
          initialValue: 'secret',
        ),
      ),
    );
    await t.tap(find.byType(TextField));
    await t.pumpAndSettle();
    await t.sendKeyEvent(LogicalKeyboardKey.tab);
    await t.pumpAndSettle();
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    await t.sendKeyEvent(LogicalKeyboardKey.enter);
    await t.pumpAndSettle();
    expect(
      t.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
    await t.sendKeyEvent(LogicalKeyboardKey.tab);
    await t.pumpAndSettle();
    await t.sendKeyEvent(LogicalKeyboardKey.enter);
    await t.pumpAndSettle();
    expect(t.widget<TextField>(find.byType(TextField)).obscureText, isFalse);
  });

  testWidgets('suffix gap is independent of prefix and respects direction', (
    t,
  ) async {
    for (final direction in TextDirection.values) {
      for (final prefix in [null, Icons.person_outline]) {
        await t.pumpWidget(
          wrap(
            D3TextField(
              label: 'Value',
              prefixIcon: prefix,
              suffixIcon: Icons.info,
            ),
            direction: direction,
          ),
        );
        final text = t.getRect(find.byType(TextField));
        final icon = t.getRect(find.byIcon(Icons.info));
        expect(
          direction == TextDirection.ltr
              ? icon.left - text.right
              : text.left - icon.right,
          8,
        );
      }
    }
  });

  testWidgets('compact custom action accepts taps beyond its visual bounds', (
    t,
  ) async {
    var taps = 0;
    await t.pumpWidget(
      wrap(
        D3TextField(
          label: 'Value',
          isCompact: true,
          suffixWidget: GestureDetector(
            onTap: () => taps++,
            child: const Icon(Icons.info, size: 18),
          ),
        ),
      ),
    );
    final icon = t.getRect(find.byIcon(Icons.info));
    for (final offset in [
      const Offset(-22, -22),
      const Offset(22, -22),
      const Offset(-22, 22),
      const Offset(22, 22),
    ]) {
      await t.tapAt(icon.center + offset);
      await t.pump();
    }
    expect(taps, 4);
    expect(t.getSize(paint()).height, 40);
    expect(t.takeException(), isNull);
  });

  testWidgets('success warning and error messages follow precedence', (
    t,
  ) async {
    for (final error in [false, true]) {
      await t.pumpWidget(
        wrap(
          D3TextField(
            label: 'Value',
            helperText: 'Help',
            successText: 'Accepted',
            warningText: 'Check this',
            errorText: error ? 'Invalid' : null,
          ),
        ),
      );
      expect(find.text(error ? 'Invalid' : 'Check this'), findsOneWidget);
      expect(find.text('Accepted'), findsNothing);
      expect(find.text('Help'), findsNothing);
      expect(find.byIcon(Icons.check_circle_outline_rounded), findsNothing);
    }
    await t.pumpWidget(
      wrap(const D3TextField(label: 'Value', successText: 'Accepted')),
    );
    expect(find.text('Accepted'), findsOneWidget);
  });

  testWidgets('editable field has one accessible label and read-only state', (
    t,
  ) async {
    final semantics = t.ensureSemantics();
    await t.pumpWidget(
      wrap(
        const D3TextField(
          label: 'Account',
          isReadOnly: true,
          initialValue: 'Saved',
        ),
      ),
    );
    expect(find.bySemanticsLabel('Account'), findsOneWidget);
    final node = t.getSemantics(find.bySemanticsLabel('Account'));
    expect(node.getSemanticsData().flagsCollection.isTextField, isTrue);
    expect(node.getSemanticsData().flagsCollection.isReadOnly, isTrue);
    semantics.dispose();
  });

  testWidgets('submit-only does not validate on blur', (t) async {
    var calls = 0;
    await t.pumpWidget(
      wrap(
        D3TextField(
          label: 'Value',
          validationMode: D3ValidationMode.onSubmit,
          validator: (_) {
            calls++;
            return 'Invalid';
          },
        ),
      ),
    );
    await t.tap(find.byType(TextField));
    await t.pump();
    t.widget<TextField>(find.byType(TextField)).focusNode!.unfocus();
    await t.pumpAndSettle();
    expect(calls, 0);
    await t.tap(find.byType(TextField));
    await t.pump();
    await t.testTextInput.receiveAction(TextInputAction.done);
    await t.pumpAndSettle();
    expect(calls, 1);
    expect(find.text('Invalid'), findsOneWidget);
  });

  testWidgets('at the length limit is warning, exceeding it is error', (
    t,
  ) async {
    for (final length in [8, 10, 11]) {
      await t.pumpWidget(
        wrap(
          D3TextField(
            label: 'Value',
            initialValue: 'x' * length,
            maxLength: 10,
          ),
        ),
      );
      final colors = t.element(find.byType(D3TextField)).d3Colors;
      expect(
        t.widget<Text>(find.text('$length / 10')).style!.color,
        d3EnsureContrast(
          length > 10 ? colors.error : colors.warning,
          colors.surface,
        ),
      );
    }
  });

  for (final dark in [false, true]) {
    for (final variant in D3InputVariant.values) {
      testWidgets('contrast and filled borders dark=$dark variant=$variant', (
        t,
      ) async {
        for (final state in ['idle', 'error', 'warning', 'success']) {
          await t.pumpWidget(
            wrap(
              D3TextField(
                label: 'Value',
                hintText: 'Hint',
                variant: variant,
                errorText: state == 'error' ? 'Error' : null,
                warningText: state == 'warning' ? 'Warning' : null,
                successText: state == 'success' ? 'Success' : null,
              ),
              dark: dark,
            ),
          );
          await t.pumpAndSettle();
          final d = decoration(t);
          final border = d.border! as Border;
          expect(border.bottom.width, 1);
          expect(border.top.width, variant == D3InputVariant.filled ? 0 : 1);
          expect(
            d3ContrastRatio(border.bottom.color, d.color!),
            greaterThanOrEqualTo(3),
          );
          final hint = t
              .widget<TextField>(find.byType(TextField))
              .decoration!
              .hintStyle!
              .color!;
          expect(d3ContrastRatio(hint, d.color!), greaterThanOrEqualTo(4.5));
          if (state != 'idle') {
            final text = t.widget<Text>(
              find.text(state[0].toUpperCase() + state.substring(1)),
            );
            final colors = t.element(find.byType(D3TextField)).d3Colors;
            expect(
              d3ContrastRatio(text.style!.color!, colors.surface),
              greaterThanOrEqualTo(4.5),
            );
          }
          expect(t.takeException(), isNull);
        }
      });
    }
  }

  for (final scale in [1.0, 2.0]) {
    for (final direction in TextDirection.values) {
      testWidgets(
        'multiline slots align with first line scale=$scale $direction',
        (t) async {
          await t.pumpWidget(
            wrap(
              const D3TextField(
                label: 'Long description',
                isCompact: true,
                maxLines: 3,
                prefixIcon: Icons.edit,
                suffixIcon: Icons.info,
              ),
              scale: scale,
              direction: direction,
            ),
          );
          final text = t.getRect(find.byType(TextField));
          final prefix = t.getRect(find.byIcon(Icons.edit));
          final suffix = t.getRect(find.byIcon(Icons.info));
          // Native editable height covers three lines; icon centers share line one.
          expect(
            prefix.center.dy,
            moreOrLessEquals(text.top + text.height / 6, epsilon: 3),
          );
          expect(suffix.center.dy, prefix.center.dy);
          expect(prefix.top, greaterThan(t.getRect(paint()).top + 4));
          expect(t.getRect(paint()).height, greaterThan(40));
          expect(t.takeException(), isNull);
        },
      );
    }
  }

  testWidgets(
    'reduced motion and custom border widths retain stable geometry',
    (t) async {
      await t.pumpWidget(
        wrap(
          const D3TextField(label: 'Value', errorText: 'Invalid'),
          reducedMotion: true,
          tokens: D3InputTokens.defaults.copyWith(focusedBorderWidth: 4),
        ),
      );
      final before = t.getRect(paint());
      await t.tap(find.byType(TextField));
      await t.pump();
      expect(t.widget<AnimatedContainer>(paint()).duration, Duration.zero);
      expect(t.getRect(paint()), before);
      final label = t.widget<Text>(find.text('Value'));
      expect(
        (label.textSpan! as TextSpan).style!.color,
        d3EnsureContrast(
          t.element(find.byType(D3TextField)).d3Colors.primary,
          t.element(find.byType(D3TextField)).d3Colors.surface,
        ),
      );
    },
  );
}
