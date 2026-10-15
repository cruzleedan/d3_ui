import 'dart:math' as math;

import 'package:d3_ui/d3_ui.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// What characters a [D3OtpField] accepts.
enum D3OtpType {
  /// Digits 0 to 9 with the numeric keypad.
  digits,

  /// Letters and digits with the text keyboard.
  alphanumeric,
}

/// A one-time-code field drawn as separate cells.
///
/// Under the cells sits one real text field, so paste, the numeric keypad and
/// SMS autofill (`AutofillHints.oneTimeCode`) all work. Tap any cell to focus
/// it. The active cell is highlighted with the primary colour and a caret line.
/// Backspace deletes the last character. A pasted code that is too long is
/// truncated, and characters that [type] does not allow are dropped.
///
/// Cells are 48 wide and 56 tall, and shrink (down to 40 wide) so six of them
/// fit a 320dp screen. [onCompleted] fires each time the last cell is filled.
/// When [errorText] is set the cells turn to the error colour, the message
/// shows below, and the cells shake once unless reduced motion is on.
///
/// Screen readers get one text field named [label], whose value is hidden when
/// [obscureText] is true.
///
/// ```dart
/// D3OtpField(
///   length: 6,
///   autofocus: true,
///   errorText: _wrong ? 'That code is not right' : null,
///   onCompleted: (code) => verify(code),
/// )
/// ```
class D3OtpField extends StatefulWidget {
  const D3OtpField({
    super.key,
    this.length = 6,
    this.type = D3OtpType.digits,
    this.controller,
    this.onChanged,
    this.onCompleted,
    this.errorText,
    this.obscureText = false,
    this.enabled = true,
    this.autofocus = false,
    this.label = 'Verification code',
    this.autofillHints = const [AutofillHints.oneTimeCode],
  }) : assert(length > 0);

  /// How many cells there are.
  final int length;

  final D3OtpType type;

  /// Holds the typed code. Created internally when null.
  final TextEditingController? controller;

  /// Called with the whole code after each edit.
  final ValueChanged<String>? onChanged;

  /// Called with the code when every cell is filled.
  final ValueChanged<String>? onCompleted;

  /// Shows the cells in the error colour with this message below.
  final String? errorText;

  /// Shows a dot instead of each character.
  final bool obscureText;

  final bool enabled;

  final bool autofocus;

  /// Names the field for screen readers.
  final String label;

  final Iterable<String>? autofillHints;

  @override
  State<D3OtpField> createState() => _D3OtpFieldState();
}

class _D3OtpFieldState extends State<D3OtpField>
    with SingleTickerProviderStateMixin {
  static const double _cellWidth = 48;
  static const double _cellMinWidth = 40;
  static const double _cellHeight = 56;

  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: D3Motion.moderate,
  );
  final FocusNode _focus = FocusNode();
  TextEditingController? _ownController;

  TextEditingController get _controller =>
      widget.controller ?? (_ownController ??= TextEditingController());

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onText);
    _focus.addListener(_onFocus);
  }

  @override
  void didUpdateWidget(D3OtpField old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      (old.controller ?? _ownController)?.removeListener(_onText);
      _controller.addListener(_onText);
    }
    if (old.errorText == null &&
        widget.errorText != null &&
        !MediaQuery.disableAnimationsOf(context)) {
      _shake.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onText);
    _focus.dispose();
    _ownController?.dispose();
    _shake.dispose();
    super.dispose();
  }

  void _onFocus() => setState(() {});

  void _onText() {
    // Keep the caret at the end: cells show no selection.
    final text = _controller.text;
    final sel = _controller.selection;
    if (!sel.isCollapsed || sel.baseOffset != text.length) {
      _controller.selection = TextSelection.collapsed(offset: text.length);
      return;
    }
    if (mounted) setState(() {});
  }

  void _changed(String value) {
    widget.onChanged?.call(value);
    if (value.length == widget.length) widget.onCompleted?.call(value);
  }

  void _focusField() {
    if (!widget.enabled) return;
    _focus.requestFocus();
    // Bring the keyboard back if it was dismissed while the field kept focus. Not
    // on the web, where focusing the field's own input is enough, and the raw
    // channel call throws when no text input client is attached yet.
    if (!kIsWeb) {
      SystemChannels.textInput.invokeMethod<void>('TextInput.show');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    final dim = context.d3ButtonTokens.disabledOpacity;
    final text = _controller.text;
    final hasError = widget.errorText != null;
    final focused = _focus.hasFocus && widget.enabled;
    final active = math.min(text.length, widget.length - 1);

    final idle = d3EnsureContrast(colors.outline, colors.surface, minRatio: 3);
    final errorColor = d3EnsureContrast(
      colors.error,
      colors.surface,
      minRatio: 4.5,
    );
    final digitColor = hasError
        ? errorColor
        : d3EnsureContrast(colors.onSurface, colors.surfaceContainerLow);
    final scaler = MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.5);

    final formatters = <TextInputFormatter>[
      widget.type == D3OtpType.digits
          ? FilteringTextInputFormatter.digitsOnly
          : FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
      LengthLimitingTextInputFormatter(widget.length),
    ];

    Widget cell(int i, double width) {
      final has = i < text.length;
      final isActive = focused && i == active;
      final borderColor = hasError
          ? errorColor
          : isActive
          ? d3EnsureContrast(colors.primary, colors.surface, minRatio: 3)
          : idle;
      Widget content;
      if (has) {
        content = Text(
          widget.obscureText ? '•' : text[i],
          textScaler: scaler,
          style: TextStyle(
            fontSize: D3TypeScale.displaySmSize,
            fontWeight: FontWeight.w600,
            color: digitColor,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        );
      } else if (isActive) {
        content = Container(
          width: 2,
          height: 24,
          color: hasError ? errorColor : colors.primary,
        );
      } else {
        content = const SizedBox.shrink();
      }
      return Material(
        color: colors.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: context.d3Shape.circularMd,
          side: BorderSide(
            color: borderColor,
            width: isActive || hasError ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _focusField,
          child: SizedBox(
            width: width,
            height: _cellHeight,
            child: Center(child: content),
          ),
        ),
      );
    }

    final field = LayoutBuilder(
      builder: (context, constraints) {
        final n = widget.length;
        var gap = D3Spacing.s8;
        var w = _cellWidth;
        final avail = constraints.maxWidth;
        if (avail.isFinite) {
          w = math.min(_cellWidth, (avail - gap * (n - 1)) / n);
          if (w < _cellMinWidth) {
            w = _cellMinWidth;
            gap = n > 1 ? math.max(2.0, (avail - w * n) / (n - 1)) : 0;
            gap = math.min(gap, D3Spacing.s8);
          }
        }
        Widget row = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < n; i++) ...[
              if (i > 0) SizedBox(width: gap),
              cell(i, w),
            ],
          ],
        );
        if (avail.isFinite && w * n + gap * (n - 1) > avail + 0.01) {
          row = FittedBox(fit: BoxFit.scaleDown, child: row);
        }
        return Stack(
          alignment: Alignment.center,
          children: [
            // The one real field, under the cells. It takes taps in the gaps.
            Positioned.fill(
              child: TextField(
                controller: _controller,
                focusNode: _focus,
                autofocus: widget.autofocus,
                enabled: widget.enabled,
                keyboardType: widget.type == D3OtpType.digits
                    ? TextInputType.number
                    : TextInputType.text,
                textCapitalization: widget.type == D3OtpType.digits
                    ? TextCapitalization.none
                    : TextCapitalization.characters,
                inputFormatters: formatters,
                autofillHints: widget.autofillHints,
                autocorrect: false,
                enableSuggestions: false,
                enableInteractiveSelection: false,
                showCursor: false,
                maxLines: 1,
                onChanged: _changed,
                style: const TextStyle(color: Color(0x00000000)),
                cursorColor: const Color(0x00000000),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  fillColor: Color(0x00000000),
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                  counterText: '',
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _shake,
              builder: (context, child) => Transform.translate(
                offset: Offset(
                  math.sin(_shake.value * math.pi * 6) * 8 * (1 - _shake.value),
                  0,
                ),
                child: child,
              ),
              child: row,
            ),
          ],
        );
      },
    );

    final masked = widget.obscureText ? '•' * text.length : text;
    Widget body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: _cellHeight,
          child: ExcludeSemantics(child: field),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: D3Spacing.s8),
            child: Semantics(
              liveRegion: true,
              child: Text(
                widget.errorText!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: D3TypeScale.bodySmSize,
                  color: errorColor,
                ),
              ),
            ),
          ),
      ],
    );

    body = Semantics(
      container: true,
      textField: true,
      label: widget.label,
      value: masked,
      obscured: widget.obscureText,
      enabled: widget.enabled,
      focused: focused,
      maxValueLength: widget.length,
      currentValueLength: text.length,
      hint: widget.errorText,
      onTap: widget.enabled ? _focusField : null,
      child: body,
    );
    if (!widget.enabled) {
      body = Opacity(
        opacity: dim,
        child: IgnorePointer(child: body),
      );
    }
    return body;
  }
}
