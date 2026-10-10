import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:d3_ui/d3_ui.dart';

import 'helpers/d3_tap_target.dart';

// ─────────────────────────────────────────────────────────────────────────────
// D3SearchBar
// ─────────────────────────────────────────────────────────────────────────────

/// A standalone rounded-rect search input.
///
/// Displays a search icon on the left and a clear button when text is present.
/// Can be used on its own or as the input surface inside [D3SearchAnchor].
///
/// ```dart
/// // Uncontrolled
/// D3SearchBar(
///   hint: 'Search contacts…',
///   onChanged: (q) => setState(() => _query = q),
/// )
///
/// // Controlled — drive the value externally
/// D3SearchBar(
///   controller: _controller,
///   hint: 'Search…',
///   onChanged: (q) => _filter(q),
///   onSubmitted: (q) => _search(q),
/// )
///
/// // Read-only tap target (e.g. opens a full-screen search page)
/// D3SearchBar(
///   hint: 'Search…',
///   readOnly: true,
///   onTap: _openSearch,
/// )
/// ```
class D3SearchBar extends StatefulWidget {
  const D3SearchBar({
    super.key,
    this.controller,
    this.hint = 'Search…',
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.onClear,
    this.readOnly = false,
    this.autofocus = false,
    this.textInputAction = TextInputAction.search,
    this.padding,
    this.focusNode,
    this.trailingWidget,
  });

  /// External controller. A local one is created when null.
  final TextEditingController? controller;

  /// Placeholder text. Defaults to "Search…".
  final String hint;

  /// Called on every keystroke with the current query.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits via the keyboard action button.
  final ValueChanged<String>? onSubmitted;

  /// Called when the bar is tapped. Particularly useful when [readOnly] is
  /// true and the bar is a tap target that opens a full-screen search page.
  final VoidCallback? onTap;

  /// Called after the clear button is pressed and the field is cleared.
  final VoidCallback? onClear;

  /// When true the field is not editable. Taps still fire [onTap].
  final bool readOnly;

  final bool autofocus;
  final TextInputAction textInputAction;

  /// Outer padding around the bar. Defaults to zero — let the parent decide.
  final EdgeInsetsGeometry? padding;

  /// External focus node. A local one is created when null.
  final FocusNode? focusNode;

  /// Optional widget rendered in the trailing slot after the clear button.
  /// Use for status indicators such as an active-filter icon.
  final Widget? trailingWidget;

  @override
  State<D3SearchBar> createState() => _D3SearchBarState();
}

/// Visible height of the field; the touch target is [kMinInteractiveDimension].
const double _visibleHeight = 40;

class _D3SearchBarState extends State<D3SearchBar> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _hasText = false;
  bool _isFocused = false;

  bool get _ownsController => widget.controller == null;
  bool get _ownsFocusNode => widget.focusNode == null;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    if (_ownsController) _controller.dispose();
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);
  }

  void _onFocusChanged() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  void _clear() {
    _controller.clear();
    _focusNode.requestFocus();
    widget.onChanged?.call('');
    widget.onClear?.call();
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    // readOnly bars are pure tap targets — never render focus state.
    final effectivelyFocused = _isFocused && !widget.readOnly;

    // No outline: messaging and social apps (Telegram, X, Facebook) show a
    // plain filled field and let the caret and keyboard say "focused". The
    // fill deepens on focus, and the leading icon turns primary, so the state
    // is still visible without a border.
    final bgColor = colors.onSurface.withValues(
      alpha: effectivelyFocused ? 0.10 : 0.06,
    );

    // The visible pill is a 40dp background; the contents sit in a 48dp strip
    // on top of it so every control inside keeps a 48dp touch target.
    final pill = Positioned(
      left: 0,
      right: 0,
      top: (kMinInteractiveDimension - _visibleHeight) / 2,
      bottom: (kMinInteractiveDimension - _visibleHeight) / 2,
      child: AnimatedContainer(
        duration: D3Motion.fast,
        curve: D3Motion.standard,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(D3Radius.full),
        ),
      ),
    );

    final content = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: kMinInteractiveDimension),
      child: Row(
        children: [
          const SizedBox(width: 12),
          AnimatedSwitcher(
            duration: D3Motion.fast,
            child: Icon(
              Icons.search_rounded,
              key: ValueKey(effectivelyFocused),
              size: 18,
              color: effectivelyFocused
                  ? colors.primary
                  : colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              readOnly: widget.readOnly,
              autofocus: widget.autofocus,
              textInputAction: widget.textInputAction,
              style: TextStyle(
                fontSize: 14,
                color: colors.onSurface,
                height: 1.2,
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: colors.onSurfaceVariant.withValues(alpha: 0.6),
                  height: 1.2,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              cursorColor: colors.primary,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              onTap: widget.onTap,
            ),
          ),

          // Clear button — animated in/out
          AnimatedSwitcher(
            duration: D3Motion.fast,
            child: _hasText
                ? GestureDetector(
                    key: const ValueKey('clear'),
                    behavior: HitTestBehavior.opaque,
                    onTap: _clear,
                    child: D3TapTarget(
                      child: Container(
                        width: 17,
                        height: 17,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.onSurfaceVariant.withValues(
                            alpha: 0.35,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.close_rounded,
                          size: 11,
                          color: colors.surface,
                        ),
                      ),
                    ),
                  )
                : const SizedBox(key: ValueKey('empty'), width: 12),
          ),

          if (widget.trailingWidget != null) widget.trailingWidget!,
        ],
      ),
    );

    // Taps in the strip outside the field (and outside any button) focus it,
    // or call onTap for a read-only bar. Taps on the TextField itself are
    // handled by the TextField, which wins the gesture arena.
    final bar = GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (!widget.readOnly) _focusNode.requestFocus();
        widget.onTap?.call();
      },
      child: Stack(children: [pill, content]),
    );

    if (widget.padding != null) {
      return Padding(padding: widget.padding!, child: bar);
    }
    return bar;
  }
}
