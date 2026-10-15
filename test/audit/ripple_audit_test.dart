// Audit: the ripple (ink splash and highlight) of a pressed widget must stay
// inside the widget's visible shape, even where its tap region is larger (the
// 48 dp rule). Method: paint the widget, press and hold, paint again, and compare
// the bounding box of the pixels that changed with the box of the visible shape.
//
// Run: flutter test test/audit/ripple_audit_test.dart
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:d3_ui/d3_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void _noop() {}

class _Case {
  const _Case(this.name, this.child);
  final String name;
  final Widget child;
}

final _cases = <_Case>[
  const _Case('D3Chip outlined', D3Chip(label: 'Tag', onTap: _noop)),
  const _Case(
    'D3Chip tonal',
    D3Chip(label: 'Tag', variant: D3ChipVariant.tonal, onTap: _noop),
  ),
  const _Case(
    'D3Chip filled',
    D3Chip(label: 'Tag', variant: D3ChipVariant.filled, onTap: _noop),
  ),
  const _Case(
    'D3Chip selected',
    D3Chip(label: 'Tag', selected: true, onTap: _noop),
  ),
  const _Case(
    'D3Chip dismissible',
    D3Chip(
      label: 'Tag',
      trailingIcon: Icons.close,
      variant: D3ChipVariant.tonal,
      onTap: _noop,
    ),
  ),
  for (final size in D3ButtonSize.values)
    _Case(
      'D3Button filled ${size.name}',
      D3Button(label: 'Go', size: size, onPressed: _noop),
    ),
  for (final size in [D3ButtonSize.xs, D3ButtonSize.md])
    _Case(
      'D3Button tonal ${size.name}',
      D3Button(
        label: 'Go',
        size: size,
        variant: D3ButtonVariant.tonal,
        onPressed: _noop,
      ),
    ),
  for (final size in [D3ButtonSize.xs, D3ButtonSize.md])
    _Case(
      'D3Button outlined ${size.name}',
      D3Button(
        label: 'Go',
        size: size,
        variant: D3ButtonVariant.outlined,
        onPressed: _noop,
      ),
    ),
  _Case(
    'D3Button icon-only xs',
    D3Button.icon(
      icon: Icons.add,
      size: D3ButtonSize.xs,
      onPressed: _noop,
      semanticsLabel: 'Add',
    ),
  ),
  _Case(
    'D3ScrimIconButton',
    D3ScrimIconButton(
      icon: Icons.close,
      semanticsLabel: 'Close',
      scrimColor: Colors.black54,
      onTap: _noop,
    ),
  ),
  _Case(
    'D3SplitButton sm',
    D3SplitButton(
      label: 'Save',
      size: D3ButtonSize.sm,
      onPressed: _noop,
      items: [D3SplitButtonItem(label: 'Other', onPressed: _noop)],
    ),
  ),
  _Case('D3QuantityStepper', D3QuantityStepper(value: 2, onChanged: (_) {})),
  _Case(
    'D3QuantityStepper compact',
    D3QuantityStepper(value: 2, onChanged: (_) {}, compact: true),
  ),
  _Case(
    'D3SearchBar (readOnly)',
    SizedBox(width: 300, child: D3SearchBar(readOnly: true, onTap: _noop)),
  ),
  _Case(
    'D3SegmentedControl',
    SizedBox(
      width: 240,
      child: D3SegmentedControl<int>(
        segments: const [
          D3Segment(value: 1, label: 'One'),
          D3Segment(value: 2, label: 'Two'),
        ],
        selected: 1,
        onChanged: (_) {},
      ),
    ),
  ),
  _Case(
    'D3NavBar',
    SizedBox(
      width: 300,
      child: D3NavBar(
        selectedIndex: 0,
        onTabSelected: (_) {},
        items: const [
          D3NavItem(icon: Icons.home, label: 'Home'),
          D3NavItem(icon: Icons.search, label: 'Find'),
          D3NavItem(icon: Icons.person, label: 'Me'),
        ],
      ),
    ),
  ),
  _Case(
    'D3Banner action',
    SizedBox(
      width: 320,
      child: D3Banner(
        message: 'Hi',
        action: D3BannerAction(label: 'Retry', onPressed: _noop),
        onDismiss: _noop,
      ),
    ),
  ),
];

/// The bounding box of pixels that differ between [a] and [b] (or null).
Rect? _changed(Uint8List a, Uint8List b, int w, int h) {
  int minX = w, minY = h, maxX = -1, maxY = -1;
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      final i = (y * w + x) * 4;
      if ((a[i] - b[i]).abs() > 2 ||
          (a[i + 1] - b[i + 1]).abs() > 2 ||
          (a[i + 2] - b[i + 2]).abs() > 2) {
        if (x < minX) minX = x;
        if (x > maxX) maxX = x;
        if (y < minY) minY = y;
        if (y > maxY) maxY = y;
      }
    }
  }
  return maxX < 0
      ? null
      : Rect.fromLTRB(minX.toDouble(), minY.toDouble(), maxX + 1, maxY + 1);
}

/// The bounding box of pixels that are not the plain background.
Rect? _visible(Uint8List a, int w, int h, List<int> bg) {
  int minX = w, minY = h, maxX = -1, maxY = -1;
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      final i = (y * w + x) * 4;
      if ((a[i] - bg[0]).abs() > 6 ||
          (a[i + 1] - bg[1]).abs() > 6 ||
          (a[i + 2] - bg[2]).abs() > 6) {
        if (x < minX) minX = x;
        if (x > maxX) maxX = x;
        if (y < minY) minY = y;
        if (y > maxY) maxY = y;
      }
    }
  }
  return maxX < 0
      ? null
      : Rect.fromLTRB(minX.toDouble(), minY.toDouble(), maxX + 1, maxY + 1);
}

void main() {
  testWidgets('audit: ripple stays inside the visible shape', (tester) async {
    tester.view.physicalSize = const Size(400, 300);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final key = GlobalKey();
    final report = <String>[];

    Future<(Uint8List, int, int)> shot() async {
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      return (await tester.runAsync(() async {
        final image = await boundary.toImage();
        final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
        return (data!.buffer.asUint8List(), image.width, image.height);
      }))!;
    }

    for (final c in _cases) {
      await tester.pumpWidget(
        KeyedSubtree(
          key: ValueKey(c.name),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: D3AppTheme.light(),
            home: Scaffold(
              backgroundColor: Colors.white,
              body: RepaintBoundary(
                key: key,
                // Ink is painted by the nearest Material, so that Material must be
                // inside the boundary being captured (and nothing opaque may sit
                // between it and the widget).
                child: Material(
                  color: Colors.white,
                  child: Center(child: c.child),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));
      final (before, w, h) = await shot();
      final visible = _visible(before, w, h, [255, 255, 255]);
      // Press the middle of the first tappable thing: the centre of the child.
      final target = tester.getCenter(find.byWidget(c.child));
      // Segmented, nav bar and the stepper have several targets: press the first.
      final press = c.name.contains('NavBar')
          ? Offset(tester.getTopLeft(find.byWidget(c.child)).dx + 50, target.dy)
          : c.name.contains('Segmented')
          ? Offset(tester.getTopLeft(find.byWidget(c.child)).dx + 60, target.dy)
          : c.name.contains('Stepper')
          ? Offset(tester.getTopLeft(find.byWidget(c.child)).dx + 24, target.dy)
          : c.name.contains('Banner')
          ? target
          : target;
      final g = await tester.startGesture(press);
      // The first frame only starts the animations: advance with a second.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 160));
      final (during, _, _) = await shot();
      await g.up();
      await tester.pump(const Duration(milliseconds: 400));
      final ink = _changed(before, during, w, h);
      if (visible == null || ink == null) {
        report.add(
          '?    ${c.name}: ${visible == null ? 'nothing visible' : 'no ripple seen'}',
        );
        continue;
      }
      final over = [
        visible.left - ink.left,
        visible.top - ink.top,
        ink.right - visible.right,
        ink.bottom - visible.bottom,
      ].reduce((a, b) => a > b ? a : b);
      if (over > 3) {
        report.add(
          'FAIL ${c.name}: ripple ${ink.size.width.round()}x${ink.size.height.round()} spills ${over.round()} px beyond the visible ${visible.size.width.round()}x${visible.size.height.round()}',
        );
      }
    }
    // ignore: avoid_print
    print(
      '\n=== RIPPLE AUDIT (${_cases.length} cases) ===\n${report.isEmpty ? 'all pass' : report.join('\n')}\n',
    );
    expect(report.where((r) => r.startsWith('FAIL')), isEmpty);
  });
}
