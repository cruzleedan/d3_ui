import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:d3_ui/d3_ui.dart';

// ─────────────────────────────────────────────────────────────────────────────
// D3ToastVariant
// ─────────────────────────────────────────────────────────────────────────────

enum D3ToastVariant { success, error, warning, info, neutral }

// ─────────────────────────────────────────────────────────────────────────────
// D3ToastAction
// ─────────────────────────────────────────────────────────────────────────────

/// An optional action button rendered in the trailing slot of a [D3Toast].
class D3ToastAction {
  const D3ToastAction({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;
}

// ─────────────────────────────────────────────────────────────────────────────
// D3Toast
// ─────────────────────────────────────────────────────────────────────────────

/// Ephemeral feedback messages shown at the bottom of the screen.
///
/// Built on [ScaffoldMessenger] + [SnackBar] with a fully custom visual shell.
/// Requires a [Scaffold] ancestor.
///
/// **Static API:**
/// ```dart
/// D3Toast.show(
///   context,
///   title: 'Changes saved',
///   variant: D3ToastVariant.success,
/// );
///
/// D3Toast.error(
///   context,
///   title: 'Upload failed',
///   message: 'Check your connection and try again.',
///   action: D3ToastAction(label: 'Retry', onPressed: _retry),
/// );
/// ```
///
/// **Convenience shorthands:**
/// ```dart
/// D3Toast.success(context, title: 'Saved');
/// D3Toast.error(context,   title: 'Failed');
/// D3Toast.warning(context, title: 'Low storage');
/// D3Toast.info(context,    title: 'Tip: swipe to delete');
/// ```
class D3Toast {
  D3Toast._();

  // ── Durations ──────────────────────────────────────────────────────────────

  static const _shortDuration = Duration(seconds: 3);
  static const _longDuration = Duration(seconds: 5);

  static Duration _durationFor(D3ToastVariant variant) =>
      (variant == D3ToastVariant.error || variant == D3ToastVariant.warning)
      ? _longDuration
      : _shortDuration;

  // ── show ──────────────────────────────────────────────────────────────────

  /// Shows a toast message. Clears any currently visible toast first.
  ///
  /// [duration] defaults to 3 s for success/info/neutral and 5 s for
  /// error/warning. Pass `Duration.zero` to keep the toast on screen until
  /// the user dismisses it manually.
  static void show(
    BuildContext context, {
    required String title,
    String? message,
    D3ToastVariant variant = D3ToastVariant.neutral,
    D3ToastAction? action,
    Duration? duration,
  }) {
    HapticFeedback.lightImpact();

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    final effectiveDuration = duration ?? _durationFor(variant);

    messenger.showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
        // Floating above the nav bar with horizontal margin
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(
          D3Spacing.s16,
          0,
          D3Spacing.s16,
          D3Spacing.s16,
        ),
        // Dismiss on swipe in any direction
        dismissDirection: DismissDirection.horizontal,
        duration: effectiveDuration == Duration.zero
            ? const Duration(days: 365) // effectively infinite
            : effectiveDuration,
        content: _D3ToastContent(
          title: title,
          message: message,
          variant: variant,
          action: action,
          onDismiss: () => messenger.hideCurrentSnackBar(),
        ),
      ),
    );
  }

  // ── Convenience shorthands ────────────────────────────────────────────────

  static void success(
    BuildContext context, {
    required String title,
    String? message,
    D3ToastAction? action,
    Duration? duration,
  }) => show(
    context,
    title: title,
    message: message,
    variant: D3ToastVariant.success,
    action: action,
    duration: duration,
  );

  static void error(
    BuildContext context, {
    required String title,
    String? message,
    D3ToastAction? action,
    Duration? duration,
  }) => show(
    context,
    title: title,
    message: message,
    variant: D3ToastVariant.error,
    action: action,
    duration: duration,
  );

  static void warning(
    BuildContext context, {
    required String title,
    String? message,
    D3ToastAction? action,
    Duration? duration,
  }) => show(
    context,
    title: title,
    message: message,
    variant: D3ToastVariant.warning,
    action: action,
    duration: duration,
  );

  static void info(
    BuildContext context, {
    required String title,
    String? message,
    D3ToastAction? action,
    Duration? duration,
  }) => show(
    context,
    title: title,
    message: message,
    variant: D3ToastVariant.info,
    action: action,
    duration: duration,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// _D3ToastContent — visual shell
// ─────────────────────────────────────────────────────────────────────────────

class _D3ToastContent extends StatelessWidget {
  const _D3ToastContent({
    required this.title,
    required this.message,
    required this.variant,
    required this.action,
    required this.onDismiss,
  });

  final String title;
  final String? message;
  final D3ToastVariant variant;
  final D3ToastAction? action;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    final style = _ToastStyle.of(variant, colors);

    return Material(
      color: style.background,
      borderRadius: BorderRadius.circular(D3Radius.lg),
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(D3Radius.lg),
          border: Border.all(color: style.border, width: 1.0),
        ),
        padding: const EdgeInsets.fromLTRB(
          D3Spacing.s12,
          D3Spacing.s12,
          D3Spacing.s8,
          D3Spacing.s12,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: style.iconBackground,
                ),
                alignment: Alignment.center,
                child: Icon(style.icon, size: 14, color: style.iconForeground),
              ),
            ),
            const SizedBox(width: D3Spacing.s10),

            // Text block
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: style.titleColor,
                      height: 1.3,
                    ),
                  ),
                  if (message != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      message!,
                      style: TextStyle(
                        fontSize: 12,
                        color: style.messageColor,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Action button
            if (action != null) ...[
              const SizedBox(width: D3Spacing.s8),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  onDismiss();
                  action!.onPressed();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: D3Spacing.s4,
                    vertical: D3Spacing.s2,
                  ),
                  child: Text(
                    action!.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: style.actionColor,
                    ),
                  ),
                ),
              ),
            ],

            // Dismiss button
            const SizedBox(width: D3Spacing.s4),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onDismiss,
              child: Padding(
                padding: const EdgeInsets.all(D3Spacing.s4),
                child: Icon(
                  Icons.close_rounded,
                  size: 15,
                  color: style.titleColor.withValues(alpha: 0.45),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ToastStyle — per-variant color bundle
// ─────────────────────────────────────────────────────────────────────────────

class _ToastStyle {
  const _ToastStyle({
    required this.background,
    required this.border,
    required this.icon,
    required this.iconForeground,
    required this.iconBackground,
    required this.titleColor,
    required this.messageColor,
    required this.actionColor,
  });

  final Color background;
  final Color border;
  final IconData icon;
  final Color iconForeground;
  final Color iconBackground;
  final Color titleColor;
  final Color messageColor;
  final Color actionColor;

  /// Builds a tinted style from an accent color, blended onto `colors.surface`
  /// so the chip is always opaque (never see-through to whatever's behind the
  /// floating SnackBar) and readable in both themes. Title/message text uses
  /// `colors.onSurface`/`colors.onSurfaceVariant` rather than a fixed accent
  /// shade — those are guaranteed to contrast against `colors.surface` by
  /// construction, whereas a hardcoded pastel only reads correctly against
  /// whichever single background brightness it was picked for.
  static _ToastStyle _tinted({
    required Color accent,
    required IconData icon,
    required D3ColorTokens colors,
  }) {
    return _ToastStyle(
      background: Color.alphaBlend(
        accent.withValues(alpha: 0.16),
        colors.surface,
      ),
      border: Color.alphaBlend(accent.withValues(alpha: 0.40), colors.surface),
      icon: icon,
      iconForeground: accent,
      iconBackground: Color.alphaBlend(
        accent.withValues(alpha: 0.28),
        colors.surface,
      ),
      titleColor: colors.onSurface,
      messageColor: colors.onSurfaceVariant,
      actionColor: accent,
    );
  }

  factory _ToastStyle.of(D3ToastVariant variant, D3ColorTokens colors) {
    switch (variant) {
      case D3ToastVariant.success:
        return _tinted(
          accent: colors.success,
          icon: Icons.check_circle_outline_rounded,
          colors: colors,
        );

      case D3ToastVariant.error:
        return _tinted(
          accent: colors.error,
          icon: Icons.error_outline_rounded,
          colors: colors,
        );

      case D3ToastVariant.warning:
        return _tinted(
          accent: colors.warning,
          icon: Icons.warning_amber_rounded,
          colors: colors,
        );

      case D3ToastVariant.info:
        return _tinted(
          accent: colors.primary,
          icon: Icons.info_outline_rounded,
          colors: colors,
        );

      case D3ToastVariant.neutral:
        final bg = Color.alphaBlend(
          colors.onSurface.withValues(alpha: 0.08),
          colors.surface,
        );
        return _ToastStyle(
          background: bg,
          border: colors.outline.withValues(alpha: 0.40),
          icon: Icons.info_outline_rounded,
          iconForeground: colors.onSurfaceVariant,
          iconBackground: colors.onSurface.withValues(alpha: 0.10),
          titleColor: colors.onSurface,
          messageColor: colors.onSurfaceVariant,
          actionColor: colors.primary,
        );
    }
  }
}
