import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// D3NumericController
// ─────────────────────────────────────────────────────────────────────────────

/// A [TextEditingController] that stores and exposes a numeric value.
///
/// ```dart
/// final amount = D3NumericController(
///   initialValue: 1250.0,
///   decimalPlaces: 2,
/// );
///
/// // Set programmatically
/// amount.numericValue = 99.95;
///
/// // Read back
/// final total = amount.doubleValue; // 99.95
/// final qty   = amount.intValue;    // 99
///
/// // Use the paired formatter so live input stays clean
/// D3TextField(
///   label: 'Amount',
///   prefixText: '\$',
///   controller: amount,
///   keyboardType: const TextInputType.numberWithOptions(decimal: true),
///   inputFormatters: [amount.formatter],
/// )
/// ```
class D3NumericController extends TextEditingController {
  D3NumericController({
    num? initialValue,
    this.decimalPlaces = 2,
    this.groupSeparator = ',',
    this.decimalSeparator = '.',
  }) {
    if (initialValue != null) numericValue = initialValue;
  }

  /// Number of decimal places shown and enforced. Set to 0 for integers.
  final int decimalPlaces;

  /// Thousands separator character. Default: ','
  final String groupSeparator;

  /// Decimal separator character. Default: '.'
  final String decimalSeparator;

  // ── Typed value access ─────────────────────────────────────────────────────

  /// Sets the field text from a [num]. Formats and moves cursor to end.
  set numericValue(num value) {
    final formatted = _format(value.toDouble());
    value = value; // suppress unused warning
    text = formatted;
    selection = TextSelection.collapsed(offset: formatted.length);
  }

  /// Parses the current text to [double]. Returns `null` if the field is empty
  /// or contains non-numeric content.
  double? get doubleValue {
    final raw = _stripFormatting(text);
    if (raw.isEmpty) return null;
    return double.tryParse(raw);
  }

  /// Parses the current text to [int] (truncates decimals). Returns `null` if
  /// the field is empty or contains non-numeric content.
  int? get intValue => doubleValue?.toInt();

  // ── Paired formatter ───────────────────────────────────────────────────────

  /// A [TextInputFormatter] that live-formats input to match this controller's
  /// [groupSeparator], [decimalSeparator], and [decimalPlaces] settings.
  ///
  /// Pass this to [D3TextField.inputFormatters].
  D3NumericInputFormatter get formatter => D3NumericInputFormatter(
        decimalPlaces: decimalPlaces,
        groupSeparator: groupSeparator,
        decimalSeparator: decimalSeparator,
      );

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _stripFormatting(String value) =>
      value.replaceAll(groupSeparator, '').replaceAll(decimalSeparator, '.');

  String _format(double value) {
    final fixed = value.toStringAsFixed(decimalPlaces);
    final parts = fixed.split('.');
    final intPart = _addGroupSeparators(parts[0]);
    if (decimalPlaces == 0) return intPart;
    return '$intPart$decimalSeparator${parts[1]}';
  }

  String _addGroupSeparators(String digits) {
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      final remaining = digits.length - i;
      if (i > 0 && remaining % 3 == 0) buffer.write(groupSeparator);
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// D3NumericInputFormatter
// ─────────────────────────────────────────────────────────────────────────────

/// Formats numeric text input live — adds thousands separators, limits decimal
/// places, and strips non-numeric characters.
///
/// Used via [D3NumericController.formatter] but can also be created standalone.
class D3NumericInputFormatter extends TextInputFormatter {
  const D3NumericInputFormatter({
    this.decimalPlaces = 2,
    this.groupSeparator = ',',
    this.decimalSeparator = '.',
  });

  final int decimalPlaces;
  final String groupSeparator;
  final String decimalSeparator;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text;

    // Allow empty field.
    if (raw.isEmpty) return newValue;

    // Strip everything except digits and the decimal separator.
    final decEscaped = RegExp.escape(decimalSeparator);
    final digitsOnly = raw.replaceAll(RegExp('[^0-9$decEscaped]'), '');

    // Split on the first decimal separator only.
    final sepIndex = digitsOnly.indexOf(decimalSeparator);
    String intRaw;
    String? decRaw;

    if (sepIndex == -1) {
      intRaw = digitsOnly;
    } else {
      intRaw = digitsOnly.substring(0, sepIndex);
      decRaw = digitsOnly.substring(sepIndex + 1);
      // Enforce decimalPlaces limit.
      if (decRaw.length > decimalPlaces) {
        decRaw = decRaw.substring(0, decimalPlaces);
      }
    }

    // Strip leading zeros (but keep a single '0' before the decimal).
    if (intRaw.length > 1) intRaw = intRaw.replaceFirst(RegExp('^0+'), '');
    if (intRaw.isEmpty) intRaw = '0';

    // Add group separators to integer part.
    final intFormatted = _addGroupSeparators(intRaw);

    // Reconstruct.
    final result = decRaw != null
        ? '$intFormatted$decimalSeparator$decRaw'
        : (sepIndex != -1 && decimalPlaces > 0)
            ? '$intFormatted$decimalSeparator'
            : intFormatted;

    // Keep cursor at the end.
    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }

  String _addGroupSeparators(String digits) {
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      final remaining = digits.length - i;
      if (i > 0 && remaining % 3 == 0) buffer.write(groupSeparator);
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}
