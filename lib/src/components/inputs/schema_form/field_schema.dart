import 'package:d3_ui/d3_ui.dart';

/// A single option for a [FieldType.dropdown] or [FieldType.segmentedButton]
/// field.
class FieldOption {
  const FieldOption({required this.value, required this.label});

  final String value;
  final String label;

  factory FieldOption.fromJson(Map<String, dynamic> json) =>
      FieldOption(value: json['value'] as String, label: json['label'] as String);

  Map<String, dynamic> toJson() => {'value': value, 'label': label};

  @override
  bool operator ==(Object other) =>
      other is FieldOption && other.value == value && other.label == label;

  @override
  int get hashCode => Object.hash(value, label);

  @override
  String toString() => 'FieldOption(value: $value, label: $label)';
}

/// Validation rules beyond simple presence, applied on top of
/// [FieldSchema.required].
///
/// Deliberately small — this is data, not code: no expressions, no
/// cross-field rules. If a form ever needs validation this can't express,
/// that's a sign the rule belongs in a real code path, not the schema.
class FieldValidation {
  const FieldValidation({
    this.minValue,
    this.maxValue,
    this.maxLength,
    this.pattern,
    this.patternMessage,
  });

  final double? minValue;
  final double? maxValue;
  final int? maxLength;

  /// A regular expression source string (no delimiters/flags).
  final String? pattern;

  /// Shown instead of the generic message when [pattern] fails to match.
  final String? patternMessage;

  factory FieldValidation.fromJson(Map<String, dynamic> json) => FieldValidation(
    minValue: (json['minValue'] as num?)?.toDouble(),
    maxValue: (json['maxValue'] as num?)?.toDouble(),
    maxLength: json['maxLength'] as int?,
    pattern: json['pattern'] as String?,
    patternMessage: json['patternMessage'] as String?,
  );

  Map<String, dynamic> toJson() => {
    if (minValue != null) 'minValue': minValue,
    if (maxValue != null) 'maxValue': maxValue,
    if (maxLength != null) 'maxLength': maxLength,
    if (pattern != null) 'pattern': pattern,
    if (patternMessage != null) 'patternMessage': patternMessage,
  };

  @override
  bool operator ==(Object other) =>
      other is FieldValidation &&
      other.minValue == minValue &&
      other.maxValue == maxValue &&
      other.maxLength == maxLength &&
      other.pattern == pattern &&
      other.patternMessage == patternMessage;

  @override
  int get hashCode =>
      Object.hash(minValue, maxValue, maxLength, pattern, patternMessage);
}

/// Describes one field in a schema-driven [FormSchema] — enough data to pick
/// a d3_ui input widget and configure it.
class FieldSchema {
  const FieldSchema({
    required this.key,
    required this.type,
    required this.label,
    this.required = false,
    this.isEnabled = true,
    this.hintText,
    this.helperText,
    this.decimalPlaces,
    this.maxLines,
    this.options,
    this.optionsSource,
    this.validation,
  });

  /// Matches a key in the form's value map and, at save time, a field on
  /// the domain entity being edited.
  final String key;
  final FieldType type;
  final String label;
  final bool required;

  /// `false` for a field the current role/context may only view, not edit.
  final bool isEnabled;
  final String? hintText;
  final String? helperText;

  /// [FieldType.decimal] only. Defaults to 2 when unset.
  final int? decimalPlaces;

  /// [FieldType.text] only. Defaults to 1 (single line) when unset.
  final int? maxLines;

  /// [FieldType.dropdown]/[FieldType.segmentedButton] only. Inline, static
  /// options.
  final List<FieldOption>? options;

  /// [FieldType.dropdown] only. Alternative to [options] — a reference the
  /// caller resolves to a live list before rendering (e.g. `"local:category"`).
  /// Never resolved by this package itself — schema parsing and rendering
  /// stay free of data-layer/business logic; the caller resolves this and
  /// hands the result to [FieldRenderer]/[SchemaForm].
  final String? optionsSource;
  final FieldValidation? validation;

  factory FieldSchema.fromJson(Map<String, dynamic> json) => FieldSchema(
    key: json['key'] as String,
    type: FieldType.values.byName(json['type'] as String),
    label: json['label'] as String,
    required: json['required'] as bool? ?? false,
    isEnabled: json['isEnabled'] as bool? ?? true,
    hintText: json['hintText'] as String?,
    helperText: json['helperText'] as String?,
    decimalPlaces: json['decimalPlaces'] as int?,
    maxLines: json['maxLines'] as int?,
    options: (json['options'] as List<dynamic>?)
        ?.map((o) => FieldOption.fromJson(o as Map<String, dynamic>))
        .toList(),
    optionsSource: json['optionsSource'] as String?,
    validation: json['validation'] == null
        ? null
        : FieldValidation.fromJson(json['validation'] as Map<String, dynamic>),
  );

  Map<String, dynamic> toJson() => {
    'key': key,
    'type': type.name,
    'label': label,
    'required': required,
    'isEnabled': isEnabled,
    if (hintText != null) 'hintText': hintText,
    if (helperText != null) 'helperText': helperText,
    if (decimalPlaces != null) 'decimalPlaces': decimalPlaces,
    if (maxLines != null) 'maxLines': maxLines,
    if (options != null) 'options': options!.map((o) => o.toJson()).toList(),
    if (optionsSource != null) 'optionsSource': optionsSource,
    if (validation != null) 'validation': validation!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      other is FieldSchema &&
      other.key == key &&
      other.type == type &&
      other.label == label &&
      other.required == required &&
      other.isEnabled == isEnabled &&
      other.hintText == hintText &&
      other.helperText == helperText &&
      other.decimalPlaces == decimalPlaces &&
      other.maxLines == maxLines &&
      _listEquals(other.options, options) &&
      other.optionsSource == optionsSource &&
      other.validation == validation;

  @override
  int get hashCode => Object.hash(
    key,
    type,
    label,
    required,
    isEnabled,
    hintText,
    helperText,
    decimalPlaces,
    maxLines,
    Object.hashAll(options ?? const []),
    optionsSource,
    validation,
  );
}

bool _listEquals<T>(List<T>? a, List<T>? b) {
  if (a == null) return b == null;
  if (b == null || a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Validates [value] against [field]; returns an error message or `null`.
///
/// Pure function — no `BuildContext`, no Riverpod — so it can run from a
/// caller's own validate step or a widget test alike.
String? validateFieldValue(FieldSchema field, Object? value) {
  // A field the current role/context can only view, not edit, can't be
  // user-fixed to satisfy `required` or any other rule — nothing to
  // validate.
  if (!field.isEnabled) return null;

  if (field.required) {
    final isEmpty = value == null || (value is String && value.trim().isEmpty);
    if (isEmpty) return '${field.label} is required';
  }

  final rules = field.validation;
  if (rules == null || value == null) return null;

  if (value is num) {
    if (rules.minValue != null && value < rules.minValue!) {
      return '${field.label} must be at least ${rules.minValue}';
    }
    if (rules.maxValue != null && value > rules.maxValue!) {
      return '${field.label} must be at most ${rules.maxValue}';
    }
  }

  if (value is String) {
    if (rules.maxLength != null && value.length > rules.maxLength!) {
      return '${field.label} must be ${rules.maxLength} characters or fewer';
    }
    if (rules.pattern != null && value.isNotEmpty) {
      final matches = RegExp(rules.pattern!).hasMatch(value);
      if (!matches) {
        return rules.patternMessage ?? '${field.label} is invalid';
      }
    }
  }

  return null;
}
