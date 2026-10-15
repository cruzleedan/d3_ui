import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

// Layout only: the owning control supplies its gesture/semantics behavior.
class D3TapTarget extends StatelessWidget {
  const D3TapTarget({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: kMinInteractiveDimension,
        minHeight: kMinInteractiveDimension,
      ),
      child: Center(widthFactor: 1, heightFactor: 1, child: child),
    );
  }
}

/// Gives a smaller visual a tap region of at least [minSize] (48 x 48 dp by
/// default), the way Material's own buttons do (`MaterialTapTargetSize.padded`):
/// the box is at least [minSize], the child stays its own size in the middle,
/// and a press anywhere in the box is handed to the child, so its ripple stays
/// inside its own shape.
///
/// Use it around the *visual* control (a button, an icon button) that has its own
/// gesture and ink. Unlike [D3TapTarget] it needs no extra gesture detector.
class D3PaddedTapTarget extends SingleChildRenderObjectWidget {
  const D3PaddedTapTarget({
    super.key,
    this.minSize = const Size.square(kMinInteractiveDimension),
    required Widget super.child,
  });

  final Size minSize;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderPaddedTapTarget(minSize);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderPaddedTapTarget renderObject,
  ) {
    renderObject.minSize = minSize;
  }
}

class _RenderPaddedTapTarget extends RenderShiftedBox {
  _RenderPaddedTapTarget(this._minSize) : super(null);

  Size _minSize;

  set minSize(Size value) {
    if (_minSize == value) return;
    _minSize = value;
    markNeedsLayout();
  }

  @override
  double computeMinIntrinsicWidth(double height) =>
      math.max(child?.getMinIntrinsicWidth(height) ?? 0.0, _minSize.width);

  @override
  double computeMaxIntrinsicWidth(double height) =>
      math.max(child?.getMaxIntrinsicWidth(height) ?? 0.0, _minSize.width);

  @override
  double computeMinIntrinsicHeight(double width) =>
      math.max(child?.getMinIntrinsicHeight(width) ?? 0.0, _minSize.height);

  @override
  double computeMaxIntrinsicHeight(double width) =>
      math.max(child?.getMaxIntrinsicHeight(width) ?? 0.0, _minSize.height);

  Size _sizeFor(Size childSize, BoxConstraints constraints) =>
      constraints.constrain(
        Size(
          math.max(childSize.width, _minSize.width),
          math.max(childSize.height, _minSize.height),
        ),
      );

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final c = child;
    if (c == null) return constraints.constrain(_minSize);
    return _sizeFor(c.getDryLayout(constraints), constraints);
  }

  @override
  void performLayout() {
    final c = child;
    if (c == null) {
      size = constraints.constrain(_minSize);
      return;
    }
    c.layout(constraints, parentUsesSize: true);
    size = _sizeFor(c.size, constraints);
    (c.parentData! as BoxParentData).offset = Offset(
      (size.width - c.size.width) / 2,
      (size.height - c.size.height) / 2,
    );
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (!size.contains(position)) return false;
    // A hit on the child itself, else a hit handed to the child's centre.
    return super.hitTest(result, position: position) ||
        child!.hitTest(result, position: child!.size.center(Offset.zero));
  }
}
