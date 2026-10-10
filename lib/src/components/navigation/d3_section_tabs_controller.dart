import 'package:material_ui/material_ui.dart';
import 'package:d3_ui/d3_ui.dart';

/// Keeps a row of tabs ([D3TabBar]) and a long scrolling list of sections in
/// step: tapping a tab scrolls to its section, and scrolling selects the tab
/// of the section currently at the top.
///
/// Usage: call [setSections] with the visible section ids on every build, put
/// `controller.keyFor(id)` on each section's heading, pass [tabController] to
/// a [D3TabBar], and call [scrollTo] from its `onTap`. Call [dispose] with the
/// owning state.
class D3SectionTabsController {
  D3SectionTabsController({
    required this.vsync,
    required this.scrollController,
    required this.stickyBottom,
    this.activeTolerance = D3Spacing.s24,
    this.scrollGap = D3Spacing.s8,
  }) {
    scrollController.addListener(syncActive);
  }

  final TickerProvider vsync;
  final ScrollController scrollController;

  /// Screen y below which section content is visible — under any pinned
  /// bar and the tab bar itself. Read on every scroll, so it may change.
  final double Function() stickyBottom;

  /// A section counts as reached once its heading is within this distance
  /// below [stickyBottom].
  final double activeTolerance;

  /// Space left between the pinned area and a section after [scrollTo].
  final double scrollGap;

  final _keys = <String, GlobalKey>{};
  List<String> _ids = const [];
  TabController? _tabController;
  bool _tabScrolling = false;

  /// Null until [setSections] has been called.
  TabController? get tabController => _tabController;

  /// A stable key for [id]'s heading.
  GlobalKey keyFor(String id) => _keys.putIfAbsent(id, GlobalKey.new);

  /// Sets the sections currently shown, in order. Recreates the
  /// [TabController] only when the count changes (keeping the selection in
  /// range; zero sections is allowed).
  void setSections(List<String> ids) {
    _ids = ids;
    final current = _tabController;
    if (current != null && current.length == ids.length) return;
    final index = ids.isEmpty || current == null
        ? 0
        : current.index.clamp(0, ids.length - 1);
    current?.dispose();
    _tabController = TabController(
      length: ids.length,
      vsync: vsync,
      initialIndex: index,
    );
  }

  double? _top(String id) {
    final box = _keys[id]?.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return null;
    return box.localToGlobal(Offset.zero).dy;
  }

  /// Selects the tab of the last section whose heading has reached the pinned
  /// area. Runs on every scroll; ignored while a [scrollTo] is animating.
  void syncActive() {
    final controller = _tabController;
    if (_tabScrolling || controller == null || controller.length == 0) return;
    var active = 0;
    for (var i = 0; i < _ids.length; i++) {
      final top = _top(_ids[i]);
      if (top != null && top <= stickyBottom() + activeTolerance) active = i;
    }
    if (active != controller.index && active < controller.length) {
      controller.animateTo(active);
    }
  }

  /// Scrolls section [index] to just under the pinned area, then selects its
  /// tab. A section that cannot reach the top (end of content) scrolls as far
  /// as it can.
  Future<void> scrollTo(int index) async {
    if (index >= _ids.length || !scrollController.hasClients) return;
    final top = _top(_ids[index]);
    if (top == null) return;
    final position = scrollController.position;
    final target = (position.pixels + top - stickyBottom() - scrollGap).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    _tabScrolling = true;
    try {
      await scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } finally {
      _tabScrolling = false;
    }
    _tabController?.animateTo(index);
  }

  void dispose() {
    scrollController.removeListener(syncActive);
    _tabController?.dispose();
  }
}
