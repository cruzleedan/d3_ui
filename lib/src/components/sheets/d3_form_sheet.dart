import 'package:material_ui/material_ui.dart';
import 'package:d3_ui/d3_ui.dart';

// ─────────────────────────────────────────────────────────────────────────────
// D3FormSheet
// ─────────────────────────────────────────────────────────────────────────────

/// A modal bottom sheet sized to its content, for forms with text fields.
///
/// Unlike [D3BottomSheet] (drag-between-explicit-snap-points, built on
/// [DraggableScrollableSheet]), this sizes to its child's intrinsic
/// content height (up to [maxHeightFraction] of the screen) via a plain
/// `showModalBottomSheet`, and handles keyboard avoidance the standard
/// Flutter way — an `AnimatedPadding` keyed to the live keyboard inset,
/// the same mechanism `Scaffold.resizeToAvoidBottomInset` uses internally.
///
/// Use this for a single-purpose form (a handful of fields, one submit
/// action) that doesn't need multiple explicit snap heights to drag
/// between. Use [D3BottomSheet] when the content genuinely benefits from
/// dragging between two or more declared heights (e.g. a filter panel, a
/// history/detail view) — see root `context/work/0008-d3-bottom-sheet-
/// keyboard-inset.md` for why the two components exist side by side
/// rather than one replacing the other: `D3BottomSheet`'s
/// `DraggableScrollableSheet` sizes itself as a fraction of the full
/// screen height, which fights keyboard-relative sizing in a way that
/// proved hard to patch correctly without either breaking multi-snap-
/// point dragging (used by several existing `D3BottomSheet` consumers)
/// or reintroducing the very bug being fixed.
///
/// ```dart
/// await D3FormSheet.show(
///   context,
///   title: 'New Visit',
///   onConfirmDiscard: () async => await confirmDiscard(context),
///   child: NewVisitForm(),
/// );
/// ```
class D3FormSheet {
  const D3FormSheet._();

  /// Closes the enclosing [D3FormSheet] and returns [result] to the
  /// caller of [show]. Use this instead of [Navigator.pop] when calling
  /// from a sheet child, so the [PopScope] discard guard is bypassed
  /// correctly — same contract as [D3BottomSheet.pop].
  static void pop<T>(BuildContext context, [T? result]) {
    _D3FormSheetScope.of(context)?._closeWithResult(result);
  }

  /// Shows a modal bottom sheet sized to [child]'s content and returns
  /// the value passed to [pop]/[Navigator.pop], or null if dismissed.
  ///
  /// [maxHeightFraction] caps the sheet's height as a fraction of the
  /// screen (default 0.9) — content taller than that scrolls within the
  /// sheet rather than growing past it.
  ///
  /// [onConfirmDiscard] is called before any close attempt (Cancel, scrim
  /// tap, back gesture). Return `true` to allow closing, `false` to
  /// cancel. When null, the sheet closes immediately — same contract as
  /// [D3BottomSheet.show].
  static Future<T?> show<T>(
    BuildContext context, {
    String? title,
    String? subtitle,
    Widget? headerAction,
    required Widget child,
    double maxHeightFraction = 0.9,
    Future<bool> Function()? onConfirmDiscard,
    bool useRootNavigator = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: onConfirmDiscard == null,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      useRootNavigator: useRootNavigator,
      builder: (ctx) => _D3FormSheetContent<T>(
        title: title,
        subtitle: subtitle,
        headerAction: headerAction,
        maxHeightFraction: maxHeightFraction,
        onConfirmDiscard: onConfirmDiscard,
        child: child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Inherited scope — lets child widgets call D3FormSheet.pop(context, result)
// ─────────────────────────────────────────────────────────────────────────────

class _D3FormSheetScope extends InheritedWidget {
  const _D3FormSheetScope({required this.state, required super.child});

  final _D3FormSheetContentState state;

  static _D3FormSheetContentState? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_D3FormSheetScope>()?.state;

  @override
  bool updateShouldNotify(_D3FormSheetScope old) => state != old.state;
}

// ─────────────────────────────────────────────────────────────────────────────
// Sheet content widget
// ─────────────────────────────────────────────────────────────────────────────

class _D3FormSheetContent<T> extends StatefulWidget {
  const _D3FormSheetContent({
    this.title,
    this.subtitle,
    this.headerAction,
    required this.maxHeightFraction,
    this.onConfirmDiscard,
    required this.child,
  });

  final String? title;
  final String? subtitle;
  final Widget? headerAction;
  final double maxHeightFraction;
  final Future<bool> Function()? onConfirmDiscard;
  final Widget child;

  @override
  State<_D3FormSheetContent<T>> createState() => _D3FormSheetContentState<T>();
}

class _D3FormSheetContentState<T> extends State<_D3FormSheetContent<T>> {
  // Prevents concurrent close attempts (e.g. double-tap Cancel, rapid back
  // taps) — same pattern as D3BottomSheet.
  bool _isClosing = false;

  // Flipped to true just before we call navigator.pop() so PopScope sees
  // canPop: true and doesn't re-intercept our own programmatic pop.
  bool _allowPop = false;

  Future<void> _tryClose() async {
    if (_isClosing || _allowPop) return;
    _isClosing = true;
    try {
      if (widget.onConfirmDiscard != null) {
        final confirmed = await widget.onConfirmDiscard!();
        if (!confirmed) return;
      }
      if (!mounted) return;
      final navigator = Navigator.of(context);
      setState(() => _allowPop = true);
      WidgetsBinding.instance.addPostFrameCallback((_) => navigator.pop());
    } finally {
      _isClosing = false;
    }
  }

  void _closeWithResult<R>(R? result) {
    if (_isClosing || _allowPop) return;
    if (!mounted) return;
    final navigator = Navigator.of(context);
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) => navigator.pop(result));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return _D3FormSheetScope(
      state: this,
      child: PopScope(
        canPop: _allowPop || widget.onConfirmDiscard == null,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _tryClose();
        },
        // The standard Flutter keyboard-avoidance mechanism —
        // AnimatedPadding keyed to the live keyboard inset, the same
        // thing Scaffold.resizeToAvoidBottomInset does internally. No
        // fraction-of-screen math: the sheet below sizes to its own
        // intrinsic content height (via Flexible+SingleChildScrollView),
        // and this padding just pushes the whole sheet up by exactly the
        // keyboard's height, whatever that height actually is.
        child: AnimatedPadding(
          padding: EdgeInsets.only(bottom: keyboardInset),
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: screenHeight * widget.maxHeightFraction,
            ),
            child: _FormSheetSurface(
              colors: colors,
              title: widget.title,
              subtitle: widget.subtitle,
              headerAction: widget.headerAction,
              onClose: _tryClose,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sheet surface (visual shell) — content-sized, not fraction-of-screen-sized
// ─────────────────────────────────────────────────────────────────────────────

class _FormSheetSurface extends StatelessWidget {
  const _FormSheetSurface({
    required this.colors,
    this.title,
    this.subtitle,
    this.headerAction,
    required this.onClose,
    required this.child,
  });

  final D3ColorTokens colors;
  final String? title;
  final String? subtitle;
  final Widget? headerAction;
  final VoidCallback onClose;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Material(
        // Tonal elevation, not colors.surface — matches D3BottomSheet, see
        // root context/work/0007-d3-ui-tonal-elevation-surface-ladder.md.
        color: colors.surfaceContainerLow,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // No status-bar-height spacer here, unlike D3BottomSheet —
            // that spacer only matters when a sheet grows to cover the
            // status bar/notch (D3BottomSheet's `atTop` case). D3FormSheet
            // never does — it's capped at maxHeightFraction (default 0.9)
            // and sized to its own content, always sitting below the
            // status bar with visible space above it. Adding the spacer
            // unconditionally (an earlier version of this file did, by
            // copying D3BottomSheet's structure without its `atTop`
            // condition) just pushed the drag handle/header down with
            // dead space, making the header block look too tall relative
            // to sheets with less content — see root context/work/0008-
            // d3-bottom-sheet-keyboard-inset.md.
            _FormSheetDragHandle(colors: colors),
            _FormSheetHeader(
              title: title,
              subtitle: subtitle,
              headerAction: headerAction,
              colors: colors,
              onClose: onClose,
            ),
            // Tap-to-dismiss-keyboard on empty space, translucent so it
            // doesn't steal taps from the actual form content — same
            // reasoning as D3BottomSheet's own tap-to-dismiss handling.
            Flexible(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => FocusScope.of(context).unfocus(),
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.viewPaddingOf(context).bottom,
                  ),
                  child: child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Drag handle (visual only — this sheet doesn't support drag-to-resize,
// the handle is purely a familiar "this is a sheet" affordance matching
// D3BottomSheet's look)
// ─────────────────────────────────────────────────────────────────────────────

class _FormSheetDragHandle extends StatelessWidget {
  const _FormSheetDragHandle({required this.colors});
  final D3ColorTokens colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 6),
      child: Center(
        child: Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: colors.outline.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header — visually identical to D3BottomSheet's, duplicated rather than
// shared so the two sheet implementations stay independently maintainable
// (see D3FormSheet's own doc comment for why they're separate components).
// ─────────────────────────────────────────────────────────────────────────────

class _FormSheetHeader extends StatelessWidget {
  const _FormSheetHeader({
    this.title,
    this.subtitle,
    this.headerAction,
    required this.colors,
    required this.onClose,
  });

  final String? title;
  final String? subtitle;
  final Widget? headerAction;
  final D3ColorTokens colors;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colors.outline.withValues(alpha: 0.15),
            width: 0.5,
          ),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 80),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: D3TypeScale.titleLgSize,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface,
                      height: D3TypeFace.tight,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: D3TypeScale.labelMdSize,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          if (headerAction != null)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: headerAction!,
              ),
            ),
          Align(
            alignment: Alignment.centerRight,
            child: Semantics(
              button: true,
              label: 'Cancel',
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onClose,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: D3TypeScale.titleMdSize,
                      fontWeight: FontWeight.w400,
                      color: colors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
