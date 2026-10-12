import 'package:material_ui/material_ui.dart';

import 'page_model.dart';
import 'pages/example_pages.dart';
import 'pages/overview_page.dart';
import 'pages/theme_page.dart';

/// Every page of the showcase, in navigation order. The first is the default.
final List<ShowcasePage> showcasePages = [
  ShowcasePage(
    id: 'overview',
    title: 'Overview',
    group: ShowcaseGroup.start,
    icon: Icons.home_outlined,
    summary: 'What d3_ui is.',
    builder: (_) => const OverviewPage(),
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
    builder: (_) => const ButtonPage(),
  ),
  ShowcasePage(
    id: 'chip',
    title: 'Chip',
    group: ShowcaseGroup.display,
    icon: Icons.label_outline,
    summary: 'Filters, tags and status.',
    builder: (_) => const ChipPage(),
  ),
];
