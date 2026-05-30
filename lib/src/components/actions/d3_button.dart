import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:d3_ui/d3_ui.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Enums
// ─────────────────────────────────────────────────────────────────────────────

enum D3ButtonVariant { filled, tonal, outlined, ghost, danger }

enum D3ButtonSize { xs, sm, md, lg, xl }

enum D3ButtonState { idle, loading, success, error }

// ─────────────────────────────────────────────────────────────────────────────
// D3Button
// ─────────────────────────────────────────────────────────────────────────────

/// Flat, minimal, mobile-first button.
///
/// - Hybrid foundation: [InkWell] for gesture + ripple + semantics;
///   [DecoratedBox] + [ConstrainedBox] for the custom visual shell.
/// - Height is driven by vertical padding + a [minHeight] floor, NOT a fixed
///   value — so it adapts naturally to the device's text scale setting.
/// - Press feedback: ripple from tap origin + haptic. No scale transform.
/// - Icons are fixed at 16dp and do not scale with text size.
///
/// ```dart
/// D3Button(
///   label: 'Continue',
///   onPressed: _handleContinue,
/// )
///
/// D3Button(
///   label: 'Delete',
///   variant: D3ButtonVariant.danger,
///   leadingIcon: Icons.delete_outline,
///   onPressed: _handleDelete,
/// )
///
/// D3Button.icon(
///   icon: Icons.add,
///   onPressed: _handleAdd,
/// )
/// ```
class D3Button extends StatefulWidget {
  const D3Button({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = D3ButtonVariant.filled,
    this.size = D3ButtonSize.md,
    this.buttonState = D3ButtonState.idle,
    this.loadingLabel,
    this.leadingIcon,
    this.trailingIcon,
    this.isFullWidth = false,
    this.maxLines,
    this.semanticsLabel,
    this.autofocus = false,
  }) : _iconOnly = false,
       _iconOnlyIcon = null;

  /// Icon-only variant. Uses square dimensions from the size token.
  const D3Button.icon({
    super.key,
    required IconData icon,
    this.onPressed,
    this.variant = D3ButtonVariant.filled,
    this.size = D3ButtonSize.md,
    this.buttonState = D3ButtonState.idle,
    this.semanticsLabel,
    this.autofocus = false,
  }) : label = '',
       loadingLabel = null,
       leadingIcon = null,
       trailingIcon = null,
       isFullWidth = false,
       maxLines = 1,
       _iconOnly = true,
       _iconOnlyIcon = icon;

  final String label;
  final VoidCallback? onPressed;
  final D3ButtonVariant variant;
  final D3ButtonSize size;
  final D3ButtonState buttonState;
  final String? loadingLabel;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool isFullWidth;

  /// Overrides token default (1). Use 2 for wide full-width buttons only.
  final int? maxLines;

  final String? semanticsLabel;
  final bool autofocus;

  // Internal
  final bool _iconOnly;
  final IconData? _iconOnlyIcon;

  bool get _isInteractive =>
      onPressed != null &&
      buttonState != D3ButtonState.loading;

  @override
  State<D3Button> createState() => _D3ButtonState();
}

class _D3ButtonState extends State<D3Button> {
  void _onTapDown(TapDownDetails _) {
    if (!widget._isInteractive) return;
    HapticFeedback.lightImpact();
  }

  // onTapUp / onTapCancel not needed — no animation to reverse.

  @override
  Widget build(BuildContext context) {
    final tokens = context.d3ButtonTokens;
    final colors = context.d3Colors;
    final effectiveState = widget.buttonState;

    // ── Sizing ──────────────────────────────────────────────────────────────
    final (hPad, vPad, minH, radius, fontSize) = _sizeValues(tokens);

    // ── Colors ──────────────────────────────────────────────────────────────
    final (bgColor, fgColor, borderColor) = _variantColors(
      colors,
      effectiveState,
    );

    // ── Content ─────────────────────────────────────────────────────────────
    Widget content = widget._iconOnly
        ? _buildIconOnly(fgColor, tokens, effectiveState)
        : _buildLabelRow(
            fgColor,
            tokens,
            fontSize,
            effectiveState,
          );

    // ── Shell: constrained box + padding ────────────────────────────────────
    // ConstrainedBox (minHeight) + symmetric Padding drives the height.
    // This is single-pass layout — no IntrinsicHeight needed.
    Widget shell = ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: minH,
        minWidth: widget._iconOnly ? minH : 64,
      ),
      child: Padding(
        padding: widget._iconOnly
            ? EdgeInsets.zero
            : EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
        child: content,
      ),
    );

    // ── Material + InkWell (background + ripple + gesture + semantics) ────────
    // IMPORTANT: background color lives on Material, not on a DecoratedBox child.
    // InkWell ripple paints on its Material ancestor's canvas — if the background
    // were a child (DecoratedBox), it would paint over the ripple and hide it.
    // By setting color on Material directly, the ripple is always visible on top.
    //
    // For outlined variant: border is applied via Material's `shape` so it
    // also clips correctly without needing a separate DecoratedBox.
    //
    // splashColor per variant:
    //   filled  → white @ 28% (fg is white; low-opacity white on blue reads clearly)
    //   others  → fgColor @ 18% (bg is tinted/transparent; fg color ripple reads well)
    //
    // Disabled/loading: onTap is null → InkWell emits no ripple at all.
    final splashColor = widget.variant == D3ButtonVariant.filled
        ? Colors.white.withValues(alpha: 0.28)
        : fgColor.withValues(alpha: 0.18);
    final highlightColor = widget.variant == D3ButtonVariant.filled
        ? Colors.white.withValues(alpha: 0.14)
        : fgColor.withValues(alpha: 0.10);

    final borderRadius = BorderRadius.circular(radius);
    final shape = borderColor != null
        ? RoundedRectangleBorder(
            borderRadius: borderRadius,
            side: BorderSide(color: borderColor, width: 1.5),
          )
        : RoundedRectangleBorder(borderRadius: borderRadius);

    shell = Material(
      color: bgColor,
      shape: shape,
      child: InkWell(
        onTap: widget._isInteractive ? widget.onPressed : null,
        onTapDown: widget._isInteractive ? _onTapDown : null,
        borderRadius: borderRadius,
        splashColor: splashColor,
        highlightColor: highlightColor,
        autofocus: widget.autofocus,
        child: shell,
      ),
    );

    // ── Disabled opacity ─────────────────────────────────────────────────────
    if (!widget._isInteractive && effectiveState != D3ButtonState.loading) {
      shell = Opacity(opacity: tokens.disabledOpacity, child: shell);
    }

    // ── Full width ───────────────────────────────────────────────────────────
    if (widget.isFullWidth) {
      shell = SizedBox(width: double.infinity, child: shell);
    }

    // ── Semantics ────────────────────────────────────────────────────────────
    return Semantics(
      button: true,
      enabled: widget._isInteractive,
      label: widget.semanticsLabel ??
          (effectiveState == D3ButtonState.loading
              ? '${widget.loadingLabel ?? widget.label}, loading'
              : widget.label),
      child: shell,
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _buildLabelRow(
    Color fgColor,
    D3ButtonTokens tokens,
    double fontSize,
    D3ButtonState state,
  ) {
    final textStyle = d3ButtonTextStyle(fontSize: fontSize, color: fgColor);
    final effectiveMaxLines = widget.maxLines ?? tokens.maxLines;

    Widget? leading;
    if (state == D3ButtonState.loading) {
      leading = _spinner(fgColor, tokens);
    } else if (widget.leadingIcon != null) {
      leading = Icon(widget.leadingIcon, size: tokens.iconSize, color: fgColor);
    }

    Widget? trailing;
    if (widget.trailingIcon != null && state == D3ButtonState.idle) {
      trailing = Icon(widget.trailingIcon, size: tokens.iconSize - 2, color: fgColor);
    }

    // State icon override (success/error)
    IconData? stateIcon = switch (state) {
      D3ButtonState.success => Icons.check_rounded,
      D3ButtonState.error   => Icons.close_rounded,
      _                     => null,
    };
    if (stateIcon != null) {
      leading = Icon(stateIcon, size: tokens.iconSize, color: fgColor);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leading != null) ...[
          leading,
          SizedBox(width: tokens.iconGap),
        ],
        Flexible(
          child: Text(
            state == D3ButtonState.loading
                ? (widget.loadingLabel ?? widget.label)
                : widget.label,
            style: textStyle,
            maxLines: effectiveMaxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (trailing != null) ...[
          SizedBox(width: tokens.iconGap),
          trailing,
        ],
      ],
    );
  }

  Widget _buildIconOnly(
    Color fgColor,
    D3ButtonTokens tokens,
    D3ButtonState state,
  ) {
    if (state == D3ButtonState.loading) return _spinner(fgColor, tokens);
    return Icon(widget._iconOnlyIcon, size: tokens.iconSize + 2, color: fgColor);
  }

  Widget _spinner(Color color, D3ButtonTokens tokens) {
    return SizedBox(
      width: tokens.iconSize,
      height: tokens.iconSize,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation(color),
      ),
    );
  }

  /// Returns (hPad, vPad, minHeight, radius, fontSize) for the current size.
  (double, double, double, double, double) _sizeValues(D3ButtonTokens t) {
    return switch (widget.size) {
      D3ButtonSize.xs => (t.hPaddingXs, t.vPaddingXs, t.minHeightXs, t.radiusXs, D3TypeScale.btnXsSize),
      D3ButtonSize.sm => (t.hPaddingXs + 4, t.vPaddingXs + 2, t.minHeightSm, t.radiusSm, D3TypeScale.btnSmSize),
      D3ButtonSize.md => (t.hPaddingMd, t.vPaddingMd, t.minHeightMd, t.radiusMd, D3TypeScale.btnMdSize),
      D3ButtonSize.lg => (t.hPaddingLg, t.vPaddingLg, t.minHeightLg, t.radiusLg, D3TypeScale.btnLgSize),
      D3ButtonSize.xl => (t.hPaddingLg + 8, t.vPaddingLg + 2, t.minHeightXl, t.radiusLg, D3TypeScale.btnXlSize),
    };
  }

  /// Returns (backgroundColor, foregroundColor, borderColor?) for the
  /// current variant × state combination.
  (Color, Color, Color?) _variantColors(
    D3ColorTokens c,
    D3ButtonState state,
  ) {
    // Success / error states override variant colors
    if (state == D3ButtonState.success) {
      return (c.success.withValues(alpha: 0.15), c.success, null);
    }
    if (state == D3ButtonState.error) {
      return (c.errorContainer, c.onErrorContainer, null);
    }

    return switch (widget.variant) {
      D3ButtonVariant.filled   => (c.primary, c.onPrimary, null),
      D3ButtonVariant.tonal    => (c.primaryContainer, c.onPrimaryContainer, null),
      D3ButtonVariant.outlined => (Colors.transparent, c.onSurface, c.outline),
      D3ButtonVariant.ghost    => (Colors.transparent, c.primary, null),
      D3ButtonVariant.danger   => (c.errorContainer, c.onErrorContainer, null),
    };
  }
}
