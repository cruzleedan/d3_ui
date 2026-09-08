import 'package:d3_ui/d3_ui.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:material_ui/material_ui.dart';

/// One swipe-revealed action for a [D3SlidableRow] — icon/label, a
/// background color, and what happens when it's tapped.
class D3SwipeAction {
  const D3SwipeAction({
    required this.icon,
    required this.onPressed,
    this.label,
    this.backgroundColor,
    this.foregroundColor,
  });

  final IconData icon;
  final String? label;

  /// Defaults to the theme's error color (this app's established
  /// swipe-to-delete convention) when null.
  final Color? backgroundColor;
  final Color? foregroundColor;
  final VoidCallback onPressed;
}

/// Wraps [child] in a swipe-to-reveal row of [actions] — replaces the
/// hand-rolled `Dismissible`+`confirmDismiss: (_) async { onDelete();
/// return false; }` pattern duplicated across `site_inspector`'s
/// project/visit list rows before this widget existed.
///
/// Defaults to one full-bleed red delete action when [actions] has a
/// single entry with no explicit color, matching this app's existing
/// swipe-to-delete visual convention exactly. Supports more than one
/// action for a future row that needs it — [actions] can hold 1-4
/// entries, revealed left-to-right in the order given.
///
/// Unlike `Dismissible`, an action's own [D3SwipeAction.onPressed] does
/// the work directly — there's no `confirmDismiss`-returns-false trick
/// needed, since this widget was never asked to fully dismiss/remove
/// the row itself; the caller's own action (e.g. delete then invalidate
/// a list provider) is what actually removes it from the list, exactly
/// as before.
class D3SlidableRow extends StatelessWidget {
  const D3SlidableRow({
    super.key,
    required this.groupTag,
    required this.actions,
    required this.child,
  });

  /// Passed straight to [Slidable.groupTag] — rows sharing the same tag
  /// auto-close each other when one opens. Callers should pass
  /// something stable per list (e.g. the screen's own type name), not
  /// per-row, so opening one row's actions closes any other open row in
  /// the same list.
  final Object groupTag;

  final List<D3SwipeAction> actions;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;

    return Slidable(
      key: key,
      groupTag: groupTag,
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: (0.25 * actions.length).clamp(0.25, 1),
        children: [
          for (final action in actions)
            SlidableAction(
              onPressed: (_) => action.onPressed(),
              backgroundColor: action.backgroundColor ?? colors.error,
              foregroundColor: action.foregroundColor ?? colors.onError,
              icon: action.icon,
              label: action.label,
              borderRadius: D3Radius.circularMd,
            ),
        ],
      ),
      child: child,
    );
  }
}
