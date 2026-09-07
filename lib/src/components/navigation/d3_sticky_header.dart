import 'package:material_ui/material_ui.dart';
import 'package:d3_ui/d3_ui.dart';

/// A sliver that pins [child] to a fixed position as the rest of a
/// [CustomScrollView] scrolls beneath it — for a persistent action or
/// label above a long list (e.g. an "Add" row above a growing list of
/// child records), the way [D3Screen]'s own app bar pins above its body.
///
/// Use only inside a [CustomScrollView] (typically as one of the
/// `slivers` passed via [D3Screen.body] under `D3ScreenLayout.sliver`).
/// See root context/work/0017-project-detail-sticky-add-visit-and-
/// status-readability.md — modeled on a mature reference app's own
/// pinned "Add Expense Line" row above its expense-line list.
///
/// ```dart
/// D3Screen(
///   layout: D3ScreenLayout.sliver,
///   body: CustomScrollView(
///     slivers: [
///       SliverToBoxAdapter(child: SomeHeaderContent()),
///       D3StickyHeader(child: AddRowWidget()),
///       SliverList.builder(...),
///     ],
///   ),
/// )
/// ```
class D3StickyHeader extends StatelessWidget {
  const D3StickyHeader({super.key, required this.child, this.extent = 56});

  /// Content pinned at the top once scrolled into place. Should size
  /// itself to [extent] — wrap in [SizedBox]/[Center] internally if it
  /// doesn't naturally fill that height.
  final Widget child;

  /// Fixed height of the pinned header. Defaults to 56 (a standard
  /// list-row/touch-target height).
  final double extent;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _D3StickyHeaderDelegate(child: child, extent: extent),
    );
  }
}

class _D3StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  _D3StickyHeaderDelegate({required this.child, required this.extent});

  final Widget child;
  final double extent;

  @override
  double get minExtent => extent;

  @override
  double get maxExtent => extent;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final colors = context.d3Colors;
    // Flat by design (no drop shadows in this design system, see
    // D3ColorTokens' surfaceContainer* docs) — a bottom border stands in
    // for a shadow once content has scrolled underneath, so the pinned
    // header still reads as separated from the list beneath it.
    //
    // SizedBox(height: extent) is load-bearing, not decorative padding:
    // RenderSliverPinnedPersistentHeader.performLayout sets paintExtent
    // to min(childExtent, effectiveRemainingPaintExtent) — the CHILD's
    // own laid-out height, not maxExtent — while layoutExtent is clamped
    // from maxExtent directly. If child doesn't actually size itself to
    // extent (e.g. a Row that only wants its content's natural height),
    // childExtent ends up smaller than maxExtent and paintExtent <
    // layoutExtent, which fails SliverGeometry's own validity assertion
    // ("layoutExtent exceeds paintExtent"). Forcing the child to fill
    // extent keeps childExtent == maxExtent so the two stay in sync.
    return SizedBox(
      height: extent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          border: overlapsContent
              ? Border(bottom: BorderSide(color: colors.outline.withValues(alpha: 0.4)))
              : null,
        ),
        child: child,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _D3StickyHeaderDelegate oldDelegate) {
    return oldDelegate.child != child || oldDelegate.extent != extent;
  }
}
