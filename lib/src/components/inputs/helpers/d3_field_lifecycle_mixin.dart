import 'package:material_ui/material_ui.dart';

/// Owns-or-borrows lifecycle for a [TextEditingController] and [FocusNode].
///
/// A field either receives an external controller/focus node (and must not
/// dispose what it doesn't own) or creates its own (and must dispose it).
/// This mixin centralizes that bookkeeping so each field widget doesn't
/// re-track `_ownsController`/`_ownsFocusNode` booleans by hand.
mixin D3FieldLifecycleMixin<T extends StatefulWidget> on State<T> {
  late TextEditingController controller;
  late FocusNode focusNode;
  bool _ownsController = false;
  bool _ownsFocusNode = false;

  /// Call once from [initState]. Uses [externalController]/[externalFocusNode]
  /// when provided, otherwise creates and owns new instances.
  void initializeFieldControllers({
    TextEditingController? externalController,
    FocusNode? externalFocusNode,
    String? initialText,
  }) {
    if (externalController == null) {
      controller = TextEditingController(text: initialText);
      _ownsController = true;
    } else {
      controller = externalController;
    }

    if (externalFocusNode == null) {
      focusNode = FocusNode();
      _ownsFocusNode = true;
    } else {
      focusNode = externalFocusNode;
    }
  }

  /// Call from [dispose] after removing any listeners you added.
  void disposeFieldControllers() {
    if (_ownsController) controller.dispose();
    if (_ownsFocusNode) focusNode.dispose();
  }
}
