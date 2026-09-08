/// Shared visual status for d3_ui input fields — idle/focused/filled/error/
/// success/disabled. Extracted from D3TextField's private `_FieldStatus` so
/// [D3FieldStylingMixin] can resolve colors the same way across fields.
enum D3FieldStatus { idle, focused, filled, error, success, disabled }

/// Resolves a single [D3FieldStatus] from a field's raw state, with a fixed
/// precedence — `disabled > error > success > focused > filled > idle` —
/// defined in exactly one place instead of each field re-deriving its own
/// ordering (see root `context/work/0019-d3-ui-field-styling-resolver.md`:
/// prior to this, `D3TextField` and `D3DateField` had two different,
/// already-diverged precedence orderings).
///
/// [isReadOnly] maps to [D3FieldStatus.disabled] — a read-only field is
/// visually indistinguishable from a disabled one in d3_ui today.
D3FieldStatus resolveD3FieldStatus({
  required bool isEnabled,
  bool isReadOnly = false,
  String? errorText,
  String? successText,
  bool hasFocus = false,
  bool hasContent = false,
}) {
  if (!isEnabled || isReadOnly) return D3FieldStatus.disabled;
  if (errorText != null) return D3FieldStatus.error;
  if (successText != null) return D3FieldStatus.success;
  if (hasFocus) return D3FieldStatus.focused;
  if (hasContent) return D3FieldStatus.filled;
  return D3FieldStatus.idle;
}
