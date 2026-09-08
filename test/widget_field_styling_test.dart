import 'package:flutter_test/flutter_test.dart';
import 'package:d3_ui/d3_ui.dart';
import 'package:d3_ui/src/components/inputs/helpers/d3_field_status.dart';
import 'package:d3_ui/src/components/inputs/helpers/d3_field_styling_mixin.dart';

class _TestField with D3FieldStylingMixin {}

void main() {
  group('resolveD3FieldStatus — centralized precedence', () {
    test('disabled beats every other state', () {
      expect(
        resolveD3FieldStatus(
          isEnabled: false,
          errorText: 'err',
          successText: 'ok',
          hasFocus: true,
          hasContent: true,
        ),
        D3FieldStatus.disabled,
      );
    });

    test('isReadOnly maps to disabled', () {
      expect(
        resolveD3FieldStatus(isEnabled: true, isReadOnly: true),
        D3FieldStatus.disabled,
      );
    });

    test('error beats success/focused/filled', () {
      expect(
        resolveD3FieldStatus(
          isEnabled: true,
          errorText: 'err',
          successText: 'ok',
          hasFocus: true,
          hasContent: true,
        ),
        D3FieldStatus.error,
      );
    });

    test('success beats focused/filled', () {
      expect(
        resolveD3FieldStatus(
          isEnabled: true,
          successText: 'ok',
          hasFocus: true,
          hasContent: true,
        ),
        D3FieldStatus.success,
      );
    });

    test('focused beats filled', () {
      expect(
        resolveD3FieldStatus(isEnabled: true, hasFocus: true, hasContent: true),
        D3FieldStatus.focused,
      );
    });

    test('filled when content but not focused', () {
      expect(
        resolveD3FieldStatus(isEnabled: true, hasContent: true),
        D3FieldStatus.filled,
      );
    });

    test('idle by default', () {
      expect(resolveD3FieldStatus(isEnabled: true), D3FieldStatus.idle);
    });
  });

  group('D3FieldStylingMixin.resolveFieldStyle', () {
    late D3ColorTokens colors;
    late D3InputTokens tokens;
    final field = _TestField();

    setUp(() {
      final ext = D3AppTheme.light().extension<D3TokensExtension>()!;
      colors = ext.colors;
      tokens = ext.inputTokens;
    });

    test('error status resolves error color for border and text', () {
      final style = field.resolveFieldStyle(
        D3FieldStatus.error,
        colors,
        tokens,
      );
      expect(style.borderColor, colors.error);
      expect(style.labelColor, colors.error);
      expect(style.iconColor, colors.error);
      expect(style.helperTextColor, colors.error);
      expect(style.borderWidth, tokens.focusedBorderWidth);
    });

    test('idle status uses outline/onSurfaceVariant, thin border', () {
      final style = field.resolveFieldStyle(
        D3FieldStatus.idle,
        colors,
        tokens,
      );
      expect(style.borderColor, colors.outline);
      expect(style.labelColor, colors.onSurfaceVariant);
      expect(style.borderWidth, tokens.borderWidth);
    });

    test('success status widens the border like focused/error', () {
      final style = field.resolveFieldStyle(
        D3FieldStatus.success,
        colors,
        tokens,
      );
      expect(style.borderColor, colors.success);
      expect(style.borderWidth, tokens.focusedBorderWidth);
    });

    test('disabled status uses a thin, non-emphasized border', () {
      final style = field.resolveFieldStyle(
        D3FieldStatus.disabled,
        colors,
        tokens,
      );
      expect(style.borderColor, colors.outline);
      expect(style.backgroundColor, colors.surfaceVariant);
      expect(style.borderWidth, tokens.borderWidth);
    });
  });
}
