import 'package:d3_ui/d3_ui.dart';
import 'package:d3_ui/src/components/inputs/d3_otp_field.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Widget _wrap(
  Widget child, {
  double width = 400,
  double scale = 1,
  bool dark = false,
}) => MaterialApp(
  theme: dark ? D3AppTheme.dark() : D3AppTheme.light(),
  home: MediaQuery(
    data: MediaQueryData(
      size: Size(width, 800),
      textScaler: TextScaler.linear(scale),
    ),
    child: Scaffold(
      body: Center(
        child: SizedBox(width: width, child: child),
      ),
    ),
  ),
);

Finder get _field => find.byType(TextField);

void main() {
  testWidgets('typing fills cells in order and backspace deletes', (
    tester,
  ) async {
    final seen = <String>[];
    await tester.pumpWidget(_wrap(D3OtpField(onChanged: seen.add)));
    await tester.enterText(_field, '12');
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    await tester.enterText(_field, '1');
    await tester.pump();
    expect(find.text('2'), findsNothing);
    expect(seen, ['12', '1']);
  });

  testWidgets('paste truncates and onCompleted fires once', (tester) async {
    final done = <String>[];
    await tester.pumpWidget(_wrap(D3OtpField(onCompleted: done.add)));
    await tester.enterText(_field, '123456789');
    await tester.pump();
    expect(tester.widget<TextField>(_field).controller!.text, '123456');
    expect(done, ['123456']);
  });

  testWidgets('digits mode rejects letters', (tester) async {
    await tester.pumpWidget(_wrap(const D3OtpField()));
    await tester.enterText(_field, '1a2b');
    await tester.pump();
    expect(tester.widget<TextField>(_field).controller!.text, '12');
  });

  testWidgets('alphanumeric mode accepts letters', (tester) async {
    await tester.pumpWidget(
      _wrap(const D3OtpField(type: D3OtpType.alphanumeric)),
    );
    await tester.enterText(_field, 'a1-b');
    await tester.pump();
    expect(tester.widget<TextField>(_field).controller!.text, 'a1b');
  });

  testWidgets('obscureText shows dots', (tester) async {
    await tester.pumpWidget(_wrap(const D3OtpField(obscureText: true)));
    await tester.enterText(_field, '12');
    await tester.pump();
    expect(find.text('•'), findsNWidgets(2));
    expect(find.text('1'), findsNothing);
  });

  testWidgets('error state shows the message', (tester) async {
    await tester.pumpWidget(_wrap(const D3OtpField(errorText: 'Wrong code')));
    await tester.pumpAndSettle();
    expect(find.text('Wrong code'), findsOneWidget);
  });

  testWidgets('six cells do not overflow at 320dp and text scale 1.5', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const D3OtpField(), width: 320, scale: 1.5));
    await tester.enterText(_field, '123456');
    await tester.pump();
    expect(tester.takeException(), isNull);
    final cells = find.byType(InkWell);
    expect(cells, findsNWidgets(6));
    final first = tester.getRect(cells.first);
    final last = tester.getRect(cells.last);
    final box = tester.getRect(find.byType(D3OtpField));
    expect(box.width, 320);
    expect(first.left, greaterThanOrEqualTo(box.left));
    expect(last.right, lessThanOrEqualTo(box.right + 0.01));
    expect(first.width, greaterThanOrEqualTo(40));
  });

  testWidgets('cells are 48x56 at default width', (tester) async {
    await tester.pumpWidget(_wrap(const D3OtpField()));
    final size = tester.getSize(find.byType(InkWell).first);
    expect(size, const Size(48, 56));
  });

  testWidgets('semantics is one text field with a label', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_wrap(const D3OtpField(obscureText: true)));
    await tester.enterText(_field, '12');
    await tester.pump();
    final node = tester.getSemantics(
      find.bySemanticsLabel('Verification code'),
    );
    final data = node.getSemanticsData();
    expect(data.value, '••');
    handle.dispose();
  });

  testWidgets('tapping a cell focuses the field', (tester) async {
    await tester.pumpWidget(_wrap(const D3OtpField()));
    expect(tester.widget<TextField>(_field).focusNode!.hasFocus, isFalse);
    await tester.tap(find.byType(InkWell).at(3));
    await tester.pump();
    expect(tester.widget<TextField>(_field).focusNode!.hasFocus, isTrue);
  });

  testWidgets('disabled field ignores taps', (tester) async {
    await tester.pumpWidget(_wrap(const D3OtpField(enabled: false)));
    await tester.tap(find.byType(InkWell).first, warnIfMissed: false);
    await tester.pump();
    expect(tester.widget<TextField>(_field).focusNode!.hasFocus, isFalse);
  });
}
