import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:d3_ui/d3_ui.dart';

/// A vertical navigation rail: the same destinations as [D3NavBar], for
/// medium and expanded windows (see [D3WindowSizeClass]).
///
/// It uses [D3NavItem], so one list of destinations can feed a [D3NavBar] on a
/// compact window and a [D3NavRail] on a larger one. The selected destination
/// has the same pill, badges are the same, and an item with no label of its own
/// still reads through its semantics label.
///
/// ```dart
/// D3NavRail(
///   selectedIndex: _tab,
///   onDestinationSelected: (i) => setState(() => _tab = i),
///   leading: D3ScrimIconButton(...),          // optional: a menu or an action
///   items: const [
///     D3NavItem(icon: Icons.explore_outlined, label: 'Explore'),
///     D3NavItem(icon: Icons.favorite_border, label: 'Saved', badgeCount: 2),
///   ],
/// )
/// ```
///
/// With [extended] the labels sit beside the icons and the rail widens, which
/// suits expanded windows.
class D3NavRail extends StatelessWidget {
  const D3NavRail({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.leading,
    this.trailing,
    this.extended = false,
  }) : assert(items.length >= 2, 'D3NavRail needs at least 2 items.');

  final List<D3NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  /// Shown above the destinations (a menu button or a primary action).
  final Widget? leading;

  /// Shown at the bottom of the rail (settings, an account).
  final Widget? trailing;

  /// Labels beside the icons, in a wider rail.
  final bool extended;

  /// The rail's width.
  static const double collapsedWidth = 80;
  static const double extendedWidth = 220;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    return Material(
      color: colors.surfaceVariant,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              color: colors.outline.withValues(alpha: 0.15),
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            width: extended ? extendedWidth : collapsedWidth,
            child: Column(
              crossAxisAlignment: extended
                  ? CrossAxisAlignment.stretch
                  : CrossAxisAlignment.center,
              children: [
                if (leading != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 4),
                    child: leading,
                  ),
                const SizedBox(height: 8),
                for (var i = 0; i < items.length; i++)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: extended ? 12 : 0,
                      vertical: 2,
                    ),
                    child: _RailItem(
                      item: items[i],
                      selected: i == selectedIndex,
                      extended: extended,
                      colors: colors,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onDestinationSelected(i);
                      },
                    ),
                  ),
                const Spacer(),
                if (trailing != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: trailing,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.item,
    required this.selected,
    required this.extended,
    required this.colors,
    required this.onTap,
  });

  final D3NavItem item;
  final bool selected;
  final bool extended;
  final D3ColorTokens colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = selected ? (item.activeIcon ?? item.icon) : item.icon;
    final color = selected ? colors.primary : colors.onSurfaceVariant;
    final weight = selected ? FontWeight.w600 : FontWeight.w400;

    final iconWithBadge = Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon, size: 22, color: color),
        if (item.badgeCount != null || item.badgeLabel != null)
          Positioned(
            top: -6,
            right: -10,
            child: _RailBadge(count: item.badgeCount, label: item.badgeLabel),
          ),
      ],
    );

    final pillColor = selected ? colors.primaryContainer : Colors.transparent;
    final splash = colors.primary.withValues(alpha: 0.14);
    final highlight = colors.primary.withValues(alpha: 0.08);

    final Widget body;
    if (extended) {
      body = Material(
        color: pillColor,
        borderRadius: BorderRadius.circular(D3Radius.full),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(D3Radius.full),
          splashColor: splash,
          highlightColor: highlight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                iconWithBadge,
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: weight,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      body = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: pillColor,
            borderRadius: BorderRadius.circular(D3Radius.full),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(D3Radius.full),
              splashColor: splash,
              highlightColor: highlight,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 6,
                ),
                child: iconWithBadge,
              ),
            ),
          ),
          // The label is part of the target too, without its own ripple: the
          // pill carries the feedback.
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: weight,
                  color: color,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
        ],
      );
    }

    return Semantics(
      label: item.semanticsLabel ?? item.label,
      selected: selected,
      button: true,
      excludeSemantics: true,
      onTap: onTap,
      child: body,
    );
  }
}

class _RailBadge extends StatelessWidget {
  const _RailBadge({this.count, this.label});

  final int? count;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final text = count != null ? (count! > 99 ? '99+' : '$count') : label!;
    return Container(
      constraints: const BoxConstraints(minWidth: 16),
      height: 16,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: context.d3Colors.error,
        borderRadius: BorderRadius.circular(D3Radius.full),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          height: 1,
        ),
      ),
    );
  }
}
