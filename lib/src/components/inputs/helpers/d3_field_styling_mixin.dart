import 'package:flutter/painting.dart';
import 'package:d3_ui/d3_ui.dart';

import 'd3_field_status.dart';

/// Resolves border/background color from [D3FieldStatus], replacing the
/// per-field `_borderColor`/`_bgColor` switch statements each d3_ui input
/// widget previously wrote independently.
mixin D3FieldStylingMixin {
  Color resolveBorderColor(D3FieldStatus status, D3ColorTokens colors) =>
      switch (status) {
        D3FieldStatus.focused => colors.primary,
        D3FieldStatus.error => colors.error,
        D3FieldStatus.success => colors.success,
        D3FieldStatus.disabled => colors.outline,
        _ => colors.outline,
      };

  Color resolveBackgroundColor(D3FieldStatus status, D3ColorTokens colors) =>
      switch (status) {
        D3FieldStatus.disabled => colors.surfaceVariant,
        D3FieldStatus.focused => colors.surface,
        D3FieldStatus.filled => colors.surface,
        D3FieldStatus.error => colors.surface,
        D3FieldStatus.success => colors.surface,
        _ => colors.surfaceVariant,
      };

  /// Border width should widen for focused/error/success — matches
  /// D3TextField's `tokens.focusedBorderWidth` vs `tokens.borderWidth` rule.
  bool isEmphasizedBorder(D3FieldStatus status) => switch (status) {
    D3FieldStatus.focused || D3FieldStatus.error || D3FieldStatus.success =>
      true,
    _ => false,
  };
}
