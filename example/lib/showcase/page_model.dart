import 'package:material_ui/material_ui.dart';

/// The groups of the navigation, in order.
enum ShowcaseGroup {
  start('Start'),
  actions('Actions'),
  display('Display'),
  feedback('Feedback'),
  inputs('Inputs'),
  navigation('Navigation'),
  overlays('Sheets and dialogs'),
  surfaces('Surfaces'),
  patterns('Patterns');

  const ShowcaseGroup(this.label);

  final String label;
}

/// One page of the showcase: a component (or the theme, or a pattern).
class ShowcasePage {
  const ShowcasePage({
    required this.id,
    required this.title,
    required this.group,
    required this.icon,
    required this.summary,
    required this.builder,
  });

  /// The `?page=` value; also unique across the registry.
  final String id;
  final String title;
  final ShowcaseGroup group;
  final IconData icon;

  /// One sentence: what it is and when to use it.
  final String summary;

  /// The page's body (no Scaffold: the shell provides the chrome).
  final WidgetBuilder builder;
}
