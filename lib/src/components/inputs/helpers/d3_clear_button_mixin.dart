/// Centralizes the enabled/read-only/has-content/focused visibility rule
/// shared by every d3_ui field that offers a clear (✕) button.
mixin D3ClearButtonMixin {
  /// True when a clear button should render, given the field's current
  /// interaction state. Mirrors the rule D3TextField applied inline:
  /// requested, focused, has text, enabled, and not read-only.
  bool shouldShowClearButton({
    required bool requested,
    required bool isFocused,
    required bool hasText,
    required bool isEnabled,
    required bool isReadOnly,
  }) {
    return requested && isFocused && hasText && isEnabled && !isReadOnly;
  }
}
