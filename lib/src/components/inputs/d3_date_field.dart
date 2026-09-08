import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/d3_field_status.dart';
import 'helpers/d3_field_styling_mixin.dart';

/// Date picker field styled to match [D3TextField].
///
/// Tapping the field or calendar icon opens [showDatePicker].
/// [onChanged] fires with the selected [DateTime].
class D3DateField extends StatefulWidget {
  const D3DateField({
    super.key,
    required this.label,
    this.initialValue,
    this.hintText,
    this.helperText,
    this.errorText,
    this.isRequired = false,
    this.isEnabled = true,
    this.isReadOnly = false,
    this.firstDate,
    this.lastDate,
    this.onChanged,
    this.semanticsLabel,
    this.useD3CalendarPicker = false,
    this.markedDates,
    this.displayFormat,
  });

  final String label;
  final DateTime? initialValue;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final bool isRequired;
  final bool isEnabled;
  final bool isReadOnly;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final ValueChanged<DateTime>? onChanged;
  final String? semanticsLabel;

  /// Overrides the field's own ISO ("2026-09-04") display text with a
  /// caller-supplied formatter — e.g. `D3DateFormat.medium` for
  /// "Sep 4, 2026". Defaults to null (ISO), preserving every existing
  /// consumer's visual behavior unchanged; opt in per call site rather
  /// than changing the shared default, since some consumers may
  /// genuinely want the compact, sortable ISO shape.
  final String Function(DateTime)? displayFormat;

  /// Opt into [showD3CalendarPicker] (themed to match d3_ui) instead of the
  /// stock [showDatePicker]. Defaults to false to keep existing consumers'
  /// visual behavior unchanged.
  final bool useD3CalendarPicker;

  /// Days to mark with a dot indicator. Only used when
  /// [useD3CalendarPicker] is true.
  final Set<DateTime>? markedDates;

  @override
  State<D3DateField> createState() => _D3DateFieldState();
}

class _D3DateFieldState extends State<D3DateField> with D3FieldStylingMixin {
  DateTime? _selected;
  bool _isFocused = false;

  D3FieldStatus get _status => resolveD3FieldStatus(
    isEnabled: widget.isEnabled,
    isReadOnly: widget.isReadOnly,
    errorText: widget.errorText,
    hasFocus: _isFocused,
    hasContent: _selected != null,
  );

  @override
  void initState() {
    super.initState();
    _selected = widget.initialValue;
  }

  @override
  void didUpdateWidget(covariant D3DateField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      _selected = widget.initialValue;
    }
  }

  String _format(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<void> _pick() async {
    if (!widget.isEnabled) return;
    final now = DateTime.now();
    final initial = _selected ?? now;
    final first = widget.firstDate ?? DateTime(now.year - 5);
    final last = widget.lastDate ?? DateTime(now.year + 5);

    final picked = widget.useD3CalendarPicker
        ? await showD3CalendarPicker(
            context: context,
            initialDate: initial,
            firstDate: first,
            lastDate: last,
            markedDates: widget.markedDates,
            semanticsLabel: widget.semanticsLabel ?? widget.label,
          )
        : await showDatePicker(
            context: context,
            initialDate: initial.isBefore(first)
                ? first
                : initial.isAfter(last)
                ? last
                : initial,
            firstDate: first,
            lastDate: last,
          );

    if (picked != null) {
      setState(() => _selected = picked);
      widget.onChanged?.call(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.d3InputTokens;
    final colors = context.d3Colors;

    final status = _status;
    final style = resolveFieldStyle(status, colors, tokens);

    final displayText = _selected != null
        ? (widget.displayFormat ?? _format)(_selected!)
        : null;

    Widget field = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        Padding(
          padding: EdgeInsets.symmetric(horizontal: tokens.paddingH),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: tokens.labelSize,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurfaceVariant,
                  letterSpacing: -0.1,
                ),
              ),
              if (widget.isRequired) ...[
                const SizedBox(width: 2),
                Text(
                  '*',
                  style: TextStyle(
                    fontSize: tokens.labelSize,
                    fontWeight: FontWeight.w700,
                    color: colors.error,
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: D3Spacing.s6),

        // Input container
        AnimatedContainer(
          duration: tokens.borderAnimDuration,
          decoration: BoxDecoration(
            color: style.backgroundColor,
            borderRadius: BorderRadius.circular(tokens.radius),
            border: Border.all(
              color: style.borderColor,
              width: style.borderWidth,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
          child: InkWell(
            onTap: widget.isEnabled && !widget.isReadOnly ? _pick : null,
            onHighlightChanged: (v) => setState(() => _isFocused = v),
            borderRadius: BorderRadius.circular(tokens.radius),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: tokens.minHeight),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: tokens.paddingH,
                  vertical: tokens.paddingV,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        displayText ?? (widget.hintText ?? ''),
                        style: TextStyle(
                          fontSize: tokens.textSize,
                          color: displayText != null
                              ? colors.onSurface
                              : colors.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.calendar_today_outlined,
                      size: tokens.iconSize,
                      color: colors.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Helper / error
        if (widget.errorText != null || widget.helperText != null)
          Padding(
            padding: EdgeInsets.only(top: D3Spacing.s4, left: tokens.paddingH),
            child: Text(
              widget.errorText ?? widget.helperText!,
              style: TextStyle(
                fontSize: tokens.helperSize,
                color: style.helperTextColor,
                height: 1.4,
              ),
            ),
          ),
      ],
    );

    if (!widget.isEnabled) {
      field = Opacity(opacity: tokens.disabledOpacity, child: field);
    }

    return Semantics(
      label: widget.semanticsLabel ?? widget.label,
      button: true,
      enabled: widget.isEnabled,
      child: field,
    );
  }
}
