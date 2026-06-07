import 'package:d3_ui/d3_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Decimal number input styled to match [D3TextField].
///
/// Accepts numeric input with up to [decimalPlaces] decimal digits.
/// [onChanged] fires with the parsed [double] value (0.0 if blank/invalid).
class D3DecimalField extends StatefulWidget {
  const D3DecimalField({
    super.key,
    required this.label,
    this.initialValue,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixText,
    this.isRequired = false,
    this.isEnabled = true,
    this.decimalPlaces = 2,
    this.maxValue,
    this.minValue,
    this.onChanged,
    this.semanticsLabel,
  });

  final String label;
  final double? initialValue;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final IconData? prefixIcon;
  final String? suffixText;
  final bool isRequired;
  final bool isEnabled;
  final int decimalPlaces;
  final double? maxValue;
  final double? minValue;
  final ValueChanged<double>? onChanged;
  final String? semanticsLabel;

  @override
  State<D3DecimalField> createState() => _D3DecimalFieldState();
}

class _D3DecimalFieldState extends State<D3DecimalField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: _format(widget.initialValue),
    );
    _focusNode = FocusNode()..addListener(_onFocusChange);
  }

  /// Returns the display string for [value], or empty string when the value is
  /// null or zero (so the hint is shown instead of "0.00").
  String _format(double? value) {
    if (value == null || value == 0.0) return '';
    return value.toStringAsFixed(widget.decimalPlaces);
  }

  @override
  void didUpdateWidget(covariant D3DecimalField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Never reformat while the user is actively editing — doing so would
    // snap the cursor to the end mid-input (bug 2).
    if (_isFocused) return;
    if (widget.initialValue != oldWidget.initialValue) {
      final newText = _format(widget.initialValue);
      if (_controller.text != newText) {
        _controller.text = newText;
        _controller.selection =
            TextSelection.collapsed(offset: newText.length);
      }
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.prefixIcon != null)
                Padding(
                  padding: EdgeInsets.only(left: tokens.paddingH),
                  child: Icon(
                    widget.prefixIcon,
                    size: tokens.iconSize,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              Expanded(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: tokens.minHeight),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: widget.prefixIcon != null
                          ? D3Spacing.s8
                          : tokens.paddingH,
                      vertical: tokens.paddingV,
                    ),
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      enabled: widget.isEnabled,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,' '${widget.decimalPlaces}' r'}'),
                        ),
                        if (widget.maxValue != null)
                          _MaxValueFormatter(widget.maxValue!),
                      ],
                      onChanged: (v) {
                        widget.onChanged?.call(double.tryParse(v) ?? 0.0);
                      },
                      style: TextStyle(
                        fontSize: tokens.textSize,
                        color: colors.onSurface,
                        height: 1.4,
                      ),
                      cursorColor: colors.primary,
                      decoration: InputDecoration(
                        hintText: widget.hintText,
                        hintStyle: TextStyle(
                          fontSize: tokens.textSize,
                          color: colors.onSurfaceVariant,
                        ),
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),
              if (widget.suffixText != null)
                Padding(
                  padding: EdgeInsets.only(right: tokens.paddingH),
                  child: Text(
                    widget.suffixText!,
                    style: TextStyle(
                      fontSize: tokens.textSize,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
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
      textField: true,
      enabled: widget.isEnabled,
      child: field,
    );
  }
}

class _MaxValueFormatter extends TextInputFormatter {
  const _MaxValueFormatter(this.maxValue);
  final double maxValue;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    final value = double.tryParse(newValue.text);
    if (value != null && value > maxValue) return oldValue;
    return newValue;
  }
}
