import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// A compact pill that shows the current choice and opens a [D3Menu] of the
/// others, in the same style as the filter pill of [D3ListScreen].
///
/// Use it for a single-choice setting that belongs beside a list, such as how
/// it is sorted. It is 48 dp tall to touch; the pill itself is smaller.
///
/// ```dart
/// D3MenuPill<Sort>(
///   semanticsLabel: 'Sort',
///   options: [
///     D3FilterOption(value: Sort.newest, label: 'Newest first'),
///     D3FilterOption(value: Sort.oldest, label: 'Oldest first'),
///   ],
///   value: sort,
///   onSelected: (s) => setState(() => sort = s),
/// )
/// ```
class D3MenuPill<T> extends StatelessWidget {
  const D3MenuPill({
    super.key,
    required this.options,
    required this.value,
    required this.onSelected,
    required this.semanticsLabel,
    this.icon = Icons.swap_vert_rounded,
  });

  /// The choices, in menu order. The label of the one equal to [value] is
  /// shown on the pill.
  final List<D3FilterOption<T>> options;

  /// The current choice.
  final T value;

  /// Called with the chosen value after the menu has closed.
  final ValueChanged<T> onSelected;

  /// What the pill is for ("Sort"); read with the current choice.
  final String semanticsLabel;

  /// The icon before the label.
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    final current = options.firstWhere(
      (o) => o.value == value,
      orElse: () => options.first,
    );
    return D3Menu(
      alignment: Alignment.topLeft,
      entries: [
        for (final o in options)
          D3MenuItem(
            label: o.label,
            icon: o.icon,
            isSelected: o.value == value,
            onPressed: () => onSelected(o.value),
          ),
      ],
      triggerBuilder: (context, toggle) => Semantics(
        button: true,
        label: '$semanticsLabel: ${current.label}',
        excludeSemantics: true,
        child: GestureDetector(
          onTap: toggle,
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            height: 48,
            child: Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.onSurface.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(D3Radius.full),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: D3Spacing.s12,
                    vertical: D3Spacing.s6,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 14, color: colors.onSurfaceVariant),
                      const SizedBox(width: D3Spacing.s4),
                      Text(
                        current.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: D3Spacing.s2),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 14,
                        color: colors.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
