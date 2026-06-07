import 'package:d3_ui/d3_ui.dart';
import 'package:flutter/material.dart';

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
    this.firstDate,
    this.lastDate,
    this.onChanged,
    this.semanticsLabel,
  });

  final String label;
  final DateTime? initialValue;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final bool isRequired;
  final bool isEnabled;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final ValueChanged<DateTime>? onChanged;
  final String? semanticsLabel;

  @override
  State<D3DateField> createState() => _D3DateFieldState();
}

class _D3DateFieldState extends State<D3DateField> {
  DateTime? _selected;
  bool _isFocused = false;

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

    final picked = await showDatePicker(
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

    final hasError = widget.errorText != null;
    final borderColor = !widget.isEnabled
        ? colors.outline.withValues(alpha: 0.4)
        : hasError
            ? colors.error
            : _isFocused
                ? colors.primary
                : colors.outline;

    final bgColor = !widget.isEnabled
        ? colors.surfaceVariant
        : _isFocused
            ? colors.surface
            : colors.surfaceVariant;

    final displayText = _selected != null ? _format(_selected!) : null;

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
            color: bgColor,
            borderRadius: BorderRadius.circular(tokens.radius),
            border: Border.all(
              color: borderColor,
              width: (_isFocused || hasError)
                  ? tokens.focusedBorderWidth
                  : tokens.borderWidth,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
          child: InkWell(
            onTap: widget.isEnabled ? _pick : null,
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
            padding: EdgeInsets.only(
              top: D3Spacing.s4,
              left: tokens.paddingH,
            ),
            child: Text(
              widget.errorText ?? widget.helperText!,
              style: TextStyle(
                fontSize: tokens.helperSize,
                color: hasError ? colors.error : colors.onSurfaceVariant,
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
