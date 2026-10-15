import 'package:material_ui/material_ui.dart';
import 'package:d3_ui/d3_ui.dart';

/// The tone of a [D3Banner].
enum D3BannerVariant { info, success, warning, error }

/// A text button shown inside a [D3Banner]. Its tap target is at least 48 dp.
class D3BannerAction {
  const D3BannerAction({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;
}

/// A persistent inline message that sits in the page.
///
/// Use it between the transient [D3Toast] and the blocking [D3Dialog]: it
/// stays until the problem is fixed or the user dismisses it. Text wraps and
/// the banner grows with the text scale. It is announced to screen readers as
/// a live region, and animates in (size and fade) unless the platform asks
/// for reduced motion.
///
/// ```dart
/// D3Banner(
///   variant: D3BannerVariant.warning,
///   title: 'You are offline',
///   message: 'Changes will sync when you reconnect.',
///   action: D3BannerAction(label: 'Retry', onPressed: _retry),
///   onDismiss: () => setState(() => _show = false),
/// )
/// ```
class D3Banner extends StatefulWidget {
  const D3Banner({
    super.key,
    required this.message,
    this.title,
    this.variant = D3BannerVariant.info,
    this.icon,
    this.action,
    this.onDismiss,
    this.compact = false,
  });

  /// The body text.
  final String message;

  /// An optional bold heading above [message].
  final String? title;

  final D3BannerVariant variant;

  /// Replaces the variant's default leading icon.
  final IconData? icon;

  /// An optional text button below the message.
  final D3BannerAction? action;

  /// When set, a 48 dp close button is shown and calls this.
  final VoidCallback? onDismiss;

  /// Tighter padding and a smaller icon, for dense screens.
  final bool compact;

  @override
  State<D3Banner> createState() => _D3BannerState();
}

class _D3BannerState extends State<D3Banner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: D3Motion.base,
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = D3BannerStyle.of(context, widget.variant);
    final shape = context.d3Shape;
    final compact = widget.compact;
    final curved = CurvedAnimation(parent: _controller, curve: D3Motion.enter);

    final content = Material(
      color: style.background,
      shape: RoundedRectangleBorder(
        borderRadius: shape.circularLg,
        side: BorderSide(color: style.border),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          compact ? D3Spacing.s10 : D3Spacing.s12,
          compact ? D3Spacing.s6 : D3Spacing.s12,
          widget.onDismiss != null ? D3Spacing.s4 : D3Spacing.s12,
          compact ? D3Spacing.s6 : D3Spacing.s12,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: ExcludeSemantics(
                child: Icon(
                  widget.icon ?? style.icon,
                  size: compact ? 18 : 22,
                  color: style.accent,
                ),
              ),
            ),
            SizedBox(width: compact ? D3Spacing.s8 : D3Spacing.s10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.title != null)
                    Text(
                      widget.title!,
                      style: TextStyle(
                        fontSize: compact ? 13 : 14,
                        fontWeight: FontWeight.w600,
                        color: style.titleColor,
                        height: 1.3,
                      ),
                    ),
                  Text(
                    widget.message,
                    style: TextStyle(
                      fontSize: compact ? 12 : 13,
                      color: style.messageColor,
                      height: 1.4,
                    ),
                  ),
                  if (widget.action != null)
                    _BannerTextButton(
                      label: widget.action!.label,
                      color: style.accent,
                      onPressed: widget.action!.onPressed,
                    ),
                ],
              ),
            ),
            if (widget.onDismiss != null)
              Semantics(
                button: true,
                label: 'Dismiss',
                excludeSemantics: true,
                child: SizedBox(
                  width: D3Spacing.s48,
                  height: D3Spacing.s48,
                  child: Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      onTap: widget.onDismiss,
                      customBorder: const CircleBorder(),
                      child: Center(
                        child: Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: style.messageColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    return Semantics(
      container: true,
      liveRegion: true,
      child: SizeTransition(
        sizeFactor: curved,
        alignment: Alignment.topCenter,
        child: FadeTransition(opacity: curved, child: content),
      ),
    );
  }
}

class _BannerTextButton extends StatelessWidget {
  const _BannerTextButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Semantics(
        button: true,
        excludeSemantics: true,
        label: label,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onPressed,
            borderRadius: context.d3Shape.circularSm,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: D3Spacing.s48,
                minHeight: D3Spacing.s48,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: D3Spacing.s8),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  widthFactor: 1,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The resolved colours of a [D3Banner] variant. Public so tests and custom
/// layouts can check contrast against [background].
class D3BannerStyle {
  const D3BannerStyle({
    required this.background,
    required this.border,
    required this.accent,
    required this.icon,
    required this.titleColor,
    required this.messageColor,
  });

  /// Opaque tint of the variant colour over the surface.
  final Color background;
  final Color border;

  /// Icon and action colour, lifted to read as text on [background].
  final Color accent;
  final IconData icon;
  final Color titleColor;
  final Color messageColor;

  factory D3BannerStyle.of(BuildContext context, D3BannerVariant variant) {
    final colors = context.d3Colors;
    final status = context.d3Status;
    final (Color base, IconData icon) = switch (variant) {
      D3BannerVariant.info => (colors.primary, Icons.info_outline_rounded),
      D3BannerVariant.success => (
        status.success.text,
        Icons.check_circle_outline_rounded,
      ),
      D3BannerVariant.warning => (
        status.warning.text,
        Icons.warning_amber_rounded,
      ),
      D3BannerVariant.error => (
        status.destructive.text,
        Icons.error_outline_rounded,
      ),
    };
    final background = Color.alphaBlend(
      base.withValues(alpha: 0.16),
      colors.surface,
    );
    return D3BannerStyle(
      background: background,
      border: Color.alphaBlend(base.withValues(alpha: 0.40), colors.surface),
      accent: d3EnsureContrast(base, background),
      icon: icon,
      titleColor: d3EnsureContrast(colors.onSurface, background),
      messageColor: d3EnsureContrast(colors.onSurfaceVariant, background),
    );
  }
}
