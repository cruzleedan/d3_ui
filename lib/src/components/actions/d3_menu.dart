import 'package:d3_ui/d3_ui.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// One entry of a [D3Menu]: a [D3MenuItem], [D3MenuDivider] or
/// [D3MenuSection].
sealed class D3MenuEntry {
  const D3MenuEntry();
}

/// A selectable row of a [D3Menu].
///
/// The menu closes first, then [onPressed] runs once. A disabled item is
/// dimmed, skipped by keyboard navigation and ignores taps.
class D3MenuItem extends D3MenuEntry {
  const D3MenuItem({
    required this.label,
    this.icon,
    this.shortcut,
    this.isDestructive = false,
    this.isSelected = false,
    this.enabled = true,
    this.onPressed,
  });

  /// The row's text.
  final String label;

  /// Optional leading icon.
  final IconData? icon;

  /// Optional trailing hint such as `Ctrl+C`. Shown on wider menus; it is
  /// also part of the semantics label.
  final String? shortcut;

  /// Renders the row in the error colour, for "Delete" and similar.
  final bool isDestructive;

  /// Shows a trailing check and reports the row as selected.
  final bool isSelected;

  /// A disabled row is dimmed and cannot be chosen.
  final bool enabled;

  /// Called after the menu has closed.
  final VoidCallback? onPressed;
}

/// A hairline that separates groups of items in a [D3Menu].
class D3MenuDivider extends D3MenuEntry {
  const D3MenuDivider();
}

/// A non-interactive heading that labels the items below it.
class D3MenuSection extends D3MenuEntry {
  const D3MenuSection(this.label);

  /// The heading text.
  final String label;
}

/// An overflow or context menu anchored to a trigger.
///
/// The menu opens with a short scale and fade from the trigger corner, flips
/// above the trigger when there is no room below, shifts to stay fully on
/// screen, scrolls when taller than the space available, and follows the
/// trigger while a parent scrolls. It closes on a tap outside, Escape, a
/// selection or the back gesture; the item callback runs after it has closed.
/// Up and down arrows move between enabled items, Enter and Space select.
/// With reduced motion (`MediaQuery.disableAnimationsOf`) it opens instantly.
///
/// ```dart
/// D3Menu(
///   alignment: Alignment.topRight,
///   triggerBuilder: (context, toggle) =>
///       D3Button(label: 'Sort', onPressed: toggle),
///   entries: [
///     const D3MenuSection('Sort by'),
///     D3MenuItem(label: 'Name', isSelected: true, onPressed: () {}),
///     const D3MenuDivider(),
///     D3MenuItem(
///       label: 'Delete',
///       icon: Icons.delete_outline,
///       isDestructive: true,
///       onPressed: () {},
///     ),
///   ],
/// )
/// ```
///
/// For the common three-dot button use [D3MenuButton].
class D3Menu extends StatefulWidget {
  const D3Menu({
    super.key,
    required this.triggerBuilder,
    required this.entries,
    this.alignment = Alignment.topRight,
    this.width,
  });

  /// Builds the trigger. Call `toggle` to open or close the menu. The trigger
  /// should be at least 48 x 48 dp.
  final Widget Function(BuildContext context, VoidCallback toggle)
  triggerBuilder;

  /// The rows of the menu.
  final List<D3MenuEntry> entries;

  /// The menu corner that attaches to the trigger. `x` below 0 lines the menu's
  /// left edge up with the trigger's left edge, otherwise the right edges line
  /// up. `y` above 0 prefers opening upwards, otherwise downwards. Whatever the
  /// preference, the menu flips when it does not fit.
  final Alignment alignment;

  /// The menu width; defaults to 224 dp, never wider than the screen minus
  /// 16 dp.
  final double? width;

  @override
  State<D3Menu> createState() => _D3MenuState();
}

class _D3MenuState extends State<D3Menu> with SingleTickerProviderStateMixin {
  static const double _margin = 8;
  static const double _gap = 4;
  static const double _defaultWidth = 224;

  final _portal = OverlayPortalController();
  final _link = LayerLink();
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: D3Motion.fast,
  );
  late final Animation<double> _curve = CurvedAnimation(
    parent: _ctrl,
    curve: D3Motion.decelerate,
    reverseCurve: D3Motion.accelerate,
  );

  bool _open = false;
  FocusNode? _returnFocus;

  // Geometry fixed when the menu opens.
  double _menuWidth = _defaultWidth;
  double _maxHeight = 400;
  Offset _offset = Offset.zero;
  bool _above = false;
  Alignment _origin = Alignment.topRight;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  double _estimatedHeight() {
    var h = 16.0;
    for (final e in widget.entries) {
      h += switch (e) {
        D3MenuItem() => 48,
        D3MenuDivider() => 9,
        D3MenuSection() => 36,
      };
    }
    return h;
  }

  void _openMenu() {
    if (_open) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final media = MediaQuery.of(context);
    final screen = media.size;
    final origin = box.localToGlobal(Offset.zero);
    final rect = origin & box.size;

    final menuW = (widget.width ?? _defaultWidth).clamp(
      0.0,
      screen.width - 2 * _margin,
    );
    final endAligned = widget.alignment.x >= 0;
    final desiredLeft = endAligned ? rect.right - menuW : rect.left;
    final left = desiredLeft.clamp(
      _margin,
      (screen.width - _margin - menuW).clamp(_margin, double.infinity),
    );

    final below =
        screen.height - media.padding.bottom - rect.bottom - _gap - _margin;
    final above = rect.top - media.padding.top - _gap - _margin;
    final est = _estimatedHeight();
    final preferAbove = widget.alignment.y > 0;
    bool goAbove;
    if (preferAbove) {
      goAbove = est <= above || (est > below && above > below);
    } else {
      goAbove = est > below && above > below;
    }

    _menuWidth = menuW;
    _above = goAbove;
    _maxHeight = (goAbove ? above : below).clamp(96.0, double.infinity);
    _offset = Offset(left - rect.left, goAbove ? -_gap : _gap);
    _origin = Alignment(endAligned ? 1 : -1, goAbove ? 1 : -1);
    _returnFocus = FocusManager.instance.primaryFocus;

    final reduced = MediaQuery.disableAnimationsOf(context);
    _ctrl.duration = reduced ? Duration.zero : D3Motion.fast;
    setState(() => _open = true);
    _portal.show();
    _ctrl.forward();
  }

  void _close({VoidCallback? then}) {
    if (!_open) return;
    _open = false;
    if (mounted) setState(() {});
    final focus = _returnFocus;
    _returnFocus = null;
    _ctrl.reverse().whenComplete(() {
      if (mounted) {
        _portal.hide();
        if (focus != null && focus.canRequestFocus && focus.context != null) {
          focus.requestFocus();
        }
      }
      then?.call();
    });
  }

  void _toggle() => _open ? _close() : _openMenu();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_open,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: CompositedTransformTarget(
        link: _link,
        child: OverlayPortal(
          controller: _portal,
          overlayChildBuilder: _buildOverlay,
          child: widget.triggerBuilder(context, _toggle),
        ),
      ),
    );
  }

  Widget _buildOverlay(BuildContext overlayContext) {
    final colors = overlayContext.d3Colors;
    final shape = overlayContext.d3Shape;
    final fill = colors.surfaceContainerHigh;

    final entries = widget.entries;
    var firstEnabled = -1;
    for (var i = 0; i < entries.length; i++) {
      final e = entries[i];
      if (e is D3MenuItem && e.enabled) {
        firstEnabled = i;
        break;
      }
    }

    final rows = <Widget>[
      for (var i = 0; i < entries.length; i++)
        switch (entries[i]) {
          final D3MenuItem item => _MenuRow(
            item: item,
            fill: fill,
            autofocus: i == firstEnabled,
            onSelected: () => _close(then: item.onPressed),
          ),
          D3MenuDivider() => Divider(
            height: 9,
            thickness: 1,
            color: colors.outlineVariant,
          ),
          final D3MenuSection s => _SectionHeader(label: s.label),
        },
    ];

    final panel = Material(
      color: fill,
      elevation: 3,
      shadowColor: colors.scrim,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: shape.circularMd,
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: Semantics(
        role: SemanticsRole.menu,
        explicitChildNodes: true,
        scopesRoute: true,
        child: FocusScope(
          autofocus: true,
          child: FocusTraversalGroup(
            policy: OrderedTraversalPolicy(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: D3Spacing.s8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < rows.length; i++)
                    FocusTraversalOrder(
                      order: NumericFocusOrder(i.toDouble()),
                      child: rows[i],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.arrowDown): NextFocusIntent(),
        SingleActivator(LogicalKeyboardKey.arrowUp): PreviousFocusIntent(),
        SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
      },
      child: Actions(
        actions: {
          DismissIntent: CallbackAction<DismissIntent>(
            onInvoke: (_) {
              _close();
              return null;
            },
          ),
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _close,
                child: const SizedBox.expand(),
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              child: CompositedTransformFollower(
                link: _link,
                showWhenUnlinked: false,
                targetAnchor: _above ? Alignment.topLeft : Alignment.bottomLeft,
                followerAnchor: _above
                    ? Alignment.bottomLeft
                    : Alignment.topLeft,
                offset: _offset,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: _menuWidth,
                    maxWidth: _menuWidth,
                    maxHeight: _maxHeight,
                  ),
                  child: ExcludeFocus(
                    excluding: !_open,
                    child: FadeTransition(
                      opacity: _curve,
                      child: ScaleTransition(
                        alignment: _origin,
                        scale: Tween<double>(
                          begin: 0.92,
                          end: 1,
                        ).animate(_curve),
                        child: panel,
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
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    return Semantics(
      header: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          D3Spacing.s16,
          D3Spacing.s8,
          D3Spacing.s16,
          D3Spacing.s4,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: d3EnsureContrast(
              colors.onSurfaceVariant,
              colors.surfaceContainerHigh,
            ),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.item,
    required this.fill,
    required this.autofocus,
    required this.onSelected,
  });

  final D3MenuItem item;
  final Color fill;
  final bool autofocus;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    final text = Theme.of(context).textTheme;
    final enabled = item.enabled;
    final labelColor = item.isDestructive
        ? d3EnsureContrast(colors.error, fill)
        : colors.onSurface;
    final iconColor = item.isDestructive ? labelColor : colors.onSurfaceVariant;
    final accent = d3EnsureContrast(colors.primary, fill, minRatio: 3);
    final shortcutColor = d3EnsureContrast(colors.onSurfaceVariant, fill);

    Widget row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: D3Spacing.s48),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: D3Spacing.s16,
          vertical: D3Spacing.s8,
        ),
        child: Row(
          children: [
            if (item.icon != null) ...[
              Icon(item.icon, size: 24, color: iconColor),
              const SizedBox(width: D3Spacing.s12),
            ],
            Expanded(
              flex: 2,
              child: Text(
                item.label,
                style: text.bodyLarge?.copyWith(
                  color: labelColor,
                  fontWeight: item.isSelected
                      ? FontWeight.w600
                      : FontWeight.w500,
                ),
              ),
            ),
            if (item.shortcut != null) ...[
              const SizedBox(width: D3Spacing.s12),
              Flexible(
                child: Text(
                  item.shortcut!,
                  textAlign: TextAlign.end,
                  style: text.bodySmall?.copyWith(color: shortcutColor),
                ),
              ),
            ],
            if (item.isSelected) ...[
              const SizedBox(width: D3Spacing.s12),
              Icon(Icons.check_rounded, size: 24, color: accent),
            ],
          ],
        ),
      ),
    );
    if (!enabled) row = Opacity(opacity: 0.38, child: row);

    final label = [
      item.label,
      if (item.shortcut != null) item.shortcut!,
    ].join(', ');

    return Semantics(
      role: SemanticsRole.menuItem,
      container: true,
      button: true,
      enabled: enabled,
      selected: item.isSelected,
      label: label,
      hint: item.isDestructive ? 'destructive' : null,
      excludeSemantics: true,
      onTap: enabled ? onSelected : null,
      child: InkWell(
        autofocus: autofocus,
        onTap: enabled ? onSelected : null,
        overlayColor: WidgetStatePropertyAll(
          labelColor.withValues(alpha: 0.10),
        ),
        child: row,
      ),
    );
  }
}

/// A 48 dp icon button that opens a [D3Menu], the usual "more options"
/// overflow control.
///
/// ```dart
/// D3MenuButton(
///   entries: [
///     D3MenuItem(label: 'Rename', icon: Icons.edit_outlined, onPressed: () {}),
///     const D3MenuDivider(),
///     D3MenuItem(
///       label: 'Delete',
///       isDestructive: true,
///       onPressed: () {},
///     ),
///   ],
/// )
/// ```
class D3MenuButton extends StatelessWidget {
  const D3MenuButton({
    super.key,
    required this.entries,
    this.icon = Icons.more_vert_rounded,
    this.semanticsLabel = 'More options',
  });

  /// The rows of the menu.
  final List<D3MenuEntry> entries;

  /// The trigger icon.
  final IconData icon;

  /// The accessibility label (and tooltip) of the trigger.
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return D3Menu(
      entries: entries,
      // D3Tooltip, not IconButton's own: it is styled from the tokens and hides
      // when the button is pressed, so it never sits on top of the open menu.
      // The icon's semanticLabel names the button for screen readers.
      triggerBuilder: (context, toggle) => D3Tooltip(
        message: semanticsLabel,
        child: IconButton(
          onPressed: toggle,
          constraints: const BoxConstraints.tightFor(width: 48, height: 48),
          icon: Icon(icon, semanticLabel: semanticsLabel),
        ),
      ),
    );
  }
}
