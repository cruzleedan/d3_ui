import 'package:material_ui/material_ui.dart';
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
// D3NavBarCenterAction
// ─────────────────────────────────────────────────────────────────────────────

/// An optional, visually distinct action rendered in the middle of a
/// [D3NavBar], alongside (not counted among) its [D3NavBar.items].
///
/// Use this for a frequent one-tap action that doesn't navigate to a
/// persistent destination (e.g. opening a "new entry" sheet) — a common
/// bottom-nav pattern for mixing navigation tabs with an action. Rendered
/// as a raised, filled circle rather than the plain pill-select style
/// [D3NavItem]s use, so it reads as "does something" rather than "goes
/// somewhere." Tapping it calls [onPressed] only — it never affects
/// [D3NavBar.selectedIndex] or [D3NavBar.onTabSelected].
class D3NavBarCenterAction {
  const D3NavBarCenterAction({
    required this.icon,
    required this.onPressed,
    this.semanticsLabel,
  });

  final IconData icon;
  final VoidCallback onPressed;

  /// Screen-reader label. Required in practice (no visible label is shown
  /// next to the icon), but kept optional with a generic fallback so a
  /// caller who forgets isn't left with no label at all.
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
///
/// // With a center action (e.g. "add new"), rendered distinctly and
/// // inserted between the two halves of items — see D3NavBarCenterAction.
/// D3NavBar(
///   selectedIndex: _tab,
///   onTabSelected: (i) => setState(() => _tab = i),
///   items: const [
///     D3NavItem(icon: Icons.home_outlined, label: 'Home'),
///     D3NavItem(icon: Icons.settings_outlined, label: 'Settings'),
///   ],
///   centerAction: D3NavBarCenterAction(
///     icon: Icons.add,
///     onPressed: () => showNewEntrySheet(context),
///     semanticsLabel: 'New entry',
///   ),
/// )
/// ```
class D3NavBar extends StatelessWidget {
  const D3NavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onTabSelected,
    this.centerAction,
  }) : assert(
         items.length >= 2 && items.length <= 5,
         'D3NavBar requires 2–5 items.',
       );

  final List<D3NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  /// Optional visually-distinct action rendered between the two halves of
  /// [items] (e.g. items = [A, B, C, D] renders as A, B, •center•, C, D).
  /// Does not count toward the 2–5 [items] limit and never affects
  /// [selectedIndex]/[onTabSelected] — see [D3NavBarCenterAction].
  final D3NavBarCenterAction? centerAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final action = centerAction;
    // Split point for inserting the center action: after the first half
    // of items, so e.g. 4 items become 2 + action + 2, and an odd count
    // (e.g. 3) becomes 2 + action + 1 (matches this being an even count
    // in the app that actually needed this — site_inspector's Projects/
    // Visit History/+/Settings — without breaking for other counts).
    final splitIndex = (items.length / 2).ceil();

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
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (action != null && i == splitIndex)
                  _NavBarCenterActionButton(
                    action: action,
                    colors: colors,
                  ),
                Expanded(
                  child: _NavBarItem(
                    item: items[i],
                    isSelected: i == selectedIndex,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onTabSelected(i);
                    },
                    colors: colors,
                  ),
                ),
              ],
              if (action != null && splitIndex == items.length)
                _NavBarCenterActionButton(action: action, colors: colors),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Center action button
// ─────────────────────────────────────────────────────────────────────────────

class _NavBarCenterActionButton extends StatelessWidget {
  const _NavBarCenterActionButton({required this.action, required this.colors});

  final D3NavBarCenterAction action;
  final D3ColorTokens colors;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: action.semanticsLabel ?? 'Action',
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.lightImpact();
          action.onPressed();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: D3Spacing.s8),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(action.icon, size: 24, color: colors.onPrimary),
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
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
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
