import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// Renders one [FieldSchema] node as the matching d3_ui input widget.
///
/// Purely presentational — takes its current [value] and reports changes via
/// [onChanged], the same shape every d3_ui input already uses. It never
/// reads app-level state, resolves `optionsSource`, or touches a database
/// itself; the caller (a [SchemaForm]) owns the value bag and resolves
/// dropdown options before handing them to this widget.
class FieldRenderer extends StatelessWidget {
  const FieldRenderer({
    super.key,
    required this.field,
    required this.value,
    required this.onChanged,
    this.errorText,
    this.resolvedOptions,
    this.onCreateNew,
    this.sheetItemsNotifier,
  });

  final FieldSchema field;
  final Object? value;
  final ValueChanged<Object?> onChanged;
  final String? errorText;

  /// Options for a [FieldType.dropdown]/[FieldType.segmentedButton] field,
  /// resolved by the caller from [FieldSchema.optionsSource] when set —
  /// falls back to [FieldSchema.options] (inline, static options) when this
  /// is null.
  final List<FieldOption>? resolvedOptions;

  /// [FieldType.dropdown] only. When the caller (a [SchemaForm] with a
  /// matching entry in its `creators` map) supports creating a new option
  /// inline, this opens that flow — shown as a "+" action next to the
  /// sheet's search field, and used to decide whether an empty options
  /// list should still be tappable rather than showing as disabled.
  ///
  /// Receives the `_CreateNewButton`'s own [BuildContext] — which sits
  /// inside `D3DropdownField`'s open selection sheet — so the caller can
  /// close that sheet (via `D3BottomSheet.pop`) once a value is chosen.
  /// Without this, creating (or resolving to an existing) option only
  /// updates the sheet's displayed list; the user still has to manually
  /// find and tap it to actually select it.
  final Future<void> Function(BuildContext sheetContext)? onCreateNew;

  /// [FieldType.dropdown] only, and only meaningful alongside [onCreateNew].
  /// `D3DropdownField`'s sheet listens to this while open — the caller
  /// updates it after a create succeeds so a newly created option appears
  /// in the sheet the user already has open, without them needing to close
  /// and reopen it to see it (a plain rebuild with new `resolvedOptions`
  /// doesn't reach an already-open modal sheet).
  final ValueNotifier<List<FieldOption>>? sheetItemsNotifier;

  @override
  Widget build(BuildContext context) {
    switch (field.type) {
      case FieldType.text:
        return D3TextField(
          label: field.label,
          initialValue: value as String? ?? '',
          isRequired: field.required,
          isEnabled: field.isEnabled,
          hintText: field.hintText,
          helperText: field.helperText,
          errorText: errorText,
          maxLines: field.maxLines ?? 1,
          onChanged: onChanged,
        );

      case FieldType.decimal:
        return D3DecimalField(
          label: field.label,
          initialValue: (value as num?)?.toDouble(),
          isRequired: field.required,
          isEnabled: field.isEnabled,
          errorText: errorText,
          decimalPlaces: field.decimalPlaces ?? 2,
          onChanged: onChanged,
        );

      case FieldType.date:
        return D3DateField(
          label: field.label,
          initialValue: value as DateTime?,
          isRequired: field.required,
          isEnabled: field.isEnabled,
          errorText: errorText,
          onChanged: onChanged,
        );

      case FieldType.dropdown:
        final items = resolvedOptions ?? field.options ?? const <FieldOption>[];
        final isEmpty = items.isEmpty;
        return D3DropdownField<FieldOption, String>(
          label: field.label,
          items: items,
          itemLabel: (o) => o.label,
          itemValue: (o) => o.value,
          initialValue: value as String?,
          isRequired: field.required,
          errorText: errorText,
          // A role-scoped read-only field (field.isEnabled == false) always
          // wins over the empty-options disable below — no point offering a
          // "create new" affordance on a field the current context can't
          // edit. Otherwise: no options and no way to create one inline —
          // disable the field instead of leaving it tappable-but-empty, and
          // say why via helperText so it doesn't look broken. If options
          // simply haven't resolved yet (in flight), this also shows
          // briefly, which is accurate — there's nothing to pick yet
          // either way.
          isEnabled: field.isEnabled && (!isEmpty || onCreateNew != null),
          helperText: !field.isEnabled
              ? field.helperText
              : (isEmpty
                    ? (onCreateNew != null
                          ? 'No options yet — tap + to create one'
                          : 'No options available yet')
                    : field.helperText),
          // Always sheet mode, never popup: `PopupMenuButton` (popup mode)
          // requires a non-empty item list and misbehaves with zero items —
          // a real state for a schema-driven dropdown whose options haven't
          // resolved yet (in flight) or are genuinely empty (e.g. a fresh
          // install with no categories created yet). The sheet's empty
          // state ("No results") is visible and correct either way.
          mode: D3DropdownMode.sheet,
          searchable: items.length > 5 || onCreateNew != null,
          sheetSearchAction: onCreateNew == null
              ? null
              : _CreateNewButton(onTap: onCreateNew!),
          sheetItemsNotifier: sheetItemsNotifier,
          onChanged: (option) => onChanged(option?.value),
        );

      case FieldType.toggle:
        return D3Toggle(
          value: value as bool? ?? false,
          label: field.label,
          // D3Toggle has no isEnabled prop — passing a null onChanged is
          // its own documented way to disable it.
          onChanged: field.isEnabled ? onChanged : null,
        );

      case FieldType.segmentedButton:
        final items = resolvedOptions ?? field.options ?? const <FieldOption>[];
        if (items.length < 2) {
          // D3SegmentedControl requires 2-4 segments — a schema-driven
          // field with fewer than 2 configured options is a config error,
          // not a runtime state to render around silently.
          return Text(
            '${field.label}: not enough options configured '
            '(needs 2-4, got ${items.length})',
            style: TextStyle(color: context.d3Colors.error),
          );
        }
        return _LabeledSegmentedControl(
          field: field,
          items: items.length > 4 ? items.sublist(0, 4) : items,
          value: value as String?,
          onChanged: onChanged,
        );
    }
  }
}

class _LabeledSegmentedControl extends StatelessWidget {
  const _LabeledSegmentedControl({
    required this.field,
    required this.items,
    required this.value,
    required this.onChanged,
  });

  final FieldSchema field;
  final List<FieldOption> items;
  final String? value;
  final ValueChanged<Object?> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          field.label,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 6),
        D3SegmentedControl<String>(
          segments: [for (final o in items) D3Segment(value: o.value, label: o.label)],
          selected: value,
          expand: true,
          onChanged: field.isEnabled ? onChanged : (_) {},
        ),
      ],
    );
  }
}

class _CreateNewButton extends StatelessWidget {
  const _CreateNewButton({required this.onTap});
  final Future<void> Function(BuildContext sheetContext) onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    return IconButton(
      onPressed: () => onTap(context),
      icon: Icon(Icons.add_rounded, color: colors.primary),
      tooltip: 'Create new',
      style: IconButton.styleFrom(
        backgroundColor: colors.surfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
