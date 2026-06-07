import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:d3_ui/d3_ui.dart';

// ─────────────────────────────────────────────────────────────────────────────
// D3FilterOption
// ─────────────────────────────────────────────────────────────────────────────

/// A single option in a [D3FilterChipRow].
class D3FilterOption<T> {
  const D3FilterOption({
    required this.value,
    required this.label,
    this.icon,
  });

  final T value;
  final String label;
  final IconData? icon;
}

// ─────────────────────────────────────────────────────────────────────────────
// D3FilterChipRow
// ─────────────────────────────────────────────────────────────────────────────

/// A horizontally scrollable row of filter chips.
///
/// **Single-select** (default) — only one chip can be active at a time. Tapping
/// an already-selected chip has no effect (at least one value always selected).
///
/// **Multi-select** — any combination of chips can be active simultaneously.
///
/// The widget is stateless — the caller owns the selected values and updates
/// them via [onChanged].
///
/// ```dart
/// // Single-select (e.g. view filter: All / Reports / Expenses)
/// D3FilterChipRow<String>(
///   options: const [
///     D3FilterOption(value: 'all',     label: 'All'),
///     D3FilterOption(value: 'reports', label: 'Reports', icon: Icons.folder_outlined),
///     D3FilterOption(value: 'expenses',label: 'Expenses', icon: Icons.receipt_long_outlined),
///   ],
///   selected: {_filter},
///   onChanged: (values) => setState(() => _filter = values.first),
/// )
///
/// // Multi-select (e.g. genre tags)
/// D3FilterChipRow<String>(
///   options: _genres.map((g) => D3FilterOption(value: g, label: g)).toList(),
///   selected: _selectedGenres,
///   onChanged: (values) => setState(() => _selectedGenres = values),
///   multiSelect: true,
/// )
/// ```
class D3FilterChipRow<T> extends StatelessWidget {
  const D3FilterChipRow({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.multiSelect = false,
    this.padding,
  }) : assert(options.length > 0, 'D3FilterChipRow requires at least one option.');

  final List<D3FilterOption<T>> options;

  /// Currently selected values. For single-select this should be a set of
  /// exactly one element; for multi-select any number.
  final Set<T> selected;

  /// Called with the new selected set whenever the user taps a chip.
  final ValueChanged<Set<T>> onChanged;

  /// When true, multiple chips can be selected simultaneously.
  /// Defaults to false (single-select).
  final bool multiSelect;

  /// Padding around the scrollable row. Defaults to horizontal 16dp.
  final EdgeInsetsGeometry? padding;

  void _onTap(T value) {
    HapticFeedback.selectionClick();
    if (multiSelect) {
      final next = Set<T>.from(selected);
      if (next.contains(value)) {
        next.remove(value);
      } else {
        next.add(value);
      }
      onChanged(next);
    } else {
      // Single-select: no-op if already selected (always keep one active).
      if (!selected.contains(value)) {
        onChanged({value});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: D3Spacing.s16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < options.length; i++) ...[
            if (i > 0) const SizedBox(width: D3Spacing.s8),
            D3Chip(
              label: options[i].label,
              leadingIcon: options[i].icon,
              selected: selected.contains(options[i].value),
              onTap: () => _onTap(options[i].value),
            ),
          ],
        ],
      ),
    );
  }
}
