import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:d3_ui/d3_ui.dart';

// ─────────────────────────────────────────────────────────────────────────────
// D3NavItem
// ─────────────────────────────────────────────────────────────────────────────

/// A single destination in a [D3NavBar].
class D3NavItem {
  const D3NavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    this.badgeCount,
    this.badgeLabel,
    this.semanticsLabel,
  }) : assert(
          badgeCount == null || badgeLabel == null,
          'Provide badgeCount or badgeLabel, not both.',
        );

  /// Icon shown when this item is not selected.
  final IconData icon;

  /// Icon shown when selected. Falls back to [icon] when null.
  final IconData? activeIcon;

  final String label;

  /// Numeric badge (e.g. unread count). Capped at 99+ in the UI.
  final int? badgeCount;

  /// Text badge (e.g. 'New'). Shown as-is; keep it short (≤4 chars).
  final String? badgeLabel;

  /// Override for screen readers. Defaults to [label].
  final String? semanticsLabel;
}

// ─────────────────────────────────────────────────────────────────────────────
// D3NavBar
// ─────────────────────────────────────────────────────────────────────────────

/// Bottom navigation bar with an animated pill indicator, always-on labels,
/// and optional badges.
///
/// ```dart
/// D3NavBar(
///   selectedIndex: _tab,
///   onTabSelected: (i) => setState(() => _tab = i),
///   items: const [
///     D3NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
///     D3NavItem(icon: Icons.search_outlined, label: 'Explore'),
///     D3NavItem(icon: Icons.notifications_outlined, label: 'Alerts', badgeCount: 3),
///     D3NavItem(icon: Icons.person_outlined, label: 'Profile'),
///   ],
/// )
/// ```
class D3NavBar extends StatelessWidget {
  const D3NavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onTabSelected,
  }) : assert(items.length >= 2 && items.length <= 5,
            'D3NavBar requires 2–5 items.');

  final List<D3NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        border: Border(
          top: BorderSide(
            color: colors.outline.withValues(alpha: 0.15),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            top: 8,
            bottom: bottomPadding > 0 ? bottomPadding : 12,
          ),
          child: Row(
            children: List.generate(items.length, (i) {
              return Expanded(
                child: _NavBarItem(
                  item: items[i],
                  isSelected: i == selectedIndex,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onTabSelected(i);
                  },
                  colors: colors,
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual nav item
// ─────────────────────────────────────────────────────────────────────────────

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.colors,
  });

  final D3NavItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final D3ColorTokens colors;

  @override
  Widget build(BuildContext context) {
    final icon = isSelected ? (item.activeIcon ?? item.icon) : item.icon;
    final iconColor = isSelected ? colors.primary : colors.onSurfaceVariant;
    final labelColor = isSelected ? colors.primary : colors.onSurfaceVariant;
    final labelWeight = isSelected ? FontWeight.w600 : FontWeight.w400;

    return Semantics(
      label: item.semanticsLabel ?? item.label,
      selected: isSelected,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Pill + icon ────────────────────────────────────────────────
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.symmetric(
                    horizontal: isSelected ? D3Spacing.s16 : D3Spacing.s8,
                    vertical: D3Spacing.s4,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors.primaryContainer
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(D3Radius.full),
                  ),
                  child: Icon(icon, size: 22, color: iconColor),
                ),

                // Badge
                if (item.badgeCount != null || item.badgeLabel != null)
                  Positioned(
                    top: -2,
                    right: -4,
                    child: _Badge(
                      count: item.badgeCount,
                      label: item.badgeLabel,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 3),

            // ── Label ──────────────────────────────────────────────────────
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10,
                fontWeight: labelWeight,
                color: labelColor,
                letterSpacing: 0.1,
              ),
              child: Text(item.label,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Badge
// ─────────────────────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  const _Badge({this.count, this.label});

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
