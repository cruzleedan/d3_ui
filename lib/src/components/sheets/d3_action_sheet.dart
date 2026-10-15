import 'package:material_ui/material_ui.dart';
import 'package:d3_ui/d3_ui.dart';

/// One row of a [D3ActionSheet].
///
/// Exactly one of [onPressed] / [onPressedWithContext] may be set (both may
/// be null for a row that only closes the sheet). The sheet closes after the
/// callback runs, unless the callback already closed it with
/// [D3ActionSheet.pop].
class D3ActionSheetAction {
  const D3ActionSheetAction({
    required this.label,
    this.icon,
    this.subtitle,
    this.isDestructive = false,
    this.isSelected = false,
    this.enabled = true,
    this.onPressed,
    this.onPressedWithContext,
  }) : assert(
         onPressed == null || onPressedWithContext == null,
         'Provide only one of onPressed or onPressedWithContext.',
       );

  /// The row's text.
  final String label;

  /// Optional leading icon.
  final IconData? icon;

  /// Optional second line under the label.
  final String? subtitle;

  /// Renders the row in the error colour for actions like "Delete".
  final bool isDestructive;

  /// Shows a trailing check and reports the row as selected.
  final bool isSelected;

  /// A disabled row is dimmed and ignores taps.
  final bool enabled;

  /// Called when the row is tapped; the sheet then closes.
  final VoidCallback? onPressed;

  /// Like [onPressed] but receives a context inside the sheet, for
  /// [D3ActionSheet.pop] with a result.
  final void Function(BuildContext context)? onPressedWithContext;

  void _invoke(BuildContext sheetContext) {
    if (onPressed != null) {
      onPressed!();
    } else {
      onPressedWithContext?.call(sheetContext);
    }
  }
}

/// A content-sized bottom sheet of actions, for choices where a dialog serves
/// poorly: "Share", "Edit", "Delete", then a separate Cancel row.
///
/// ```dart
/// final choice = await D3ActionSheet.show<String>(
///   context,
///   title: 'Photo',
///   actions: [
///     D3ActionSheetAction(
///       label: 'Share',
///       icon: Icons.ios_share,
///       onPressedWithContext: (ctx) => D3ActionSheet.pop(ctx, 'share'),
///     ),
///     D3ActionSheetAction(
///       label: 'Delete',
///       isDestructive: true,
///       onPressedWithContext: (ctx) => D3ActionSheet.pop(ctx, 'delete'),
///     ),
///   ],
/// );
/// ```
class D3ActionSheet {
  const D3ActionSheet._();

  /// Closes the enclosing action sheet and returns [result] from [show].
  static void pop<T>(BuildContext context, [T? result]) {
    _ActionSheetScope.of(context)?._close(result);
  }

  /// Shows the sheet and returns the value passed to [pop], or null when the
  /// sheet was dismissed (Cancel, tap outside, drag down, back).
  static Future<T?> show<T>(
    BuildContext context, {
    String? title,
    String? message,
    required List<D3ActionSheetAction> actions,
    String cancelLabel = 'Cancel',
    bool showCancel = true,
    bool useRootNavigator = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      useRootNavigator: useRootNavigator,
      builder: (ctx) => _ActionSheetContent(
        title: title,
        message: message,
        actions: actions,
        cancelLabel: cancelLabel,
        showCancel: showCancel,
      ),
    );
  }
}

class _ActionSheetScope extends InheritedWidget {
  const _ActionSheetScope({required this.state, required super.child});
  final _ActionSheetContentState state;

  static _ActionSheetContentState? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ActionSheetScope>()?.state;

  @override
  bool updateShouldNotify(_ActionSheetScope old) => false;
}

class _ActionSheetContent extends StatefulWidget {
  const _ActionSheetContent({
    required this.title,
    required this.message,
    required this.actions,
    required this.cancelLabel,
    required this.showCancel,
  });

  final String? title;
  final String? message;
  final List<D3ActionSheetAction> actions;
  final String cancelLabel;
  final bool showCancel;

  @override
  State<_ActionSheetContent> createState() => _ActionSheetContentState();
}

class _ActionSheetContentState extends State<_ActionSheetContent> {
  bool _closed = false;

  void _close<R>(R? result) {
    if (_closed || !mounted) return;
    _closed = true;
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    final media = MediaQuery.of(context);
    final text = Theme.of(context).textTheme;
    final hasHeader = widget.title != null || widget.message != null;
    final radius = Radius.circular(context.d3Shape.xl);

    return _ActionSheetScope(
      state: this,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: media.size.height * 0.7),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: radius),
          child: Material(
            color: colors.surfaceContainerLow,
            child: Padding(
              padding: EdgeInsets.only(bottom: media.viewPadding.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 6),
                    child: Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: colors.outline.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: D3Spacing.s16,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (hasHeader)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: D3Spacing.s16,
                                vertical: D3Spacing.s12,
                              ),
                              child: Column(
                                children: [
                                  if (widget.title != null)
                                    Text(
                                      widget.title!,
                                      textAlign: TextAlign.center,
                                      style: text.titleMedium?.copyWith(
                                        color: colors.onSurface,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  if (widget.message != null)
                                    Padding(
                                      padding: EdgeInsets.only(
                                        top: widget.title != null
                                            ? D3Spacing.s4
                                            : 0,
                                      ),
                                      child: Text(
                                        widget.message!,
                                        textAlign: TextAlign.center,
                                        style: text.bodyMedium?.copyWith(
                                          color: colors.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          _Group(
                            colors: colors,
                            children: [
                              for (var i = 0; i < widget.actions.length; i++)
                                _ActionRow(
                                  action: widget.actions[i],
                                  showDivider: i > 0,
                                  onTap: (rowContext) {
                                    // Row context sits below the scope, so
                                    // D3ActionSheet.pop resolves from it.
                                    widget.actions[i]._invoke(rowContext);
                                    _close<Object>(null);
                                  },
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (widget.showCancel)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        D3Spacing.s16,
                        D3Spacing.s8,
                        D3Spacing.s16,
                        D3Spacing.s8,
                      ),
                      child: _Group(
                        colors: colors,
                        children: [
                          _ActionRow(
                            action: D3ActionSheetAction(
                              label: widget.cancelLabel,
                            ),
                            showDivider: false,
                            bold: true,
                            onTap: (_) => _close<Object>(null),
                          ),
                        ],
                      ),
                    )
                  else
                    const SizedBox(height: D3Spacing.s8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.colors, required this.children});
  final D3ColorTokens colors;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colors.surfaceContainerHigh,
      clipBehavior: Clip.antiAlias,
      borderRadius: context.d3Shape.circularLg,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.action,
    required this.showDivider,
    required this.onTap,
    this.bold = false,
  });

  final D3ActionSheetAction action;
  final bool showDivider;
  final void Function(BuildContext context) onTap;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    final text = Theme.of(context).textTheme;
    final fill = colors.surfaceContainerHigh;
    final Color labelColor = action.isDestructive
        ? d3EnsureContrast(colors.error, fill)
        : colors.onSurface;
    final iconColor = action.isDestructive
        ? labelColor
        : colors.onSurfaceVariant;
    final enabled = action.enabled;

    final semanticsLabel = [
      action.label,
      if (action.subtitle != null) action.subtitle!,
      if (action.isDestructive) 'destructive',
    ].join(', ');

    Widget row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: D3Spacing.s56),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: D3Spacing.s16,
          vertical: D3Spacing.s8,
        ),
        child: Row(
          children: [
            if (action.icon != null) ...[
              Icon(action.icon, size: 24, color: iconColor),
              const SizedBox(width: D3Spacing.s16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: bold
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    action.label,
                    textAlign: bold ? TextAlign.center : TextAlign.start,
                    style: text.bodyLarge?.copyWith(
                      color: labelColor,
                      fontWeight: bold ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  if (action.subtitle != null)
                    Text(
                      action.subtitle!,
                      style: text.bodySmall?.copyWith(
                        color: action.isDestructive
                            ? labelColor
                            : colors.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            if (action.isSelected) ...[
              const SizedBox(width: D3Spacing.s12),
              Icon(Icons.check_rounded, size: 24, color: colors.primary),
            ],
          ],
        ),
      ),
    );

    if (!enabled) row = Opacity(opacity: 0.38, child: row);

    return Semantics(
      container: true,
      button: true,
      enabled: enabled,
      selected: action.isSelected,
      label: semanticsLabel,
      excludeSemantics: true,
      onTap: enabled ? () => onTap(context) : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showDivider)
            Divider(height: 1, thickness: 1, color: colors.outlineVariant),
          InkWell(onTap: enabled ? () => onTap(context) : null, child: row),
        ],
      ),
    );
  }
}
