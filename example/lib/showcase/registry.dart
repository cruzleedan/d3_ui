import 'package:material_ui/material_ui.dart';

import 'deferred_page.dart';
import 'page_model.dart';
import 'pages/display_pages.dart' deferred as display;
import 'pages/controls_overlay_pages.dart' deferred as controls;
import 'pages/banner_badge_pages.dart' deferred as extras;
import 'pages/progress_inputs_pages.dart' deferred as progress;
import 'pages/action_sheet_page.dart' deferred as sheets;
import 'pages/rating_otp_pages.dart' deferred as rating;
import 'pages/time_field_page.dart' deferred as time;
import 'pages/menu_tooltip_pages.dart' deferred as menus;
import 'pages/example_pages.dart' deferred as actions;
import 'pages/inputs_text_pages.dart' deferred as inputs;
import 'pages/nav_surface_pages.dart' deferred as nav;
import 'pages/patterns_page.dart' deferred as patterns;
import 'pages/components_page.dart';
import 'pages/overview_page.dart';
import 'pages/theme_page.dart';

/// Every page of the showcase, in navigation order. The first is the default.
final List<ShowcasePage> showcasePages = [
  ShowcasePage(
    id: 'overview',
    title: 'Home',
    group: ShowcaseGroup.start,
    icon: Icons.home_outlined,
    summary: 'What d3_ui is.',
    builder: (_) => const OverviewPage(),
  ),
  ShowcasePage(
    id: 'components',
    title: 'Components',
    group: ShowcaseGroup.start,
    icon: Icons.widgets_outlined,
    summary: 'Every component, by group.',
    builder: (_) => const ComponentsPage(),
  ),
  ShowcasePage(
    id: 'theme',
    title: 'Theme',
    group: ShowcaseGroup.start,
    icon: Icons.palette_outlined,
    summary: 'The tokens of the running theme.',
    builder: (_) => const ThemePage(),
  ),
  ShowcasePage(
    id: 'button',
    title: 'Button',
    group: ShowcaseGroup.actions,
    icon: Icons.smart_button_outlined,
    summary: 'Variants, sizes, icons and states.',
    builder: (_) => DeferredPage(
      load: actions.loadLibrary,
      builder: (_) => actions.ButtonPage(),
    ),
  ),
  ShowcasePage(
    id: 'split-button',
    title: 'Split button',
    group: ShowcaseGroup.actions,
    icon: Icons.arrow_drop_down_circle_outlined,
    summary: 'A main action with a menu.',
    builder: (_) => DeferredPage(
      load: actions.loadLibrary,
      builder: (_) => actions.SplitButtonPage(),
    ),
  ),
  ShowcasePage(
    id: 'expanding-fab',
    title: 'Expanding FAB',
    group: ShowcaseGroup.actions,
    icon: Icons.add_circle_outline,
    summary: 'A floating button that fans out actions.',
    builder: (_) => DeferredPage(
      load: actions.loadLibrary,
      builder: (_) => actions.ExpandingFabPage(),
    ),
  ),
  ShowcasePage(
    id: 'scrim-button',
    title: 'Scrim icon button',
    group: ShowcaseGroup.actions,
    icon: Icons.photo_camera_back_outlined,
    summary: 'An icon button for use over photos.',
    builder: (_) => DeferredPage(
      load: actions.loadLibrary,
      builder: (_) => actions.ScrimButtonPage(),
    ),
  ),
  ShowcasePage(
    id: 'avatar',
    title: 'Avatar',
    group: ShowcaseGroup.display,
    icon: Icons.account_circle_outlined,
    summary: 'People and places as pictures or initials.',
    builder: (_) => DeferredPage(
      load: display.loadLibrary,
      builder: (_) => display.AvatarPage(),
    ),
  ),
  ShowcasePage(
    id: 'chip',
    title: 'Chip',
    group: ShowcaseGroup.display,
    icon: Icons.label_outline,
    summary: 'Filters, tags and status.',
    builder: (_) => DeferredPage(
      load: actions.loadLibrary,
      builder: (_) => actions.ChipPage(),
    ),
  ),
  ShowcasePage(
    id: 'image',
    title: 'Image',
    group: ShowcaseGroup.display,
    icon: Icons.image_outlined,
    summary: 'A network image with safe fallbacks.',
    builder: (_) => DeferredPage(
      load: display.loadLibrary,
      builder: (_) => display.ImagePage(),
    ),
  ),
  ShowcasePage(
    id: 'poster-card',
    title: 'Poster card',
    group: ShowcaseGroup.display,
    icon: Icons.view_agenda_outlined,
    summary: 'A picture-led card for grids.',
    builder: (_) => DeferredPage(
      load: display.loadLibrary,
      builder: (_) => display.PosterCardPage(),
    ),
  ),
  ShowcasePage(
    id: 'photos',
    title: 'Photos',
    group: ShowcaseGroup.display,
    icon: Icons.photo_library_outlined,
    summary: 'Carousel, gallery and viewer.',
    builder: (_) => DeferredPage(
      load: display.loadLibrary,
      builder: (_) => display.PhotosPage(),
    ),
  ),
  ShowcasePage(
    id: 'list',
    title: 'List',
    group: ShowcaseGroup.display,
    icon: Icons.list_alt_outlined,
    summary: 'Sections, refresh and selection.',
    builder: (_) => DeferredPage(
      load: display.loadLibrary,
      builder: (_) => display.ListPage(),
    ),
  ),
  ShowcasePage(
    id: 'section-header',
    title: 'Section header',
    group: ShowcaseGroup.display,
    icon: Icons.title_outlined,
    summary: 'A label for a group of rows.',
    builder: (_) => DeferredPage(
      load: display.loadLibrary,
      builder: (_) => display.SectionHeaderPage(),
    ),
  ),
  ShowcasePage(
    id: 'expandable-section',
    title: 'Expandable section',
    group: ShowcaseGroup.display,
    icon: Icons.unfold_more_outlined,
    summary: 'A block that opens and closes.',
    builder: (_) => DeferredPage(
      load: display.loadLibrary,
      builder: (_) => display.ExpandableSectionPage(),
    ),
  ),
  ShowcasePage(
    id: 'skeleton',
    title: 'Skeleton',
    group: ShowcaseGroup.display,
    icon: Icons.hourglass_empty_outlined,
    summary: 'Placeholders while content loads.',
    builder: (_) => DeferredPage(
      load: display.loadLibrary,
      builder: (_) => display.SkeletonPage(),
    ),
  ),
  ShowcasePage(
    id: 'empty-state',
    title: 'Empty state',
    group: ShowcaseGroup.display,
    icon: Icons.inbox_outlined,
    summary: 'What to show when there is nothing.',
    builder: (_) => DeferredPage(
      load: display.loadLibrary,
      builder: (_) => display.EmptyStatePage(),
    ),
  ),
  ShowcasePage(
    id: 'toast',
    title: 'Toast',
    group: ShowcaseGroup.feedback,
    icon: Icons.chat_bubble_outline,
    summary: 'A short message that goes away.',
    builder: (_) => DeferredPage(
      load: display.loadLibrary,
      builder: (_) => display.ToastPage(),
    ),
  ),
  ShowcasePage(
    id: 'text-field',
    title: 'Text field',
    group: ShowcaseGroup.inputs,
    icon: Icons.text_fields_rounded,
    summary: 'Single or multi-line text with helper and error states.',
    builder: (_) => DeferredPage(
      load: inputs.loadLibrary,
      builder: (_) => inputs.TextFieldPage(),
    ),
  ),
  ShowcasePage(
    id: 'date-field',
    title: 'Date field',
    group: ShowcaseGroup.inputs,
    icon: Icons.event_rounded,
    summary: 'Tap to pick a date.',
    builder: (_) => DeferredPage(
      load: inputs.loadLibrary,
      builder: (_) => inputs.DateFieldPage(),
    ),
  ),
  ShowcasePage(
    id: 'decimal-field',
    title: 'Decimal field',
    group: ShowcaseGroup.inputs,
    icon: Icons.pin_outlined,
    summary: 'Numbers with decimals, limits, prefix and suffix.',
    builder: (_) => DeferredPage(
      load: inputs.loadLibrary,
      builder: (_) => inputs.DecimalFieldPage(),
    ),
  ),
  ShowcasePage(
    id: 'dropdown-field',
    title: 'Dropdown field',
    group: ShowcaseGroup.inputs,
    icon: Icons.arrow_drop_down_circle_outlined,
    summary: 'Pick one value from a menu or a searchable sheet.',
    builder: (_) => DeferredPage(
      load: inputs.loadLibrary,
      builder: (_) => inputs.DropdownFieldPage(),
    ),
  ),
  ShowcasePage(
    id: 'search',
    title: 'Search',
    group: ShowcaseGroup.inputs,
    icon: Icons.search_rounded,
    summary: 'A search bar, and an anchor that opens a full search view.',
    builder: (_) => DeferredPage(
      load: inputs.loadLibrary,
      builder: (_) => inputs.SearchPage(),
    ),
  ),
  ShowcasePage(
    id: 'schema-form',
    title: 'Schema form',
    group: ShowcaseGroup.inputs,
    icon: Icons.dynamic_form_rounded,
    summary: 'A whole form rendered from a schema.',
    builder: (_) => DeferredPage(
      load: inputs.loadLibrary,
      builder: (_) => inputs.SchemaFormPage(),
    ),
  ),
  ShowcasePage(
    id: 'checkbox',
    title: 'Checkbox',
    group: ShowcaseGroup.inputs,
    icon: Icons.check_box_outlined,
    summary: 'Checkbox with label and indeterminate state.',
    builder: (_) => DeferredPage(
      load: controls.loadLibrary,
      builder: (_) => controls.CheckboxPage(),
    ),
  ),
  ShowcasePage(
    id: 'radio',
    title: 'Radio',
    group: ShowcaseGroup.inputs,
    icon: Icons.radio_button_checked,
    summary: 'Pick exactly one option from a visible group.',
    builder: (_) => DeferredPage(
      load: controls.loadLibrary,
      builder: (_) => controls.RadioPage(),
    ),
  ),
  ShowcasePage(
    id: 'toggle',
    title: 'Toggle',
    group: ShowcaseGroup.inputs,
    icon: Icons.toggle_on_outlined,
    summary: 'On/off switch for settings that apply at once.',
    builder: (_) => DeferredPage(
      load: controls.loadLibrary,
      builder: (_) => controls.TogglePage(),
    ),
  ),
  ShowcasePage(
    id: 'segmented-control',
    title: 'Segmented control',
    group: ShowcaseGroup.inputs,
    icon: Icons.view_week_outlined,
    summary: 'A short row of exclusive options.',
    builder: (_) => DeferredPage(
      load: controls.loadLibrary,
      builder: (_) => controls.SegmentedControlPage(),
    ),
  ),
  ShowcasePage(
    id: 'filter-chip-row',
    title: 'Filter chip row',
    group: ShowcaseGroup.inputs,
    icon: Icons.filter_list,
    summary: 'A scrolling row of filter chips.',
    builder: (_) => DeferredPage(
      load: controls.loadLibrary,
      builder: (_) => controls.FilterChipRowPage(),
    ),
  ),
  ShowcasePage(
    id: 'screen',
    title: 'Screen',
    group: ShowcaseGroup.navigation,
    icon: Icons.smartphone_outlined,
    summary: 'The page scaffold: app bar, body and actions.',
    builder: (_) => DeferredPage(
      load: nav.loadLibrary,
      builder: (_) => nav.ScreenPage(),
    ),
  ),
  ShowcasePage(
    id: 'list-screen',
    title: 'List screen',
    group: ShowcaseGroup.navigation,
    icon: Icons.view_list_outlined,
    summary: 'A screen built around a list.',
    builder: (_) => DeferredPage(
      load: nav.loadLibrary,
      builder: (_) => nav.ListScreenPage(),
    ),
  ),
  ShowcasePage(
    id: 'scroll-over-sheet',
    title: 'Scroll-over sheet',
    group: ShowcaseGroup.navigation,
    icon: Icons.vertical_align_top,
    summary: 'A sheet that scrolls over a header image.',
    builder: (_) => DeferredPage(
      load: nav.loadLibrary,
      builder: (_) => nav.ScrollOverSheetPage(),
    ),
  ),
  ShowcasePage(
    id: 'nav-bar',
    title: 'Nav bar',
    group: ShowcaseGroup.navigation,
    icon: Icons.menu_open,
    summary: 'Bottom navigation between top-level places.',
    builder: (_) => DeferredPage(
      load: nav.loadLibrary,
      builder: (_) => nav.NavBarPage(),
    ),
  ),
  ShowcasePage(
    id: 'nav-rail',
    title: 'Nav rail',
    group: ShowcaseGroup.navigation,
    icon: Icons.view_sidebar_outlined,
    summary: 'Navigation for medium and expanded windows.',
    builder: (_) => DeferredPage(
      load: nav.loadLibrary,
      builder: (_) => nav.NavRailPage(),
    ),
  ),
  ShowcasePage(
    id: 'tab-bar',
    title: 'Tab bar',
    group: ShowcaseGroup.navigation,
    icon: Icons.tab_outlined,
    summary: 'Tabs for switching views in one place.',
    builder: (_) => DeferredPage(
      load: nav.loadLibrary,
      builder: (_) => nav.TabBarPage(),
    ),
  ),
  ShowcasePage(
    id: 'sticky-header',
    title: 'Sticky header',
    group: ShowcaseGroup.navigation,
    icon: Icons.push_pin_outlined,
    summary: 'A header that stays while its section scrolls.',
    builder: (_) => DeferredPage(
      load: nav.loadLibrary,
      builder: (_) => nav.StickyHeaderPage(),
    ),
  ),
  ShowcasePage(
    id: 'bottom-sheet',
    title: 'Bottom sheet',
    group: ShowcaseGroup.overlays,
    icon: Icons.vertical_align_top,
    summary: 'A modal sheet with snap points and a discard guard.',
    builder: (_) => DeferredPage(
      load: controls.loadLibrary,
      builder: (_) => controls.BottomSheetPage(),
    ),
  ),
  ShowcasePage(
    id: 'form-sheet',
    title: 'Form sheet',
    group: ShowcaseGroup.overlays,
    icon: Icons.edit_note,
    summary: 'A content-sized sheet for short forms.',
    builder: (_) => DeferredPage(
      load: controls.loadLibrary,
      builder: (_) => controls.FormSheetPage(),
    ),
  ),
  ShowcasePage(
    id: 'dialog',
    title: 'Dialog',
    group: ShowcaseGroup.overlays,
    icon: Icons.chat_bubble_outline,
    summary: 'A centred dialog for confirmations and alerts.',
    builder: (_) => DeferredPage(
      load: controls.loadLibrary,
      builder: (_) => controls.DialogPage(),
    ),
  ),
  ShowcasePage(
    id: 'calendar-picker',
    title: 'Calendar picker',
    group: ShowcaseGroup.overlays,
    icon: Icons.calendar_month_rounded,
    summary: 'A themed calendar dialog with marked days.',
    builder: (_) => DeferredPage(
      load: inputs.loadLibrary,
      builder: (_) => inputs.CalendarPickerPage(),
    ),
  ),
  ShowcasePage(
    id: 'card',
    title: 'Card',
    group: ShowcaseGroup.surfaces,
    icon: Icons.crop_square,
    summary: 'A grouped block with optional media.',
    builder: (_) => DeferredPage(
      load: nav.loadLibrary,
      builder: (_) => nav.CardPage(),
    ),
  ),
  ShowcasePage(
    id: 'info-card',
    title: 'Info card',
    group: ShowcaseGroup.surfaces,
    icon: Icons.info_outline,
    summary: 'A few icon and text facts in an outline.',
    builder: (_) => DeferredPage(
      load: nav.loadLibrary,
      builder: (_) => nav.InfoCardPage(),
    ),
  ),
  ShowcasePage(
    id: 'list-tile',
    title: 'List tile',
    group: ShowcaseGroup.surfaces,
    icon: Icons.list_alt,
    summary: 'A row with leading, title, subtitle and trailing.',
    builder: (_) => DeferredPage(
      load: nav.loadLibrary,
      builder: (_) => nav.ListTilePage(),
    ),
  ),
  ShowcasePage(
    id: 'slidable-row',
    title: 'Slidable row',
    group: ShowcaseGroup.surfaces,
    icon: Icons.swipe_left_outlined,
    summary: 'A row with actions behind a swipe.',
    builder: (_) => DeferredPage(
      load: nav.loadLibrary,
      builder: (_) => nav.SlidableRowPage(),
    ),
  ),
  ShowcasePage(
    id: 'thumbnail-card',
    title: 'Thumbnail card',
    group: ShowcaseGroup.surfaces,
    icon: Icons.photo_size_select_actual_outlined,
    summary: 'A small picture card.',
    builder: (_) => DeferredPage(
      load: nav.loadLibrary,
      builder: (_) => nav.ThumbnailCardPage(),
    ),
  ),
  ShowcasePage(
    id: 'ticket-card',
    title: 'Ticket card',
    group: ShowcaseGroup.surfaces,
    icon: Icons.confirmation_number_outlined,
    summary: 'A coupon-like card with a tear line.',
    builder: (_) => DeferredPage(
      load: nav.loadLibrary,
      builder: (_) => nav.TicketCardPage(),
    ),
  ),
  ShowcasePage(
    id: 'patterns',
    title: 'Places',
    group: ShowcaseGroup.patterns,
    icon: Icons.explore_outlined,
    summary: 'A small app built only from d3_ui parts.',
    builder: (_) => DeferredPage(
      load: patterns.loadLibrary,
      builder: (_) => patterns.PatternsPage(),
    ),
  ),
  ShowcasePage(
    id: 'banner',
    title: 'Banner',
    group: ShowcaseGroup.feedback,
    icon: Icons.campaign_outlined,
    summary: 'A message that stays until it is dealt with.',
    builder: (_) => DeferredPage(
      load: extras.loadLibrary,
      builder: (_) => extras.BannerPage(),
    ),
  ),
  ShowcasePage(
    id: 'progress',
    title: 'Progress',
    group: ShowcaseGroup.feedback,
    icon: Icons.linear_scale,
    summary: 'Bar and ring, known or unknown.',
    builder: (_) => DeferredPage(
      load: progress.loadLibrary,
      builder: (_) => progress.ProgressPage(),
    ),
  ),
  ShowcasePage(
    id: 'badge',
    title: 'Badge',
    group: ShowcaseGroup.display,
    icon: Icons.notifications_none_rounded,
    summary: 'A count, dot or status pill, on anything.',
    builder: (_) => DeferredPage(
      load: extras.loadLibrary,
      builder: (_) => extras.BadgePage(),
    ),
  ),
  ShowcasePage(
    id: 'slider',
    title: 'Slider',
    group: ShowcaseGroup.inputs,
    icon: Icons.tune,
    summary: 'Pick a value by dragging.',
    builder: (_) => DeferredPage(
      load: progress.loadLibrary,
      builder: (_) => progress.SliderPage(),
    ),
  ),
  ShowcasePage(
    id: 'quantity-stepper',
    title: 'Quantity stepper',
    group: ShowcaseGroup.inputs,
    icon: Icons.exposure,
    summary: 'Minus, value, plus, with hold to repeat.',
    builder: (_) => DeferredPage(
      load: progress.loadLibrary,
      builder: (_) => progress.QuantityStepperPage(),
    ),
  ),
  ShowcasePage(
    id: 'action-sheet',
    title: 'Action sheet',
    group: ShowcaseGroup.overlays,
    icon: Icons.view_agenda_outlined,
    summary: 'A bottom sheet of thumb-sized actions.',
    builder: (_) => DeferredPage(
      load: sheets.loadLibrary,
      builder: (_) => sheets.ActionSheetPage(),
    ),
  ),
  ShowcasePage(
    id: 'rating',
    title: 'Rating',
    group: ShowcaseGroup.inputs,
    icon: Icons.star_rounded,
    summary: 'Stars to show or choose a rating.',
    builder: (_) => DeferredPage(
      load: rating.loadLibrary,
      builder: (_) => rating.RatingPage(),
    ),
  ),
  ShowcasePage(
    id: 'otp-field',
    title: 'OTP field',
    group: ShowcaseGroup.inputs,
    icon: Icons.password_rounded,
    summary: 'One-time-code cells over one real text field.',
    builder: (_) => DeferredPage(
      load: rating.loadLibrary,
      builder: (_) => rating.OtpFieldPage(),
    ),
  ),
  ShowcasePage(
    id: 'time-field',
    title: 'Time field',
    group: ShowcaseGroup.inputs,
    icon: Icons.schedule_outlined,
    summary: 'A field that opens a wheel time picker.',
    builder: (_) => DeferredPage(
      load: time.loadLibrary,
      builder: (_) => time.TimeFieldPage(),
    ),
  ),
  ShowcasePage(
    id: 'menu',
    title: 'Menu',
    group: ShowcaseGroup.actions,
    icon: Icons.more_vert_rounded,
    summary: 'An overflow or context menu on a trigger.',
    builder: (_) => DeferredPage(
      load: menus.loadLibrary,
      builder: (_) => menus.MenuPage(),
    ),
  ),
  ShowcasePage(
    id: 'tooltip',
    title: 'Tooltip',
    group: ShowcaseGroup.feedback,
    icon: Icons.chat_bubble_outline_rounded,
    summary: 'Hints on hover, focus and long-press; tap-to-open info.',
    builder: (_) => DeferredPage(
      load: menus.loadLibrary,
      builder: (_) => menus.TooltipPage(),
    ),
  ),
];
