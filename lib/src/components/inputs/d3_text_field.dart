import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:d3_ui/d3_ui.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Enums
// ─────────────────────────────────────────────────────────────────────────────

enum D3InputVariant {
  /// Rounded border. Works on any background. Default.
  outlined,

  /// Soft tinted fill, bottom border only. Good for search/inline fields.
  filled,
}

enum D3ValidationMode {
  /// Validate only when the form is submitted.
  onSubmit,

  /// Validate when the field loses focus.
  onBlur,

  /// Validate on every keystroke.
  onChange,

  /// Validate on blur first; then live-validate once an error is visible.
  /// Recommended default — doesn't punish while typing.
  onBlurThenChange,
}

// ─────────────────────────────────────────────────────────────────────────────
// D3TextField
// ─────────────────────────────────────────────────────────────────────────────

/// Flat, minimal text input with full state management and an optional
/// tap-triggered popover tooltip.
///
/// ```dart
/// D3TextField(
///   label: 'Email',
///   keyboardType: TextInputType.emailAddress,
///   validator: (v) => v!.contains('@') ? null : 'Enter a valid email',
/// )
///
/// D3TextField(
///   label: 'Referral code',
///   tooltip: 'Ask a friend for their 8-character code.',
///   helperText: 'Optional',
/// )
/// ```
class D3TextField extends StatefulWidget {
  const D3TextField({
    super.key,
    required this.label,
    this.controller,
    this.focusNode,
    this.initialValue,
    this.hintText,
    this.helperText,
    this.tooltip,
    this.errorText,
    this.successText,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.suffixText,
    this.prefixWidget,
    this.suffixWidget,
    this.isRequired = false,
    this.isReadOnly = false,
    this.isEnabled = true,
    this.obscureText = false,
    this.showClearButton = true,
    this.maxLength,
    this.maxLengthEnforced = false,
    this.maxLines = 1,
    this.minLines,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.autocorrect = true,
    this.variant = D3InputVariant.outlined,
    this.validationMode = D3ValidationMode.onBlurThenChange,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.inputFormatters,
    this.semanticsLabel,
  });

  final String label;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? initialValue;
  final String? hintText;
  final String? helperText;

  /// Text shown in a tap-triggered popover anchored below the ⓘ icon
  /// in the label row.
  final String? tooltip;

  /// When set, overrides validation error and shows success state.
  final String? successText;

  /// When set, forces error state and overrides validator result.
  final String? errorText;

  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final String? prefixText;
  final String? suffixText;

  /// Arbitrary widget in the prefix slot (e.g. a flag for phone inputs).
  final Widget? prefixWidget;

  /// Arbitrary widget in the suffix slot.
  final Widget? suffixWidget;

  final bool isRequired;
  final bool isReadOnly;
  final bool isEnabled;
  final bool obscureText;

  /// Shows a clear (✕) button in the suffix when the field has text and is
  /// focused. Automatically hidden on disabled and read-only fields.
  /// Defaults to true.
  final bool showClearButton;

  final int? maxLength;

  /// When false (default), counter shows but input is not blocked at limit.
  final bool maxLengthEnforced;

  final int? maxLines;
  final int? minLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final bool autocorrect;
  final D3InputVariant variant;
  final D3ValidationMode validationMode;

  /// Return null for valid, a String for the error message.
  final String? Function(String?)? validator;

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final String? semanticsLabel;

  @override
  State<D3TextField> createState() => _D3TextFieldState();
}

class _D3TextFieldState extends State<D3TextField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _ownsController = false;
  bool _ownsFocusNode = false;

  bool _isFocused = false;
  String? _validationError;

  /// True once the field has been blurred at least once — gates live validation
  /// for [D3ValidationMode.onBlurThenChange].
  bool _hasBeenBlurred = false;

  bool _obscured = false;

  // Tooltip overlay
  OverlayEntry? _tooltipOverlay;
  final GlobalKey _tooltipIconKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    if (widget.controller == null) {
      _controller = TextEditingController(text: widget.initialValue);
      _ownsController = true;
    } else {
      _controller = widget.controller!;
    }

    if (widget.focusNode == null) {
      _focusNode = FocusNode();
      _ownsFocusNode = true;
    } else {
      _focusNode = widget.focusNode!;
    }

    _obscured = widget.obscureText;

    _focusNode.addListener(_onFocusChange);
    _controller.addListener(_onTextChange);
  }

  @override
  void dispose() {
    _removeTooltip();
    _focusNode.removeListener(_onFocusChange);
    _controller.removeListener(_onTextChange);
    if (_ownsController) _controller.dispose();
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  // ── Focus ──────────────────────────────────────────────────────────────────

  void _onFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);

    if (!_focusNode.hasFocus) {
      _hasBeenBlurred = true;
      _removeTooltip();
      _runValidation(_controller.text);
    }
  }

  // ── Text change ────────────────────────────────────────────────────────────

  void _onTextChange() {
    widget.onChanged?.call(_controller.text);

    final shouldValidateLive = switch (widget.validationMode) {
      D3ValidationMode.onChange => true,
      D3ValidationMode.onBlurThenChange =>
        _hasBeenBlurred && _validationError != null,
      _ => false,
    };

    if (shouldValidateLive) {
      setState(
        () => _validationError = widget.validator?.call(_controller.text),
      );
    } else {
      // Still update counter without re-running validator.
      setState(() {});
    }
  }

  // ── Validation ─────────────────────────────────────────────────────────────

  void _runValidation(String value) {
    if (widget.validator == null) return;
    setState(() => _validationError = widget.validator!(value));
  }

  /// Called by a parent [Form] widget.
  String? validate() {
    _runValidation(_controller.text);
    return _validationError;
  }

  // ── Tooltip overlay ────────────────────────────────────────────────────────

  void _toggleTooltip() {
    if (_tooltipOverlay != null) {
      _removeTooltip();
      return;
    }
    _showTooltip();
  }

  void _showTooltip() {
    final renderBox =
        _tooltipIconKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final overlay = Overlay.of(context);
    final iconPos = renderBox.localToGlobal(Offset.zero);
    final iconSize = renderBox.size;
    final screenWidth = MediaQuery.of(context).size.width;
    final tokens = context.d3InputTokens;
    final colors = context.d3Colors;

    _tooltipOverlay = OverlayEntry(
      builder: (ctx) => _TooltipOverlay(
        text: widget.tooltip!,
        anchorRect: Rect.fromLTWH(
          iconPos.dx,
          iconPos.dy,
          iconSize.width,
          iconSize.height,
        ),
        screenWidth: screenWidth,
        tokens: tokens,
        colors: colors,
        onDismiss: _removeTooltip,
      ),
    );

    overlay.insert(_tooltipOverlay!);
  }

  void _removeTooltip() {
    _tooltipOverlay?.remove();
    _tooltipOverlay = null;
  }

  // ── State resolution ───────────────────────────────────────────────────────

  _FieldStatus get _status {
    if (!widget.isEnabled) return _FieldStatus.disabled;
    if (widget.errorText != null || _validationError != null) {
      return _FieldStatus.error;
    }
    if (widget.successText != null) return _FieldStatus.success;
    if (_isFocused) return _FieldStatus.focused;
    if (_controller.text.isNotEmpty) return _FieldStatus.filled;
    return _FieldStatus.idle;
  }

  String? get _effectiveError => widget.errorText ?? _validationError;
  String? get _effectiveHelper => _effectiveError ?? widget.helperText;

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final tokens = context.d3InputTokens;
    final colors = context.d3Colors;
    final status = _status;
    final isMultiline = (widget.maxLines == null || (widget.maxLines ?? 1) > 1);

    final borderColor = _borderColor(status, colors);
    final bgColor = _bgColor(status, colors);

    Widget field = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Label row ─────────────────────────────────────────────────────
        _LabelRow(
          label: widget.label,
          isRequired: widget.isRequired,
          tooltip: widget.tooltip,
          tooltipKey: _tooltipIconKey,
          onTooltipTap: _toggleTooltip,
          tokens: tokens,
          colors: colors,
          isEnabled: widget.isEnabled,
        ),

        SizedBox(height: D3Spacing.s6),

        // ── Input container ───────────────────────────────────────────────
        AnimatedContainer(
          duration: tokens.borderAnimDuration,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(tokens.radius),
            border: Border.all(
              color: borderColor,
              width: tokens.borderWidth,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
          child: Row(
            crossAxisAlignment: isMultiline
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              // Prefix
              if (widget.prefixWidget != null)
                Padding(
                  padding: EdgeInsets.only(left: tokens.paddingH),
                  child: widget.prefixWidget!,
                )
              else if (widget.prefixIcon != null)
                Padding(
                  padding: EdgeInsets.only(left: tokens.paddingH),
                  child: Icon(
                    widget.prefixIcon,
                    size: tokens.iconSize,
                    color: colors.onSurfaceVariant,
                  ),
                )
              else if (widget.prefixText != null)
                Padding(
                  padding: EdgeInsets.only(left: tokens.paddingH),
                  child: Text(
                    widget.prefixText!,
                    style: TextStyle(
                      fontSize: tokens.textSize,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),

              // Input
              Expanded(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: tokens.minHeight),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: _hasPrefix ? D3Spacing.s8 : tokens.paddingH,
                      vertical: tokens.paddingV,
                    ),
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      enabled: widget.isEnabled,
                      readOnly: widget.isReadOnly,
                      obscureText: _obscured,
                      maxLines: widget.obscureText ? 1 : widget.maxLines,
                      minLines: widget.minLines,
                      maxLength: widget.maxLengthEnforced
                          ? widget.maxLength
                          : null,
                      keyboardType: widget.keyboardType,
                      textInputAction: widget.textInputAction,
                      autofillHints: widget.autofillHints,
                      autocorrect: widget.autocorrect,
                      inputFormatters: widget.inputFormatters,
                      onTap: widget.onTap,
                      onSubmitted: (v) {
                        if (widget.validationMode ==
                                D3ValidationMode.onSubmit ||
                            widget.validationMode == D3ValidationMode.onBlur) {
                          _runValidation(v);
                        }
                        widget.onSubmitted?.call(v);
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
                        counterText: '', // hide built-in counter
                      ),
                    ),
                  ),
                ),
              ),

              // Suffix
              _buildSuffix(tokens, colors, status),
            ],
          ),
        ),

        // ── Helper / counter row ──────────────────────────────────────────
        if (_effectiveHelper != null || widget.maxLength != null)
          _BottomRow(
            helperText: _effectiveHelper,
            isError: _effectiveError != null,
            isSuccess: widget.successText != null && _effectiveError == null,
            maxLength: widget.maxLength,
            currentLength: _controller.text.length,
            tokens: tokens,
            colors: colors,
            warnThreshold: tokens.counterWarnThreshold,
          ),
      ],
    );

    // Disabled: wrap in Semantics + Opacity
    if (!widget.isEnabled) {
      field = Opacity(opacity: tokens.disabledOpacity, child: field);
    }

    return Semantics(
      label: widget.semanticsLabel ?? widget.label,
      textField: true,
      enabled: widget.isEnabled,
      readOnly: widget.isReadOnly,
      child: field,
    );
  }

  bool get _hasPrefix =>
      widget.prefixWidget != null ||
      widget.prefixIcon != null ||
      widget.prefixText != null;

  // ── Suffix builder ─────────────────────────────────────────────────────────

  Widget _buildSuffix(
    D3InputTokens tokens,
    D3ColorTokens colors,
    _FieldStatus status,
  ) {
    final parts = <Widget>[];

    // ── Clear button ────────────────────────────────────────────────────────
    // Shown when: showClearButton is true, field has text, is focused,
    // and is not disabled or read-only. Visible on password fields too.
    final showClear =
        widget.showClearButton &&
        _isFocused &&
        _controller.text.isNotEmpty &&
        widget.isEnabled &&
        !widget.isReadOnly;

    if (showClear) {
      parts.add(
        Semantics(
          button: true,
          label: 'Clear',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              _controller.clear();
              setState(() => _validationError = null);
              _focusNode.requestFocus();
            },
            child: Padding(
              padding: const EdgeInsets.all(13),
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.onSurfaceVariant.withValues(alpha: 0.15),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.close_rounded,
                  size: 12,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      );
    }

    // ── State icon (validation feedback) ───────────────────────────────────
    if (status == _FieldStatus.error) {
      parts.add(
        Icon(
          Icons.warning_amber_rounded,
          size: tokens.iconSize,
          color: colors.error,
        ),
      );
    } else if (status == _FieldStatus.success) {
      parts.add(
        Icon(
          Icons.check_circle_outline_rounded,
          size: tokens.iconSize,
          color: colors.success,
        ),
      );
    }

    // ── Password visibility toggle ─────────────────────────────────────────
    if (widget.obscureText) {
      parts.add(
        GestureDetector(
          onTap: () => setState(() => _obscured = !_obscured),
          child: Icon(
            _obscured
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            size: tokens.iconSize,
            color: colors.onSurfaceVariant,
          ),
        ),
      );
    }

    // ── Custom suffix ──────────────────────────────────────────────────────
    if (widget.suffixWidget != null) {
      parts.add(widget.suffixWidget!);
    } else if (widget.suffixIcon != null) {
      parts.add(
        Icon(
          widget.suffixIcon,
          size: tokens.iconSize,
          color: colors.onSurfaceVariant,
        ),
      );
    } else if (widget.suffixText != null) {
      parts.add(
        Text(
          widget.suffixText!,
          style: TextStyle(
            fontSize: tokens.textSize,
            fontWeight: FontWeight.w600,
            color: colors.onSurfaceVariant,
          ),
        ),
      );
    }

    if (parts.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(right: tokens.paddingH),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children:
            parts.expand((w) => [w, SizedBox(width: D3Spacing.s8)]).toList()
              ..removeLast(),
      ),
    );
  }

  // ── Color helpers ──────────────────────────────────────────────────────────

  Color _borderColor(_FieldStatus status, D3ColorTokens c) => switch (status) {
    _FieldStatus.focused => c.primary,
    _FieldStatus.error => c.error,
    _FieldStatus.success => c.success,
    _FieldStatus.disabled => c.outline,
    _ => c.outline,
  };

  Color _bgColor(_FieldStatus status, D3ColorTokens c) => switch (status) {
    _FieldStatus.disabled => c.surfaceVariant,
    _FieldStatus.focused => c.surface,
    _FieldStatus.filled => c.surface,
    _FieldStatus.error => c.surface,
    _FieldStatus.success => c.surface,
    _ => c.surfaceVariant,
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal status enum
// ─────────────────────────────────────────────────────────────────────────────

enum _FieldStatus { idle, focused, filled, error, success, disabled }

// ─────────────────────────────────────────────────────────────────────────────
// Label row
// ─────────────────────────────────────────────────────────────────────────────

class _LabelRow extends StatelessWidget {
  const _LabelRow({
    required this.label,
    required this.isRequired,
    required this.tooltip,
    required this.tooltipKey,
    required this.onTooltipTap,
    required this.tokens,
    required this.colors,
    required this.isEnabled,
  });

  final String label;
  final bool isRequired;
  final String? tooltip;
  final GlobalKey tooltipKey; // anchors the popover — must stay on the ⓘ icon
  final VoidCallback onTooltipTap;
  final D3InputTokens tokens;
  final D3ColorTokens colors;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (tooltip != null) ...[
          _TooltipIcon(
            key: tooltipKey, // popover anchors to this render box
            colors: colors,
          ),
          const SizedBox(width: 6),
        ],
        Text(
          label,
          style: TextStyle(
            fontSize: tokens.labelSize,
            fontWeight: FontWeight.w600,
            color: colors.onSurfaceVariant,
            letterSpacing: -0.1,
          ),
        ),
        if (isRequired) ...[
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
    );

    if (tooltip != null) {
      content = Semantics(
        button: true,
        label: '${label}, more info',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTooltipTap,
          child: content,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: tokens.paddingH),
      child: content,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tooltip icon (ⓘ)
// ─────────────────────────────────────────────────────────────────────────────

class _TooltipIcon extends StatelessWidget {
  const _TooltipIcon({super.key, required this.colors});

  final D3ColorTokens colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.primary.withValues(alpha: 0.12),
      ),
      alignment: Alignment.center,
      child: Text(
        'i',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: colors.primary,
          height: 1,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tooltip overlay widget
// ─────────────────────────────────────────────────────────────────────────────

class _TooltipOverlay extends StatefulWidget {
  const _TooltipOverlay({
    required this.text,
    required this.anchorRect,
    required this.screenWidth,
    required this.tokens,
    required this.colors,
    required this.onDismiss,
  });

  final String text;
  final Rect anchorRect;
  final double screenWidth;
  final D3InputTokens tokens;
  final D3ColorTokens colors;
  final VoidCallback onDismiss;

  @override
  State<_TooltipOverlay> createState() => _TooltipOverlayState();
}

class _TooltipOverlayState extends State<_TooltipOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: D3Motion.fast);
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, -0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const gap = 8.0;
    const screenPad = 16.0;
    final maxW = widget.tokens.tooltipMaxWidth;

    // Default: left-align with the anchor icon
    double left = widget.anchorRect.left;
    // Flip to right-align if it would overflow the screen
    if (left + maxW > widget.screenWidth - screenPad) {
      left = widget.screenWidth - screenPad - maxW;
    }
    // Clamp to left edge
    if (left < screenPad) left = screenPad;

    final top = widget.anchorRect.bottom + gap;

    return Stack(
      children: [
        // Full-screen dismiss barrier
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: widget.onDismiss,
          ),
        ),

        // Popover
        Positioned(
          left: left,
          top: top,
          width: maxW,
          child: FadeTransition(
            opacity: _opacity,
            child: SlideTransition(
              position: _slide,
              child: Semantics(
                liveRegion: true,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.colors.surfaceVariant,
                      borderRadius: BorderRadius.circular(
                        widget.tokens.tooltipRadius,
                      ),
                      border: Border.all(
                        color: widget.colors.primary.withValues(alpha: 0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: widget.tokens.tooltipPaddingH,
                      vertical: widget.tokens.tooltipPaddingV,
                    ),
                    child: Text(
                      widget.text,
                      style: TextStyle(
                        fontSize: widget.tokens.helperSize,
                        color: widget.colors.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom row (helper + counter)
// ─────────────────────────────────────────────────────────────────────────────

class _BottomRow extends StatelessWidget {
  const _BottomRow({
    required this.helperText,
    required this.isError,
    required this.isSuccess,
    required this.maxLength,
    required this.currentLength,
    required this.tokens,
    required this.colors,
    required this.warnThreshold,
  });

  final String? helperText;
  final bool isError;
  final bool isSuccess;
  final int? maxLength;
  final int currentLength;
  final D3InputTokens tokens;
  final D3ColorTokens colors;
  final double warnThreshold;

  @override
  Widget build(BuildContext context) {
    final helperColor = isError
        ? colors.error
        : isSuccess
        ? colors.success
        : colors.onSurfaceVariant;

    Color counterColor = colors.onSurfaceVariant;
    if (maxLength != null) {
      final ratio = currentLength / maxLength!;
      if (ratio >= 1.0) {
        counterColor = colors.error;
      } else if (ratio >= warnThreshold) {
        counterColor = colors.warning;
      }
    }

    return Padding(
      padding: EdgeInsets.only(top: D3Spacing.s4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (helperText != null)
            Expanded(
              child: Semantics(
                liveRegion: isError, // announce errors immediately
                child: Padding(
                  padding: EdgeInsets.only(left: tokens.paddingH),
                  child: Text(
                    helperText!,
                    style: TextStyle(
                      fontSize: tokens.helperSize,
                      color: helperColor,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            )
          else
            const Spacer(),
          if (maxLength != null)
            Padding(
              padding: EdgeInsets.only(right: tokens.paddingH),
              child: Text(
                '$currentLength / $maxLength',
                style: TextStyle(
                  fontSize: tokens.helperSize,
                  color: counterColor,
                  fontVariations: const [FontVariation('wght', 500)],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
