import 'package:material_ui/material_ui.dart';
import 'package:d3_ui/d3_ui.dart';

/// A scrollable tab bar. Pass a [controller] to drive or observe the
/// selection from outside (e.g. a tab strip that scrolls a list); without
/// one the bar manages its own.
class D3TabBar extends StatefulWidget {
  const new({
    super.key,
    required this.tabs,
    this.isScrollable = true,
    this.controller,
    this.onTap,
  });
  final List<Widget> tabs;

  final bool isScrollable;

  /// Must have `length == tabs.length`. Owned by the caller.
  final TabController? controller;

  final ValueChanged<int>? onTap;

  @override
  State<D3TabBar> createState() => _D3TabBarState();
}

class _D3TabBarState extends State<D3TabBar>
    with SingleTickerProviderStateMixin {
  TabController? _ownController;

  TabController get _controller =>
      widget.controller ??
      (_ownController ??= TabController(
        length: widget.tabs.length,
        vsync: this,
      ));

  @override
  void dispose() {
    _ownController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    return TabBar(
      splashBorderRadius: BorderRadius.circular(12),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return colors.primary.withValues(alpha: 0.14);
        }
        if (states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.focused)) {
          return colors.primary.withValues(alpha: 0.08);
        }
        return null;
      }),
      isScrollable: widget.isScrollable,
      controller: _controller,
      tabs: widget.tabs,
      onTap: widget.onTap,
    );
  }
}
