import 'dart:io';
import 'dart:ui' as ui;

import 'package:d3_ui/d3_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:d3_ui_example/previews/d3_input_previews.dart';

void main() {
  for (final dark in [false, true]) {
    for (final scale in [1.0, 1.5]) {
      testWidgets(
        'input example fits a compact form: dark=$dark scale=$scale',
        (tester) async {
          await tester.binding.setSurfaceSize(const Size(320, 1000));
          addTearDown(() => tester.binding.setSurfaceSize(null));
          final boundaryKey = GlobalKey();
          await tester.pumpWidget(
            MaterialApp(
              theme: dark ? D3AppTheme.dark() : D3AppTheme.light(),
              home: MediaQuery(
                data: MediaQueryData(
                  size: const Size(320, 1000),
                  textScaler: TextScaler.linear(scale),
                ),
                child: Scaffold(
                  body: SingleChildScrollView(
                    child: RepaintBoundary(
                      key: boundaryKey,
                      child: const InputExamples(),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await tester.tap(find.byTooltip('Change currency'));
          await tester.pumpAndSettle();
          expect(find.text('Amount (PHP)'), findsOneWidget);
          await tester.tap(find.byTooltip('Amount details'));
          await tester.pumpAndSettle();
          expect(find.byType(AlertDialog), findsOneWidget);
          await tester.tap(find.text('Close'));
          await tester.pumpAndSettle();
          await tester.tap(find.byType(D3Toggle));
          await tester.pumpAndSettle();
          final buttons = tester.widgetList<IconButton>(
            find.byType(IconButton),
          );
          expect(buttons.every((button) => button.onPressed == null), isTrue);
          expect(tester.takeException(), isNull);

          // Optional local review artifact; normal test runs write no files.
          final output = Platform.environment[
              dark ? 'D3_INPUT_PREVIEW_DARK' : 'D3_INPUT_PREVIEW_LIGHT'];
          if (output != null && scale == 1.0) {
            final boundary = boundaryKey.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
            await tester.runAsync(() async {
              final image = await boundary.toImage();
              final data =
                  await image.toByteData(format: ui.ImageByteFormat.png);
              final file = File(output);
              await file.parent.create(recursive: true);
              await file.writeAsBytes(data!.buffer.asUint8List());
              image.dispose();
            });
          }
        },
      );
    }
  }
}
