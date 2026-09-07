import 'package:d3_ui/d3_ui.dart';
import 'package:flutter/material.dart';

/// Renders a whole [FormSchema] as one form body.
///
/// Purely presentational and data-layer-free, matching [FieldRenderer]'s own
/// principle one level up: [schema], [values], and [errors] are handed in
/// already resolved, and every edit is reported via [onFieldChanged] — this
/// widget owns no state of its own (no loading, no caching, no app-level
/// state subscription). The caller is responsible for:
/// - resolving the [FormSchema] itself (from wherever it's stored) before
///   rendering this widget
/// - owning the value/error bag (e.g. its own state notifier) that
///   [values]/[errors] read from and [onFieldChanged] writes into
/// - resolving any [FieldSchema.optionsSource] via [optionsResolver]
class SchemaForm extends StatefulWidget {
  const SchemaForm({
    super.key,
    required this.schema,
    required this.values,
    required this.errors,
    required this.onFieldChanged,
    this.optionsResolver,
    this.creators,
  });

  final FormSchema schema;

  /// Current value for each field, keyed by [FieldSchema.key].
  final Map<String, Object?> values;

  /// Current validation error for each field (if any), keyed by
  /// [FieldSchema.key].
  final Map<String, String> errors;

  /// Fired on every field edit with the field's key and new value.
  final void Function(String key, Object? value) onFieldChanged;

  /// Resolves a [FieldSchema.optionsSource] reference (e.g. `"local:category"`)
  /// to a live options list.
  final OptionsResolver? optionsResolver;

  /// Per-field inline "create new option" builders, keyed by
  /// [FieldSchema.key]. A dropdown field with no entry here — the default
  /// for any field a caller doesn't opt into — shows an empty options list
  /// as disabled with an explanatory helper text instead of a create
  /// affordance (see [FieldRenderer]).
  final Map<String, DropdownCreator>? creators;

  @override
  State<SchemaForm> createState() => _SchemaFormState();
}

/// Resolves a [FieldSchema.optionsSource] reference (e.g. `"local:category"`)
/// to a live options list. Kept outside [SchemaForm] itself so option
/// resolution — a data-layer concern — never lives in this presentational
/// widget tree.
typedef OptionsResolver = Future<List<FieldOption>> Function(String source);

/// Builds the inline "create a new option" UI for one [FieldType.dropdown]
/// field — e.g. a category-creation form. Calls [onCreated] with the new
/// option once created; [SchemaForm] closes the sheet and adds the option to
/// that field's resolved list itself, so the builder only needs to know how
/// to create the underlying record. Kept outside [FieldRenderer] for the
/// same reason as [OptionsResolver] — creating a real record is a
/// data-layer concern, not something a purely presentational widget does.
typedef DropdownCreator = Widget Function(
  BuildContext context,
  void Function(FieldOption created) onCreated,
);

class _SchemaFormState extends State<SchemaForm> {
  final Map<String, List<FieldOption>> _resolvedOptions = {};

  /// Mirrors [_resolvedOptions] per dropdown field, lazily created. A plain
  /// `setState` rebuild changes the `items` a [FieldRenderer] is built with,
  /// but `D3DropdownField`'s sheet, once open, is a separate modal route
  /// that doesn't see that rebuild — only a listenable it was explicitly
  /// given does. This is what lets [_openCreateSheet] make a newly created
  /// option show up in a sheet the user already has open.
  final Map<String, ValueNotifier<List<FieldOption>>> _sheetItemsNotifiers = {};

  ValueNotifier<List<FieldOption>> _notifierFor(String key) =>
      _sheetItemsNotifiers.putIfAbsent(
        key,
        () => ValueNotifier(_resolvedOptions[key] ?? const []),
      );

  void _setOptions(String key, List<FieldOption> options) {
    setState(() => _resolvedOptions[key] = options);
    _sheetItemsNotifiers[key]?.value = options;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolveOptions());
  }

  @override
  void didUpdateWidget(covariant SchemaForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.schema != widget.schema) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _resolveOptions());
    }
  }

  @override
  void dispose() {
    for (final notifier in _sheetItemsNotifiers.values) {
      notifier.dispose();
    }
    super.dispose();
  }

  Future<void> _resolveOptions() async {
    final resolver = widget.optionsResolver;
    if (resolver == null) return;

    for (final field in widget.schema.fields) {
      final source = field.optionsSource;
      if (source == null) continue;
      final options = await resolver(source);
      if (!mounted) return;
      _setOptions(field.key, options);
    }
  }

  /// [dropdownSheetContext] is the still-open `D3DropdownField` selection
  /// sheet's own context (see [FieldRenderer.onCreateNew]). Once a value is
  /// created/resolved, this both applies it to the form (so it's correct
  /// even if the sheet context is gone) and pops that sheet with the value
  /// — otherwise creating (or a `creator` resolving to an existing option,
  /// e.g. a dedup match) only updates the sheet's displayed list, leaving
  /// the user to manually find and tap it to actually select it.
  Future<void> _openCreateSheet(
    FieldSchema field,
    DropdownCreator creator,
    BuildContext dropdownSheetContext,
  ) async {
    final created = await D3BottomSheet.show<FieldOption?>(
      context,
      title: 'New ${field.label}',
      snapPoints: const [D3SnapPoint(0.75)],
      // A Builder so onCreated pops with a context inside the sheet's own
      // scope — D3BottomSheet.pop looks up its scope from the context it's
      // called with, and this widget's own `context` is outside the sheet.
      child: Builder(
        builder: (sheetContext) => creator(
          sheetContext,
          (option) => D3BottomSheet.pop(sheetContext, option),
        ),
      ),
    );
    if (created == null || !mounted) return;

    final existing = _resolvedOptions[field.key] ?? const <FieldOption>[];
    final alreadyPresent = existing.any((o) => o.value == created.value);
    if (!alreadyPresent) {
      _setOptions(field.key, [...existing, created]);
    }

    widget.onFieldChanged(field.key, created.value);

    if (dropdownSheetContext.mounted) {
      D3BottomSheet.pop(dropdownSheetContext, created);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 16.0,
          children: [
            for (final field in widget.schema.fields)
              FieldRenderer(
                field: field,
                value: widget.values[field.key],
                errorText: widget.errors[field.key],
                resolvedOptions: _resolvedOptions[field.key],
                sheetItemsNotifier: field.type == FieldType.dropdown
                    ? _notifierFor(field.key)
                    : null,
                onCreateNew: widget.creators?[field.key] == null
                    ? null
                    : (sheetContext) => _openCreateSheet(
                        field,
                        widget.creators![field.key]!,
                        sheetContext,
                      ),
                onChanged: (value) => widget.onFieldChanged(field.key, value),
              ),
          ],
        ),
      ),
    );
  }
}
