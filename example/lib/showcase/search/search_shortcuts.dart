import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// Asks to open the showcase search.
class OpenSearchIntent extends Intent {
  const OpenSearchIntent();
}

/// Ctrl+K, Cmd+K and "/" open the search.
///
/// Ctrl/Cmd+K work everywhere, also while typing in a field. "/" opens it only
/// when no text field has focus, so it can still be typed into one.
class SearchShortcuts extends StatelessWidget {
  const SearchShortcuts(
      {super.key, required this.onSearch, required this.child});

  final VoidCallback onSearch;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.keyK, control: true):
            OpenSearchIntent(),
        SingleActivator(LogicalKeyboardKey.keyK, meta: true):
            OpenSearchIntent(),
        SingleActivator(LogicalKeyboardKey.slash): _SlashSearchIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          OpenSearchIntent: CallbackAction<OpenSearchIntent>(
            onInvoke: (_) {
              onSearch();
              return null;
            },
          ),
          _SlashSearchIntent: _SlashSearchAction(onSearch),
        },
        // Keys only reach the shortcuts through a focused widget, so something
        // inside takes focus (when nothing else does) and nothing is lost on a
        // fresh page.
        child: Focus(autofocus: true, skipTraversal: true, child: child),
      ),
    );
  }
}

class _SlashSearchIntent extends Intent {
  const _SlashSearchIntent();
}

/// Opens the search unless the primary focus is in an editable text, where
/// the key must reach the field.
class _SlashSearchAction extends Action<_SlashSearchIntent> {
  _SlashSearchAction(this.onSearch);

  final VoidCallback onSearch;

  @override
  bool isEnabled(_SlashSearchIntent intent) {
    final focusContext = FocusManager.instance.primaryFocus?.context;
    if (focusContext == null) return true;
    if (focusContext.widget is EditableText) return false;
    return focusContext.findAncestorWidgetOfExactType<EditableText>() == null;
  }

  @override
  Object? invoke(_SlashSearchIntent intent) {
    onSearch();
    return null;
  }
}
