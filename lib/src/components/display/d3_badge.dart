import 'package:material_ui/material_ui.dart';
import 'package:d3_ui/d3_ui.dart';

/// The colour of a [D3Badge].
enum D3BadgeVariant { primary, success, warning, error, neutral }

enum _BadgeKind { count, dot, label }

/// A small count, dot or status pill.
///
/// ```dart
/// D3Badge.count(3, semanticsLabel: '3 notifications')
/// D3Badge.dot(semanticsLabel: 'Unread')
/// D3Badge.label('New', variant: D3BadgeVariant.success)
///
/// // Overlaid on the corner of any widget, without changing its size:
/// D3Badge.on(
///   child: IconButton(icon: Icon(Icons.notifications), onPressed: _open),
///   badge: D3Badge.count(3, semanticsLabel: '3 notifications'),
/// )
/// ```
///
/// Counts and dots are solid; labels are tinted pills like a status chip.
/// Text meets 4.5:1 contrast in light and dark, and grows with the text scale.
class D3Badge extends StatelessWidget {
  /// A number, shown as `max+` above [max]. A zero count is hidden unless
  /// [showZero] is true.
  const D3Badge.count(
    this.count, {
    super.key,
    this.max = 99,
    this.showZero = false,
    this.variant = D3BadgeVariant.error,
    this.semanticsLabel,
  }) : _kind = _BadgeKind.count,
       text = null;

  /// A small dot with no text.
  const D3Badge.dot({
    super.key,
    this.variant = D3BadgeVariant.error,
    this.semanticsLabel,
  }) : _kind = _BadgeKind.dot,
       count = 0,
       max = 99,
       showZero = false,
       text = null;

  /// A short status pill such as "New" or "Paused".
  const D3Badge.label(
    String this.text, {
    super.key,
    this.variant = D3BadgeVariant.primary,
    this.semanticsLabel,
  }) : _kind = _BadgeKind.label,
       count = 0,
       max = 99,
       showZero = false;

  /// Overlays [badge] at a corner of [child]. See [D3BadgeAnchor].
  static Widget on({
    Key? key,
    required Widget child,
    required Widget badge,
    Alignment alignment = Alignment.topRight,
  }) =>
      D3BadgeAnchor(key: key, badge: badge, alignment: alignment, child: child);

  final _BadgeKind _kind;
  final int count;
  final int max;
  final bool showZero;
  final String? text;
  final D3BadgeVariant variant;

  /// What a screen reader says, for example "3 notifications". Defaults to
  /// the visible text; a dot has no default and should be given one.
  final String? semanticsLabel;

  /// The text a count badge shows, or null when it is hidden.
  String? get _countText {
    if (count <= 0 && !showZero) return null;
    return count > max ? '$max+' : '$count';
  }

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    widthFactor: 1,
    heightFactor: 1,
    child: _buildBadge(context),
  );

  Widget _buildBadge(BuildContext context) {
    switch (_kind) {
      case _BadgeKind.dot:
        final s = _BadgeStyle.solid(context, variant);
        return Semantics(
          label: semanticsLabel,
          container: true,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: s.background,
              shape: BoxShape.circle,
              border: Border.all(color: context.d3Colors.surface, width: 1.5),
            ),
          ),
        );
      case _BadgeKind.count:
        final t = _countText;
        if (t == null) return const SizedBox.shrink();
        final s = _BadgeStyle.solid(context, variant);
        return Semantics(
          label: semanticsLabel ?? t,
          container: true,
          excludeSemantics: true,
          child: Container(
            constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
            padding: const EdgeInsets.symmetric(
              horizontal: D3Spacing.s4 + 1,
              vertical: 1,
            ),
            decoration: BoxDecoration(
              color: s.background,
              borderRadius: D3Radius.circularFull,
            ),
            child: Center(
              widthFactor: 1,
              heightFactor: 1,
              child: Text(
                t,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: s.foreground,
                  height: 1.2,
                ),
              ),
            ),
          ),
        );
      case _BadgeKind.label:
        final s = _BadgeStyle.tinted(context, variant);
        return Semantics(
          label: semanticsLabel ?? text,
          container: true,
          excludeSemantics: true,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: D3Spacing.s8,
              vertical: D3Spacing.s2,
            ),
            decoration: BoxDecoration(
              color: s.background,
              borderRadius: D3Radius.circularFull,
              border: Border.all(color: s.border),
            ),
            child: Text(
              text!,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: s.foreground,
                height: 1.3,
              ),
            ),
          ),
        );
    }
  }
}

/// Overlays a badge at a corner of [child] without changing the child's
/// layout: the anchor is exactly as large as [child], and the badge may
/// overflow its edge.
///
/// ```dart
/// D3BadgeAnchor(
///   badge: D3Badge.count(12, semanticsLabel: '12 messages'),
///   child: IconButton(icon: Icon(Icons.mail), onPressed: _open),
/// )
/// ```
class D3BadgeAnchor extends StatelessWidget {
  const D3BadgeAnchor({
    super.key,
    required this.child,
    required this.badge,
    this.alignment = Alignment.topRight,
    this.offset = Offset.zero,
  });

  final Widget child;
  final Widget badge;

  /// Which corner of [child] the badge centre sits on.
  final Alignment alignment;

  /// Extra nudge, for example `Offset(-6, 6)` to tuck it inside a 48 dp
  /// button's visible icon.
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: Align(
              alignment: alignment,
              child: FractionalTranslation(
                translation: Offset(
                  alignment.x == 0 ? 0 : alignment.x * 0.5,
                  alignment.y == 0 ? 0 : alignment.y * 0.5,
                ),
                child: Transform.translate(offset: offset, child: badge),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BadgeStyle {
  const _BadgeStyle(this.background, this.foreground, this.border);

  final Color background;
  final Color foreground;
  final Color border;

  static _BadgeStyle solid(BuildContext context, D3BadgeVariant v) {
    final c = context.d3Colors;
    final (bg, on) = switch (v) {
      D3BadgeVariant.primary => (c.primary, c.onPrimary),
      D3BadgeVariant.success => (c.success, c.onSuccess),
      D3BadgeVariant.warning => (c.warning, c.onWarning),
      D3BadgeVariant.error => (c.error, c.onError),
      D3BadgeVariant.neutral => (c.onSurfaceVariant, c.surface),
    };
    var fg = d3EnsureContrast(on, bg);
    if (d3ContrastRatio(fg, bg) < 4.5) {
      // Mid-tone fills: the nearest shade may not reach AA, so use whichever
      // of black and white reads better.
      const black = Color(0xFF000000);
      const white = Color(0xFFFFFFFF);
      fg = d3ContrastRatio(black, bg) >= d3ContrastRatio(white, bg)
          ? black
          : white;
    }
    return _BadgeStyle(bg, fg, bg);
  }

  static _BadgeStyle tinted(BuildContext context, D3BadgeVariant v) {
    final c = context.d3Colors;
    final s = context.d3Status;
    final D3StatusColor status = switch (v) {
      D3BadgeVariant.primary => D3StatusColor(
        text: c.primary,
        tint: c.primary.withValues(alpha: 0.15),
        border: c.primary.withValues(alpha: 0.5),
      ),
      D3BadgeVariant.success => s.success,
      D3BadgeVariant.warning => s.warning,
      D3BadgeVariant.error => s.destructive,
      D3BadgeVariant.neutral => s.neutral,
    };
    return _BadgeStyle(
      Color.alphaBlend(status.tint, c.surface),
      status.readableTextOn(c.surface),
      status.border,
    );
  }
}
