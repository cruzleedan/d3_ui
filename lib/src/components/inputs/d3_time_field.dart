import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/d3_field_status.dart';
import 'helpers/d3_field_styling_mixin.dart';

/// Time field styled to match [D3DateField].
///
/// Tapping the field opens [showD3TimePicker]; [onChanged] fires with the
/// chosen [TimeOfDay]. The value shows as "9:30 AM", or "09:30" when
/// [use24h] is true (default: the platform's 24-hour setting).
///
/// ```dart
/// D3TimeField(
///   label: 'Reminder',
///   initialValue: const TimeOfDay(hour: 9, minute: 30),
///   minuteInterval: 15,
///   onChanged: (t) => print(t.format(context)),
/// )
/// ```
class D3TimeField extends StatefulWidget {
  const D3TimeField({
    super.key,
    required this.label,
    this.initialValue,
    this.hintText,
    this.helperText,
    this.errorText,
    this.isRequired = false,
    this.isEnabled = true,
    this.isCompact,
    this.isReadOnly = false,
    this.onChanged,
    this.semanticsLabel,
    this.use24h,
    this.minuteInterval = 1,
    this.displayFormat,
  });

  final String label;
  final TimeOfDay? initialValue;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final bool isRequired;
  final bool isEnabled;

  /// Overrides the theme's compact-density default for this field.
  final bool? isCompact;
  final bool isReadOnly;
  final ValueChanged<TimeOfDay>? onChanged;
  final String? semanticsLabel;

  /// 24-hour wheels and text. Null follows the platform setting.
  final bool? use24h;

  /// Minute wheel step; must divide 60 (5, 10, 15, 30).
  final int minuteInterval;

  /// Overrides the displayed text, e.g. `(t) => '${t.hour}h${t.minute}'`.
  final String Function(TimeOfDay)? displayFormat;

  @override
  State<D3TimeField> createState() => _D3TimeFieldState();
}

class _D3TimeFieldState extends State<D3TimeField> with D3FieldStylingMixin {
  TimeOfDay? _selected;
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
  void didUpdateWidget(covariant D3TimeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      _selected = widget.initialValue;
    }
  }

  bool get _use24h =>
      widget.use24h ?? MediaQuery.alwaysUse24HourFormatOf(context);

  Future<void> _pick() async {
    if (!widget.isEnabled || widget.isReadOnly) return;
    final picked = await showD3TimePicker(
      context,
      initialTime: _selected,
      use24h: _use24h,
      minuteInterval: widget.minuteInterval,
      title: widget.label,
    );
    if (picked != null && mounted) {
      setState(() => _selected = picked);
      widget.onChanged?.call(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.d3InputTokens;
    final isCompact = widget.isCompact ?? tokens.compactByDefault;
    final colors = context.d3Colors;
    final style = resolveFieldStyle(_status, colors, tokens);

    final displayText = _selected != null
        ? (widget.displayFormat ?? (t) => d3FormatTime(t, use24h: _use24h))(
            _selected!,
          )
        : null;

    Widget field = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: tokens.paddingH),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: tokens.labelSize,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurfaceVariant,
                    letterSpacing: -0.1,
                  ),
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
        SizedBox(height: isCompact ? D3Spacing.s2 : D3Spacing.s4),
        Stack(
          children: [
            Positioned.fill(
              top: isCompact ? D3Spacing.s4 : 0,
              bottom: isCompact ? D3Spacing.s4 : 0,
              child: IgnorePointer(
                child: AnimatedContainer(
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
                ),
              ),
            ),
            InkWell(
              onTap: widget.isEnabled && !widget.isReadOnly ? _pick : null,
              onHighlightChanged: (v) => setState(() => _isFocused = v),
              borderRadius: BorderRadius.circular(tokens.radius),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: tokens.minHeight < kMinInteractiveDimension
                      ? kMinInteractiveDimension
                      : tokens.minHeight,
                ),
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
                        Icons.schedule_outlined,
                        size: tokens.iconSize,
                        color: colors.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        if (widget.errorText != null || widget.helperText != null)
          Padding(
            padding: EdgeInsets.only(
              top: isCompact ? 0 : D3Spacing.s2,
              left: tokens.paddingH,
            ),
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
      value: displayText,
      button: true,
      enabled: widget.isEnabled,
      child: field,
    );
  }
}
