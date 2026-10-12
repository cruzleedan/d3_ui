import 'package:material_ui/material_ui.dart';

/// The Material 3 window size classes, by width in logical pixels.
///
/// | Class | Width | Typical navigation |
/// |---|---|---|
/// | [compact] | under 600 | bottom bar, one pane |
/// | [medium] | 600 to 839 | rail, one pane |
/// | [expanded] | 840 and over | rail, list and detail side by side |
///
/// Use [D3WindowSizeBuilder] when the layout should follow the width it is
/// given (an app embedded in a frame, a pane), and [D3WindowSizeClass.of] when
/// it should follow the window.
enum D3WindowSizeClass {
  compact,
  medium,
  expanded;

  /// The first width of [medium].
  static const double mediumBreakpoint = 600;

  /// The first width of [expanded].
  static const double expandedBreakpoint = 840;

  /// The class for a width.
  static D3WindowSizeClass fromWidth(double width) {
    if (width >= expandedBreakpoint) return expanded;
    if (width >= mediumBreakpoint) return medium;
    return compact;
  }

  /// The class of the window the widget is in.
  static D3WindowSizeClass of(BuildContext context) =>
      fromWidth(MediaQuery.sizeOf(context).width);

  bool get isCompact => this == compact;
  bool get isMedium => this == medium;
  bool get isExpanded => this == expanded;
}

/// Builds its child from the [D3WindowSizeClass] of the width it is given,
/// which can be narrower than the window (a frame, a split pane).
class D3WindowSizeBuilder extends StatelessWidget {
  const D3WindowSizeBuilder({super.key, required this.builder});

  final Widget Function(BuildContext context, D3WindowSizeClass sizeClass)
  builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => builder(
        context,
        D3WindowSizeClass.fromWidth(
          constraints.hasBoundedWidth
              ? constraints.maxWidth
              : MediaQuery.sizeOf(context).width,
        ),
      ),
    );
  }
}
