import 'package:material_ui/material_ui.dart';

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
    return TabBar(
      isScrollable: widget.isScrollable,
      controller: _controller,
      tabs: widget.tabs,
      onTap: widget.onTap,
    );
  }
}
