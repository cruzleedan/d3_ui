import 'package:flutter/painting.dart';
import 'package:d3_ui/d3_ui.dart';

import 'd3_field_status.dart';

/// Bundled result of resolving a field's visual style for a given
/// [D3FieldStatus] — one object instead of separately calling multiple
/// methods per property. Immutable and cheap to construct: a pure function
/// of `(status, colors, tokens)`, not tied to a `BuildContext`.
class D3FieldStyleResult {
  const D3FieldStyleResult({
    required this.borderColor,
    required this.backgroundColor,
    required this.borderWidth,
    required this.labelColor,
    required this.iconColor,
    required this.helperTextColor,
  });

  final Color borderColor;
  final Color backgroundColor;
  final double borderWidth;
  final Color labelColor;
  final Color iconColor;
  final Color helperTextColor;
}

/// Resolves a [D3FieldStyleResult] from [D3FieldStatus] in one call,
/// replacing the per-field `_borderColor`/`_bgColor` switch statements each
/// d3_ui input widget previously wrote independently.
mixin D3FieldStylingMixin {
  Color _resolveBorderColor(D3FieldStatus status, D3ColorTokens colors) =>
      switch (status) {
        D3FieldStatus.focused => colors.primary,
        D3FieldStatus.error => colors.error,
        D3FieldStatus.success => colors.success,
        D3FieldStatus.disabled => colors.outline,
        _ => colors.outline,
      };

  Color _resolveBackgroundColor(D3FieldStatus status, D3ColorTokens colors) =>
      switch (status) {
        D3FieldStatus.disabled => colors.surfaceVariant,
        D3FieldStatus.focused => colors.surface,
        D3FieldStatus.filled => colors.surface,
        D3FieldStatus.error => colors.surface,
        D3FieldStatus.success => colors.surface,
        _ => colors.surfaceVariant,
      };

  /// Border width widens for focused/error/success — matches the
  /// `tokens.focusedBorderWidth` vs `tokens.borderWidth` rule every d3_ui
  /// field already followed before this resolver existed.
  bool _isEmphasizedBorder(D3FieldStatus status) => switch (status) {
    D3FieldStatus.focused || D3FieldStatus.error || D3FieldStatus.success =>
      true,
    _ => false,
  };

  /// Resolves every visual property a field needs to paint itself for
  /// [status] in one call. Label/icon/helper text stay `onSurfaceVariant`
  /// except in the error state (`colors.error`) — matching the behavior
  /// both `D3TextField` and `D3DateField` already had before this resolver
  /// existed; this call replaces that per-field logic, it doesn't change it.
  D3FieldStyleResult resolveFieldStyle(
    D3FieldStatus status,
    D3ColorTokens colors,
    D3InputTokens tokens,
  ) {
    final textColor = status == D3FieldStatus.error
        ? colors.error
        : colors.onSurfaceVariant;

    return D3FieldStyleResult(
      borderColor: _resolveBorderColor(status, colors),
      backgroundColor: _resolveBackgroundColor(status, colors),
      borderWidth: _isEmphasizedBorder(status)
          ? tokens.focusedBorderWidth
          : tokens.borderWidth,
      labelColor: textColor,
      iconColor: textColor,
      helperTextColor: textColor,
    );
  }
}
