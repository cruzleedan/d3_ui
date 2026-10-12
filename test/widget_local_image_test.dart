import 'package:d3_ui/src/components/display/helpers/d3_local_image_io.dart'
    as io;
import 'package:d3_ui/src/components/display/helpers/d3_local_image_web.dart'
    as web;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Widget _host(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

void main() {
  const missing = '/definitely/not/a/real/file.png';

  testWidgets('io: a missing file reports through errorBuilder', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        io.d3LocalImage(
          missing,
          width: 40,
          height: 40,
          errorBuilder: (_, _, _) => const Text('fallback'),
        ),
      ),
    );
    // The file read is real I/O, which the fake clock does not run.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pump();
    expect(find.text('fallback'), findsOneWidget);
  });

  group('web variant (no file system in a browser)', () {
    testWidgets('a local path shows the error fallback, without throwing', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          web.d3LocalImage(
            missing,
            errorBuilder: (_, error, _) =>
                Text('fallback: ${error.runtimeType}'),
          ),
        ),
      );
      expect(find.textContaining('fallback'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('with no errorBuilder it is an empty box of the right size', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(web.d3LocalImage(missing, width: 30, height: 20)),
      );
      expect(tester.getSize(find.byType(SizedBox).last), const Size(30, 20));
    });

    testWidgets('a URL, as a browser file picker returns, uses Image.network', (
      tester,
    ) async {
      for (final url in [
        'https://example.test/a.png',
        'blob:https://x/1',
        'data:image/png;base64,AAAA',
      ]) {
        await tester.pumpWidget(
          _host(
            web.d3LocalImage(url, errorBuilder: (_, _, _) => const SizedBox()),
          ),
        );
        final image = tester.widget<Image>(find.byType(Image));
        expect(image.image, isA<NetworkImage>(), reason: url);
      }
    });
  });
}
