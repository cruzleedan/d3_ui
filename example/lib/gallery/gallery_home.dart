import 'package:flutter/material.dart';
import 'package:d3_ui/d3_ui.dart';

import 'pages/avatar_gallery.dart';
import 'pages/bottom_sheet_gallery.dart';
import 'pages/button_gallery.dart';
import 'pages/card_gallery.dart';
import 'pages/dialog_gallery.dart';
import 'pages/d3_list_gallery.dart';
import 'pages/empty_state_gallery.dart';
import 'pages/list_tile_gallery.dart';
import 'pages/segmented_control_gallery.dart';
import 'pages/search_anchor_gallery.dart';
import 'pages/text_field_gallery.dart';
import 'pages/screen_gallery.dart';
import 'pages/checkbox_gallery.dart';
import 'pages/radio_gallery.dart';
import 'pages/toggle_gallery.dart';
import 'pages/toast_gallery.dart';
import 'pages/chip_gallery.dart';
import 'pages/skeleton_gallery.dart';
import 'pages/image_gallery.dart';

class GalleryHome extends StatefulWidget {
  const GalleryHome({
    super.key,
    required this.themeMode,
    required this.onToggleTheme,
  });

  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  @override
  State<GalleryHome> createState() => _GalleryHomeState();
}

class _GalleryHomeState extends State<GalleryHome> {
  // Index into [_allPages]. Indices 0–3 map to primary tabs; 4+ are overflow.
  int _pageIndex = 0;

  // The "More" tab is always tab index 4 in D3NavBar.
  static const int _moreTabIndex = 4;

  // All gallery pages in order. Primary tabs = first 4; overflow = rest.
  List<Widget> get _allPages => [
        ButtonGallery(
            themeMode: widget.themeMode, onToggleTheme: widget.onToggleTheme),
        TextFieldGallery(
            themeMode: widget.themeMode, onToggleTheme: widget.onToggleTheme),
        BottomSheetGallery(
            themeMode: widget.themeMode, onToggleTheme: widget.onToggleTheme),
        CardGallery(
            themeMode: widget.themeMode, onToggleTheme: widget.onToggleTheme),
        // Overflow pages start at index 4
        ListTileGallery(
            themeMode: widget.themeMode, onToggleTheme: widget.onToggleTheme),
        DialogGallery(
            themeMode: widget.themeMode, onToggleTheme: widget.onToggleTheme),
        SegmentedControlGallery(
            themeMode: widget.themeMode, onToggleTheme: widget.onToggleTheme),
        AvatarGallery(
            themeMode: widget.themeMode, onToggleTheme: widget.onToggleTheme),
        EmptyStateGallery(
            themeMode: widget.themeMode, onToggleTheme: widget.onToggleTheme),
        D3ListGallery(
            themeMode: widget.themeMode, onToggleTheme: widget.onToggleTheme),
        SearchAnchorGallery(
            themeMode: widget.themeMode, onToggleTheme: widget.onToggleTheme),
        ToastGallery(
            themeMode: widget.themeMode, onToggleTheme: widget.onToggleTheme),
        ScreenGallery(
            themeMode: widget.themeMode, onToggleTheme: widget.onToggleTheme),
        ToggleGallery(
            themeMode: widget.themeMode, onToggleTheme: widget.onToggleTheme),
        CheckboxGallery(
            themeMode: widget.themeMode, onToggleTheme: widget.onToggleTheme),
        RadioGallery(
            themeMode: widget.themeMode, onToggleTheme: widget.onToggleTheme),
        ChipGallery(
            themeMode: widget.themeMode, onToggleTheme: widget.onToggleTheme),
        SkeletonGallery(
            themeMode: widget.themeMode, onToggleTheme: widget.onToggleTheme),
        ImageGallery(
            themeMode: widget.themeMode, onToggleTheme: widget.onToggleTheme),
      ];

  // Overflow destinations shown in the More sheet.
  static const _overflowItems = [
    _OverflowItem(
      icon: Icons.list_outlined,
      label: 'Lists',
      pageIndex: 4,
    ),
    _OverflowItem(
      icon: Icons.chat_bubble_outline_rounded,
      label: 'Dialogs',
      pageIndex: 5,
    ),
    _OverflowItem(
      icon: Icons.tune_rounded,
      label: 'Segmented',
      pageIndex: 6,
    ),
    _OverflowItem(
      icon: Icons.account_circle_outlined,
      label: 'Avatars',
      pageIndex: 7,
    ),
    _OverflowItem(
      icon: Icons.inbox_outlined,
      label: 'Empty States',
      pageIndex: 8,
    ),
    _OverflowItem(
      icon: Icons.format_list_bulleted_rounded,
      label: 'Lists',
      pageIndex: 9,
    ),
    _OverflowItem(
      icon: Icons.search_rounded,
      label: 'Search',
      pageIndex: 10,
    ),
    _OverflowItem(
      icon: Icons.notifications_outlined,
      label: 'Toasts',
      pageIndex: 11,
    ),
    _OverflowItem(
      icon: Icons.web_asset_outlined,
      label: 'Screens',
      pageIndex: 12,
    ),
    _OverflowItem(
      icon: Icons.toggle_on_outlined,
      label: 'Toggle',
      pageIndex: 13,
    ),
    _OverflowItem(
      icon: Icons.check_box_outlined,
      label: 'Checkbox',
      pageIndex: 14,
    ),
    _OverflowItem(
      icon: Icons.radio_button_checked_outlined,
      label: 'Radio',
      pageIndex: 15,
    ),
    _OverflowItem(
      icon: Icons.label_outline_rounded,
      label: 'Chips',
      pageIndex: 16,
    ),
    _OverflowItem(
      icon: Icons.view_agenda_outlined,
      label: 'Skeleton',
      pageIndex: 17,
    ),
    _OverflowItem(
      icon: Icons.image_outlined,
      label: 'Image',
      pageIndex: 18,
    ),
  ];

  bool get _isOverflowActive => _pageIndex >= _moreTabIndex;

  void _onTabSelected(int navIndex) {
    if (navIndex == _moreTabIndex) {
      _showMoreSheet();
    } else {
      setState(() => _pageIndex = navIndex);
    }
  }

  void _showMoreSheet() {
    D3BottomSheet.show(
      context,
      title: 'More',
      snapPoints: [D3SnapPoint.half],
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: D3ListTileGroup(
          children: _overflowItems.map((item) {
            final isSelected = _pageIndex == item.pageIndex;
            return D3ListTile(
              leading: D3ListTileIcon(
                icon: item.icon,
                color: isSelected
                    ? context.d3Colors.primary
                    : context.d3Colors.onSurfaceVariant,
              ),
              title: item.label,
              trailing: isSelected
                  ? Icon(Icons.check_rounded,
                      size: 18, color: context.d3Colors.primary)
                  : const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.pop(context);
                setState(() => _pageIndex = item.pageIndex);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;

    // Nav bar highlights the active primary tab, or "More" for overflow pages.
    final navIndex = _isOverflowActive ? _moreTabIndex : _pageIndex;

    return Scaffold(
      backgroundColor: colors.surface,
      body: _allPages[_pageIndex],
      bottomNavigationBar: D3NavBar(
        selectedIndex: navIndex,
        onTabSelected: _onTabSelected,
        items: const [
          D3NavItem(
            icon: Icons.smart_button_outlined,
            activeIcon: Icons.smart_button_rounded,
            label: 'Buttons',
          ),
          D3NavItem(
            icon: Icons.text_fields_outlined,
            activeIcon: Icons.text_fields_rounded,
            label: 'Text Fields',
          ),
          D3NavItem(
            icon: Icons.layers_outlined,
            activeIcon: Icons.layers_rounded,
            label: 'Sheets',
          ),
          D3NavItem(
            icon: Icons.crop_square_outlined,
            activeIcon: Icons.crop_square_rounded,
            label: 'Cards',
          ),
          D3NavItem(
            icon: Icons.grid_view_outlined,
            activeIcon: Icons.grid_view_rounded,
            label: 'More',
          ),
        ],
      ),
    );
  }
}

// Lightweight descriptor for an overflow destination.
class _OverflowItem {
  const _OverflowItem({
    required this.icon,
    required this.label,
    required this.pageIndex,
  });

  final IconData icon;
  final String label;
  final int pageIndex;
}
