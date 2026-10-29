import 'package:d3_ui/d3_ui.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// A compact two-option switch with both labels visible, for a choice that
/// belongs on one row of a list: "Snore | Not snore", "Open | Closed".
///
/// It is [D3SegmentedControl]'s small sibling: the painted pill is 32 dp tall
/// but each half is a 48 dp touch target, so it fits a dense row without
/// shrinking the target. Both options are always readable, so the state is
/// clear without colour. Screen readers get one button per option, with the
/// chosen one selected, in a mutually exclusive group.
///
/// ```dart
/// D3SegmentSwitch<bool>(
///   semanticsLabel: 'Snore at 8:14 PM',
///   first: const D3Segment(value: true, label: 'Snore'),
///   second: const D3Segment(value: false, label: 'Not snore'),
///   value: isSnore,
///   onChanged: (v) => setState(() => isSnore = v),
/// )
/// ```
class D3SegmentSwitch<T extends Object> extends StatelessWidget {
  const D3SegmentSwitch({
    super.key,
    required this.first,
    required this.second,
    required this.value,
    required this.onChanged,
    this.semanticsLabel,
  });

  final D3Segment<T> first;
  final D3Segment<T> second;

  /// The chosen option's value.
  final T value;

  /// Called with the other option's value when it is tapped. Not called for
  /// the option that is already chosen.
  final ValueChanged<T> onChanged;

  /// Names the whole switch for screen readers.
  final String? semanticsLabel;

  static const double _painted = 32;
  static const double _hit = 48;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : D3Motion.fast;
    final style = (Theme.of(context).textTheme.labelMedium ?? const TextStyle())
        .copyWith(fontWeight: FontWeight.w600);

    Widget segment(D3Segment<T> s) {
      final chosen = s.value == value;
      return Semantics(
        button: true,
        selected: chosen,
        inMutuallyExclusiveGroup: true,
        label: s.semanticsLabel ?? s.label,
        excludeSemantics: true,
        onTap: chosen ? null : () => onChanged(s.value),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: chosen
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  onChanged(s.value);
                },
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: _hit, minHeight: _hit),
            child: Center(
              child: AnimatedContainer(
                duration: duration,
                curve: D3Motion.decelerate,
                height: _painted - 6,
                padding: const EdgeInsets.symmetric(horizontal: D3Spacing.s12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: chosen ? colors.primaryContainer : null,
                  borderRadius: BorderRadius.circular(D3Radius.full),
                ),
                child: Text(
                  s.label ?? '',
                  maxLines: 1,
                  softWrap: false,
                  style: style.copyWith(
                    color: chosen
                        ? colors.onPrimaryContainer
                        : colors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Semantics(
      container: true,
      label: semanticsLabel,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: (_hit - _painted) / 2,
            bottom: (_hit - _painted) / 2,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.surfaceContainerHigh,
                border: Border.all(color: colors.outlineVariant),
                borderRadius: BorderRadius.circular(D3Radius.full),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: D3Spacing.s2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [segment(first), segment(second)],
            ),
          ),
        ],
      ),
    );
  }
}
