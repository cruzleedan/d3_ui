import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:d3_ui/d3_ui.dart';

// ─────────────────────────────────────────────────────────────────────────────
// showD3CalendarPicker
// ─────────────────────────────────────────────────────────────────────────────

/// Opens a themed calendar dialog matching [D3Dialog]'s flat surface style,
/// with an optional set of marked days and a year-picker sub-dialog.
///
/// Scoped deliberately smaller than an enterprise calendar-picker
/// subsystem: no period-range selection, no fluent builder config — just a
/// month grid, a year picker, and optional day markers. See root
/// `context/work/0014-d3-ui-themed-calendar-picker-dialog.md`.
///
/// ```dart
/// final picked = await showD3CalendarPicker(
///   context: context,
///   initialDate: DateTime.now(),
///   markedDates: {DateTime(2026, 9, 10), DateTime(2026, 9, 20)},
/// );
/// ```
Future<DateTime?> showD3CalendarPicker({
  required BuildContext context,
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
  Set<DateTime>? markedDates,
  String? semanticsLabel,
}) {
  final now = DateTime.now();
  final first = firstDate ?? DateTime(now.year - 5);
  final last = lastDate ?? DateTime(now.year + 5);
  final initial = initialDate ?? now;
  final clampedInitial = initial.isBefore(first)
      ? first
      : initial.isAfter(last)
      ? last
      : initial;

  return showDialog<DateTime>(
    context: context,
    barrierColor: Colors.black54,
    builder: (_) => _D3CalendarPickerDialog(
      initialDate: DateTime(
        clampedInitial.year,
        clampedInitial.month,
        clampedInitial.day,
      ),
      firstDate: DateTime(first.year, first.month, first.day),
      lastDate: DateTime(last.year, last.month, last.day),
      markedDates: (markedDates ?? const {})
          .map((d) => DateTime(d.year, d.month, d.day))
          .toSet(),
      semanticsLabel: semanticsLabel,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// _D3CalendarPickerDialog
// ─────────────────────────────────────────────────────────────────────────────

class _D3CalendarPickerDialog extends StatefulWidget {
  const _D3CalendarPickerDialog({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.markedDates,
    this.semanticsLabel,
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final Set<DateTime> markedDates;
  final String? semanticsLabel;

  @override
  State<_D3CalendarPickerDialog> createState() =>
      _D3CalendarPickerDialogState();
}

class _D3CalendarPickerDialogState extends State<_D3CalendarPickerDialog> {
  late DateTime _selected;
  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialDate;
    _visibleMonth = DateTime(_selected.year, _selected.month);
  }

  bool _isMarked(DateTime day) => widget.markedDates.contains(day);

  void _changeMonth(int delta) {
    HapticFeedback.selectionClick();
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    });
  }

  bool get _canGoPrevious =>
      DateTime(_visibleMonth.year, _visibleMonth.month - 1)
          .isAfter(DateTime(widget.firstDate.year, widget.firstDate.month - 1));

  bool get _canGoNext =>
      DateTime(_visibleMonth.year, _visibleMonth.month + 1)
          .isBefore(DateTime(widget.lastDate.year, widget.lastDate.month + 1));

  Future<void> _pickYear() async {
    final year = await showDialog<int>(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => _YearPickerDialog(
        selectedYear: _visibleMonth.year,
        firstYear: widget.firstDate.year,
        lastYear: widget.lastDate.year,
      ),
    );
    if (year != null) {
      setState(() => _visibleMonth = DateTime(year, _visibleMonth.month));
    }
  }

  static const _weekdayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  static const _monthLabels = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;

    return Dialog(
      backgroundColor: colors.surfaceVariant,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(D3Radius.xl),
        side: BorderSide(
          color: colors.outline.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Semantics(
        label: widget.semanticsLabel ?? 'Choose a date',
        container: true,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Padding(
            padding: const EdgeInsets.all(D3Spacing.s16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(colors),
                const SizedBox(height: D3Spacing.s12),
                _buildWeekdayRow(colors),
                const SizedBox(height: D3Spacing.s6),
                _buildMonthGrid(colors),
                const SizedBox(height: D3Spacing.s16),
                _buildActions(colors),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(D3ColorTokens colors) {
    return Row(
      children: [
        Expanded(
          child: Semantics(
            button: true,
            label: 'Choose year',
            child: InkWell(
              onTap: _pickYear,
              borderRadius: D3Radius.circularSm,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: D3Spacing.s8,
                  vertical: D3Spacing.s4,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        '${_monthLabels[_visibleMonth.month - 1]} ${_visibleMonth.year}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: colors.onSurface,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.arrow_drop_down_rounded,
                      size: 20,
                      color: colors.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        _NavIconButton(
          icon: Icons.chevron_left_rounded,
          enabled: _canGoPrevious,
          semanticsLabel: 'Previous month',
          onTap: () => _changeMonth(-1),
        ),
        _NavIconButton(
          icon: Icons.chevron_right_rounded,
          enabled: _canGoNext,
          semanticsLabel: 'Next month',
          onTap: () => _changeMonth(1),
        ),
      ],
    );
  }

  Widget _buildWeekdayRow(D3ColorTokens colors) {
    return Row(
      children: [
        for (final label in _weekdayLabels)
          Expanded(
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMonthGrid(D3ColorTokens colors) {
    final firstOfMonth = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final daysInMonth = DateTime(
      _visibleMonth.year,
      _visibleMonth.month + 1,
      0,
    ).day;
    final leadingBlanks = firstOfMonth.weekday % 7; // Sunday-first grid

    final cells = <Widget>[];
    for (int i = 0; i < leadingBlanks; i++) {
      cells.add(const SizedBox.shrink());
    }
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_visibleMonth.year, _visibleMonth.month, day);
      final isSelected =
          date.year == _selected.year &&
          date.month == _selected.month &&
          date.day == _selected.day;
      final isToday =
          date.year == DateTime.now().year &&
          date.month == DateTime.now().month &&
          date.day == DateTime.now().day;
      final inRange =
          !date.isBefore(widget.firstDate) && !date.isAfter(widget.lastDate);

      cells.add(
        _DayCell(
          day: day,
          isSelected: isSelected,
          isToday: isToday,
          isMarked: _isMarked(date),
          enabled: inRange,
          onTap: inRange
              ? () {
                  HapticFeedback.selectionClick();
                  setState(() => _selected = date);
                }
              : null,
        ),
      );
    }

    const cellSize = 40.0;
    final rowCount = (cells.length / 7).ceil();

    return SizedBox(
      height: cellSize * rowCount,
      child: GridView.count(
        crossAxisCount: 7,
        mainAxisSpacing: 0,
        crossAxisSpacing: 0,
        childAspectRatio: 1,
        physics: const NeverScrollableScrollPhysics(),
        children: cells,
      ),
    );
  }

  Widget _buildActions(D3ColorTokens colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(foregroundColor: colors.onSurfaceVariant),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: D3Spacing.s4),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_selected),
          style: TextButton.styleFrom(foregroundColor: colors.primary),
          child: const Text('OK'),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _NavIconButton
// ─────────────────────────────────────────────────────────────────────────────

class _NavIconButton extends StatelessWidget {
  const _NavIconButton({
    required this.icon,
    required this.enabled,
    required this.semanticsLabel,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final String semanticsLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticsLabel,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: D3Radius.circularFull,
        child: Padding(
          padding: const EdgeInsets.all(D3Spacing.s4),
          child: Icon(
            icon,
            size: 22,
            color: enabled
                ? colors.onSurface
                : colors.onSurfaceVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DayCell
// ─────────────────────────────────────────────────────────────────────────────

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.isMarked,
    required this.enabled,
    required this.onTap,
  });

  final int day;
  final bool isSelected;
  final bool isToday;
  final bool isMarked;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;

    final Color bg;
    final Color fg;
    if (isSelected) {
      bg = colors.primary;
      fg = colors.onPrimary;
    } else if (isToday) {
      bg = colors.primaryContainer;
      fg = colors.onPrimaryContainer;
    } else {
      bg = Colors.transparent;
      fg = enabled
          ? colors.onSurface
          : colors.onSurfaceVariant.withValues(alpha: 0.4);
    }

    return Padding(
      padding: const EdgeInsets.all(2),
      child: Semantics(
        button: true,
        enabled: enabled,
        selected: isSelected,
        label: '$day',
        child: InkWell(
          onTap: onTap,
          borderRadius: D3Radius.circularFull,
          child: Container(
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected || isToday
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: fg,
                  ),
                ),
                if (isMarked && !isSelected)
                  Positioned(
                    bottom: 4,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _YearPickerDialog
// ─────────────────────────────────────────────────────────────────────────────

class _YearPickerDialog extends StatelessWidget {
  const _YearPickerDialog({
    required this.selectedYear,
    required this.firstYear,
    required this.lastYear,
  });

  final int selectedYear;
  final int firstYear;
  final int lastYear;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    final years = [for (int y = firstYear; y <= lastYear; y++) y];

    return Dialog(
      backgroundColor: colors.surfaceVariant,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(D3Radius.xl),
        side: BorderSide(
          color: colors.outline.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
      child: Padding(
        padding: const EdgeInsets.all(D3Spacing.s12),
        child: SizedBox(
          width: 260,
          height: 320,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2,
            ),
            itemCount: years.length,
            itemBuilder: (context, index) {
              final year = years[index];
              final isSelected = year == selectedYear;
              return Padding(
                padding: const EdgeInsets.all(2),
                child: Material(
                  color: isSelected ? colors.primary : Colors.transparent,
                  borderRadius: D3Radius.circularSm,
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(year),
                    borderRadius: D3Radius.circularSm,
                    child: Center(
                      child: Text(
                        '$year',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? colors.onPrimary
                              : colors.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
