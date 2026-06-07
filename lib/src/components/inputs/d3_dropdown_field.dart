import 'package:d3_ui/d3_ui.dart';
import 'package:flutter/material.dart';

enum D3DropdownMode {
  /// Opens a [PopupMenuButton] anchored below the field.
  /// Best for static lists of 5 or fewer short items.
  popup,

  /// Opens a bottom sheet with an optional search field.
  /// Best for longer lists or API-driven data.
  sheet,
}

/// Dropdown selector styled to match [D3TextField].
///
/// [T] is the item type, [V] is the value type used for selection matching.
///
/// Use [mode] to control the selection UI:
/// - [D3DropdownMode.popup] — anchored popup menu (small static lists)
/// - [D3DropdownMode.sheet] — bottom sheet, set [searchable] for a search field
class D3DropdownField<T, V> extends StatefulWidget {
  const D3DropdownField({
    super.key,
    required this.label,
    required this.items,
    required this.itemLabel,
    required this.itemValue,
    this.initialValue,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.isRequired = false,
    this.isEnabled = true,
    this.mode = D3DropdownMode.popup,
    this.searchable = false,
    this.searchHint = 'Search…',
    this.onChanged,
    this.semanticsLabel,
  });

  final String label;
  final List<T> items;

  /// Returns the display string for an item.
  final String Function(T item) itemLabel;

  /// Returns the value used for matching [initialValue].
  final V? Function(T item) itemValue;

  /// Pre-selects the item whose [itemValue] equals this.
  final V? initialValue;

  final String? hintText;
  final String? helperText;
  final String? errorText;
  final IconData? prefixIcon;
  final bool isRequired;
  final bool isEnabled;

  /// Controls whether tapping opens a popup menu or a bottom sheet.
  final D3DropdownMode mode;

  /// When [mode] is [D3DropdownMode.sheet], shows a search field at the top.
  final bool searchable;

  /// Placeholder text for the search field.
  final String searchHint;

  final ValueChanged<T?>? onChanged;
  final String? semanticsLabel;

  @override
  State<D3DropdownField<T, V>> createState() => _D3DropdownFieldState<T, V>();
}

class _D3DropdownFieldState<T, V> extends State<D3DropdownField<T, V>> {
  T? _selected;
  bool _isFocused = false;
  final _focusNode = FocusNode(skipTraversal: true);

  @override
  void initState() {
    super.initState();
    _syncSelection();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant D3DropdownField<T, V> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue ||
        widget.items != oldWidget.items) {
      _syncSelection();
    }
  }

  void _syncSelection() {
    _selected = null;
    for (final item in widget.items) {
      if (widget.itemValue(item) == widget.initialValue) {
        _selected = item;
        break;
      }
    }
  }

  Future<void> _openSheet() async {
    _focusNode.requestFocus();
    setState(() => _isFocused = true);

    final result = await D3BottomSheet.show<T>(
      context,
      title: widget.label,
      snapPoints: const [D3SnapPoint(0.75)],
      child: _DropdownSheetBody<T>(  // ignore: prefer_const_constructors
        items: widget.items,
        itemLabel: widget.itemLabel,
        selected: _selected,
        searchable: widget.searchable,
        searchHint: widget.searchHint,
      ),
    );

    if (!mounted) return;
    setState(() => _isFocused = false);

    if (result != null) {
      setState(() => _selected = result);
      widget.onChanged?.call(result);
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

    final displayText =
        _selected != null ? widget.itemLabel(_selected as T) : null;

    final fieldContent = ConstrainedBox(
      constraints: BoxConstraints(minHeight: tokens.minHeight),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.paddingH,
          vertical: tokens.paddingV,
        ),
        child: Row(
          children: [
            if (widget.prefixIcon != null) ...[
              Icon(
                widget.prefixIcon,
                size: tokens.iconSize,
                color: colors.onSurfaceVariant,
              ),
              const SizedBox(width: D3Spacing.s8),
            ],
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
              Icons.unfold_more_rounded,
              size: tokens.iconSize,
              color: colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );

    final inputContainer = AnimatedContainer(
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
      child: Focus(
        focusNode: _focusNode,
        child: widget.mode == D3DropdownMode.popup
            ? PopupMenuButton<T>(
                enabled: widget.isEnabled,
                borderRadius: BorderRadius.circular(tokens.radius),
                position: PopupMenuPosition.under,
                onOpened: () {
                  _focusNode.requestFocus();
                  setState(() => _isFocused = true);
                },
                onCanceled: () => setState(() => _isFocused = false),
                onSelected: (item) {
                  setState(() {
                    _selected = item;
                    _isFocused = false;
                  });
                  widget.onChanged?.call(item);
                },
                itemBuilder: (_) => widget.items.map((item) {
                  return PopupMenuItem<T>(
                    value: item,
                    child: Text(
                      widget.itemLabel(item),
                      style: TextStyle(
                        fontSize: tokens.textSize,
                        color: colors.onSurface,
                      ),
                    ),
                  );
                }).toList(),
                child: fieldContent,
              )
            : GestureDetector(
                onTap: widget.isEnabled ? _openSheet : null,
                child: fieldContent,
              ),
      ),
    );

    Widget field = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
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
        inputContainer,
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
      enabled: widget.isEnabled,
      child: field,
    );
  }
}

class _DropdownSheetBody<T> extends StatefulWidget {
  const _DropdownSheetBody({
    required this.items,
    required this.itemLabel,
    required this.selected,
    required this.searchable,
    required this.searchHint,
  });

  final List<T> items;
  final String Function(T item) itemLabel;
  final T? selected;
  final bool searchable;
  final String searchHint;

  @override
  State<_DropdownSheetBody<T>> createState() => _DropdownSheetBodyState<T>();
}

class _DropdownSheetBodyState<T> extends State<_DropdownSheetBody<T>> {
  late List<T> _filtered;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filtered = widget.items;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? widget.items
          : widget.items
              .where((item) =>
                  widget.itemLabel(item).toLowerCase().contains(q))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    final tokens = context.d3InputTokens;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.searchable)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: _onSearch,
              style: TextStyle(fontSize: tokens.textSize, color: colors.onSurface),
              decoration: InputDecoration(
                hintText: widget.searchHint,
                hintStyle: TextStyle(color: colors.onSurfaceVariant),
                prefixIcon: Icon(Icons.search, color: colors.onSurfaceVariant),
                filled: true,
                fillColor: colors.surfaceVariant,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(tokens.radius),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        if (_filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              'No results',
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filtered.length,
            itemBuilder: (context, index) {
              final item = _filtered[index];
              final isSelected = item == widget.selected;
              return ListTile(
                title: Text(
                  widget.itemLabel(item),
                  style: TextStyle(
                    fontSize: tokens.textSize,
                    color: colors.onSurface,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check_rounded, color: colors.primary)
                    : null,
                onTap: () => Navigator.of(context).pop(item),
              );
            },
          ),
      ],
    );
  }
}
