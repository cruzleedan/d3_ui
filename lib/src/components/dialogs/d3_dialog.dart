import 'package:flutter/material.dart';
import 'package:d3_ui/d3_ui.dart';

// ─────────────────────────────────────────────────────────────────────────────
// D3DialogIconPlacement
// ─────────────────────────────────────────────────────────────────────────────

/// Controls where the icon appears relative to the title.
///
/// [centered] — icon sits above the title, centred. Actions render as
/// full-width stacked buttons (better touch targets for high-stakes dialogs).
///
/// [leading] — icon sits inline to the left of the title block. Actions
/// render as compact text buttons (better for informational / low-stakes
/// dialogs).
enum D3DialogIconPlacement { centered, leading }

// ─────────────────────────────────────────────────────────────────────────────
// D3DialogAction
// ─────────────────────────────────────────────────────────────────────────────

/// A single button action rendered in the dialog footer.
///
/// [isDestructive] renders the action in [D3ColorTokens.error].
/// In stacked layout it becomes a filled red button.
///
/// [isDefault] renders the action in [D3ColorTokens.primary] with semi-bold
/// weight. In stacked layout it becomes a filled primary button.
///
/// Typically the primary/destructive action is listed last so it reads as the
/// "confirm" side.
class D3DialogAction {
  const D3DialogAction({
    required this.label,
    required this.onPressed,
    this.isDestructive = false,
    this.isDefault = false,
  }) : assert(
          !(isDestructive && isDefault),
          'A dialog action cannot be both destructive and default.',
        );

  final String label;
  final VoidCallback onPressed;

  /// Renders the label in [D3ColorTokens.error]. Filled in stacked layout.
  final bool isDestructive;

  /// Renders the label in [D3ColorTokens.primary] with semi-bold weight.
  /// Filled in stacked layout.
  final bool isDefault;
}

// ─────────────────────────────────────────────────────────────────────────────
// D3Dialog
// ─────────────────────────────────────────────────────────────────────────────

/// A minimal, modern dialog with an optional icon, title, message, custom
/// content slot, and a list of [D3DialogAction] buttons.
///
/// **With a centered icon (default when [icon] is set):**
/// Actions render as full-width stacked buttons — a filled primary/destructive
/// button on top, a ghost cancel below. Best for high-stakes confirmations.
///
/// ```dart
/// await D3Dialog.show(
///   context,
///   icon: Icons.delete_outline_rounded,
///   iconColor: context.d3Colors.error,
///   title: 'Delete account',
///   message: 'This cannot be undone.',
///   actions: [
///     D3DialogAction(label: 'Cancel', onPressed: () => Navigator.pop(context)),
///     D3DialogAction(
///       label: 'Delete',
///       isDestructive: true,
///       onPressed: () => Navigator.pop(context, true),
///     ),
///   ],
/// );
/// ```
///
/// **With a leading icon:**
/// Actions render as compact text buttons. Best for informational alerts.
///
/// ```dart
/// await D3Dialog.show(
///   context,
///   icon: Icons.wifi_off_rounded,
///   iconColor: context.d3Colors.primary,
///   iconPlacement: D3DialogIconPlacement.leading,
///   title: 'Connection lost',
///   message: 'Check your internet connection and try again.',
///   actions: [
///     D3DialogAction(
///       label: 'OK',
///       isDefault: true,
///       onPressed: () => Navigator.pop(context),
///     ),
///   ],
/// );
/// ```
///
/// **No icon:**
/// Falls back to compact text button layout.
class D3Dialog extends StatelessWidget {
  const D3Dialog({
    super.key,
    this.icon,
    this.iconColor,
    this.iconPlacement = D3DialogIconPlacement.centered,
    this.title,
    this.message,
    this.content,
    required this.actions,
  }) : assert(
          actions.length > 0,
          'D3Dialog requires at least one action.',
        );

  /// Optional icon displayed above or beside the title.
  final IconData? icon;

  /// Color applied to the icon and its tinted background container.
  /// Defaults to [D3ColorTokens.primary] when null.
  final Color? iconColor;

  /// Whether the icon sits centred above the title or inline to its left.
  /// Defaults to [D3DialogIconPlacement.centered].
  /// Only relevant when [icon] is not null.
  final D3DialogIconPlacement iconPlacement;

  /// Bold title. Optional.
  final String? title;

  /// Secondary body text below the title. Optional.
  final String? message;

  /// Arbitrary widget rendered between the header and action row.
  final Widget? content;

  /// List of action buttons. At least one required.
  final List<D3DialogAction> actions;

  // ── Derived layout ─────────────────────────────────────────────────────────

  /// Stacked layout when there is a centered icon; text buttons otherwise.
  bool get _useStackedActions =>
      icon != null && iconPlacement == D3DialogIconPlacement.centered;

  // ── Static API ─────────────────────────────────────────────────────────────

  static Future<T?> show<T>(
    BuildContext context, {
    IconData? icon,
    Color? iconColor,
    D3DialogIconPlacement iconPlacement = D3DialogIconPlacement.centered,
    String? title,
    String? message,
    Widget? content,
    required List<D3DialogAction> actions,
    bool barrierDismissible = true,
    bool useRootNavigator = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      useRootNavigator: useRootNavigator,
      barrierColor: Colors.black54,
      builder: (_) => D3Dialog(
        icon: icon,
        iconColor: iconColor,
        iconPlacement: iconPlacement,
        title: title,
        message: message,
        content: content,
        actions: actions,
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    final effectiveIconColor = iconColor ?? colors.primary;
    final isCentered =
        icon != null && iconPlacement == D3DialogIconPlacement.centered;

    return Dialog(
      backgroundColor: colors.surfaceVariant,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(D3Radius.xl),
        side: BorderSide(
          color: colors.outline.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ─────────────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
              D3Spacing.s24,
              D3Spacing.s24,
              D3Spacing.s24,
              _useStackedActions ? D3Spacing.s20 : D3Spacing.s16,
            ),
            child: isCentered
                ? _CenteredIconHeader(
                    icon: icon!,
                    iconColor: effectiveIconColor,
                    title: title,
                    message: message,
                    colors: colors,
                  )
                : _LeadingIconHeader(
                    icon: icon,
                    iconColor: effectiveIconColor,
                    title: title,
                    message: message,
                    colors: colors,
                  ),
          ),

          // ── Custom content ─────────────────────────────────────────────────
          if (content != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                D3Spacing.s24,
                0,
                D3Spacing.s24,
                D3Spacing.s16,
              ),
              child: content,
            ),

          // ── Actions ────────────────────────────────────────────────────────
          if (_useStackedActions)
            _StackedActions(
              actions: actions,
              colors: colors,
            )
          else
            _InlineActions(
              actions: actions,
              colors: colors,
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header variants
// ─────────────────────────────────────────────────────────────────────────────

class _CenteredIconHeader extends StatelessWidget {
  const _CenteredIconHeader({
    required this.icon,
    required this.iconColor,
    this.title,
    this.message,
    required this.colors,
  });

  final IconData icon;
  final Color iconColor;
  final String? title;
  final String? message;
  final D3ColorTokens colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon container
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(D3Radius.lg),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 28, color: iconColor),
        ),

        if (title != null) ...[
          const SizedBox(height: D3Spacing.s16),
          Text(
            title!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
              letterSpacing: -0.2,
              height: 1.3,
            ),
          ),
        ],

        if (message != null) ...[
          const SizedBox(height: D3Spacing.s6),
          Text(
            message!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: colors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }
}

class _LeadingIconHeader extends StatelessWidget {
  const _LeadingIconHeader({
    this.icon,
    required this.iconColor,
    this.title,
    this.message,
    required this.colors,
  });

  final IconData? icon;
  final Color iconColor;
  final String? title;
  final String? message;
  final D3ColorTokens colors;

  @override
  Widget build(BuildContext context) {
    final hasIcon = icon != null;
    final textColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null)
          Text(
            title!,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
              letterSpacing: -0.2,
              height: 1.3,
            ),
          ),
        if (message != null) ...[
          if (title != null) const SizedBox(height: D3Spacing.s6),
          Text(
            message!,
            style: TextStyle(
              fontSize: 13,
              color: colors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ],
    );

    if (!hasIcon) return textColumn;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(D3Radius.sm),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: D3Spacing.s12),
        Expanded(child: textColumn),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Action layouts
// ─────────────────────────────────────────────────────────────────────────────

/// Full-width stacked buttons separated by a hairline divider.
/// Used when a centered icon is present.
class _StackedActions extends StatelessWidget {
  const _StackedActions({
    required this.actions,
    required this.colors,
  });

  final List<D3DialogAction> actions;
  final D3ColorTokens colors;

  @override
  Widget build(BuildContext context) {
    // Render primary/destructive action first (visually on top), then cancel.
    final sorted = [...actions]..sort((a, b) {
        if (a.isDefault || a.isDestructive) return -1;
        if (b.isDefault || b.isDestructive) return 1;
        return 0;
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Divider(
          height: 0.5,
          thickness: 0.5,
          color: colors.outline.withValues(alpha: 0.15),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            D3Spacing.s16,
            D3Spacing.s16,
            D3Spacing.s16,
            D3Spacing.s20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < sorted.length; i++) ...[
                if (i > 0) const SizedBox(height: D3Spacing.s8),
                _StackedButton(action: sorted[i], colors: colors),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _StackedButton extends StatelessWidget {
  const _StackedButton({required this.action, required this.colors});

  final D3DialogAction action;
  final D3ColorTokens colors;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;

    if (action.isDestructive) {
      bg = colors.error;
      fg = Colors.white;
    } else if (action.isDefault) {
      bg = colors.primary;
      fg = colors.onPrimary;
    } else {
      // Cancel / neutral
      bg = colors.onSurface.withValues(alpha: 0.10);
      fg = colors.onSurface;
    }

    return SizedBox(
      height: 46,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(D3Radius.md),
        child: InkWell(
          onTap: action.onPressed,
          borderRadius: BorderRadius.circular(D3Radius.md),
          splashColor: Colors.white.withValues(alpha: 0.08),
          highlightColor: Colors.white.withValues(alpha: 0.04),
          child: Center(
            child: Text(
              action.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: fg,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact right-aligned text buttons.
/// Used when there is no icon, or when iconPlacement is leading.
class _InlineActions extends StatelessWidget {
  const _InlineActions({
    required this.actions,
    required this.colors,
  });

  final List<D3DialogAction> actions;
  final D3ColorTokens colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        D3Spacing.s12,
        0,
        D3Spacing.s12,
        D3Spacing.s12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          for (int i = 0; i < actions.length; i++) ...[
            if (i > 0) const SizedBox(width: D3Spacing.s4),
            _InlineButton(action: actions[i], colors: colors),
          ],
        ],
      ),
    );
  }
}

class _InlineButton extends StatelessWidget {
  const _InlineButton({required this.action, required this.colors});

  final D3DialogAction action;
  final D3ColorTokens colors;

  Color get _labelColor {
    if (action.isDestructive) return colors.error;
    if (action.isDefault) return colors.primary;
    return colors.onSurfaceVariant;
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: action.onPressed,
      style: TextButton.styleFrom(
        foregroundColor: _labelColor,
        overlayColor: _labelColor,
        padding: const EdgeInsets.symmetric(
          horizontal: D3Spacing.s12,
          vertical: D3Spacing.s8,
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: TextStyle(
          fontSize: 14,
          fontWeight:
              action.isDefault ? FontWeight.w600 : FontWeight.w500,
          letterSpacing: 0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(D3Radius.sm),
        ),
      ),
      child: Text(action.label),
    );
  }
}
