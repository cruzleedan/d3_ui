
import 'package:flutter/services.dart';
import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// Formats [t] for display: "9:30 AM" in 12-hour mode, "09:30" when
/// [use24h] is true.
///
/// ```dart
/// d3FormatTime(const TimeOfDay(hour: 9, minute: 30)); // "9:30 AM"
/// d3FormatTime(const TimeOfDay(hour: 21, minute: 5), use24h: true); // "21:05"
/// ```
String d3FormatTime(TimeOfDay t, {bool use24h = false}) {
  final mm = t.minute.toString().padLeft(2, '0');
  if (use24h) return '${t.hour.toString().padLeft(2, '0')}:$mm';
  final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
  return '$h:$mm ${t.hour < 12 ? 'AM' : 'PM'}';
}

/// Opens a themed bottom sheet with scroll wheels for hour, minute and (in
/// 12-hour mode) AM/PM, and returns the chosen time. Returns null when the
/// sheet is dismissed (Cancel, tap outside, drag down, back).
///
/// [use24h] defaults to `MediaQuery.alwaysUse24HourFormatOf(context)`.
/// [minuteInterval] limits the minute wheel to multiples of it (for example
/// 15 offers 0, 15, 30, 45); [initialTime] is snapped to the nearest one.
///
/// ```dart
/// final time = await showD3TimePicker(
///   context,
///   initialTime: const TimeOfDay(hour: 9, minute: 30),
///   minuteInterval: 5,
/// );
/// if (time != null) print(d3FormatTime(time));
/// ```
///
/// Each wheel is an adjustable control for screen readers (swipe up/down to
/// change it) and responds to the arrow keys. Ticks give selection haptics;
/// animations are skipped when the platform asks to disable them.
Future<TimeOfDay?> showD3TimePicker(
  BuildContext context, {
  TimeOfDay? initialTime,
  bool? use24h,
  int minuteInterval = 1,
  String title = 'Select time',
  String confirmLabel = 'Done',
  bool useRootNavigator = true,
}) {
  assert(
    minuteInterval >= 1 && minuteInterval <= 30 && 60 % minuteInterval == 0,
    'minuteInterval must divide 60.',
  );
  final is24 = use24h ?? MediaQuery.alwaysUse24HourFormatOf(context);
  return showModalBottomSheet<TimeOfDay>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    useRootNavigator: useRootNavigator,
    builder: (ctx) => _TimePickerContent(
      initial: initialTime ?? TimeOfDay.now(),
      use24h: is24,
      minuteInterval: minuteInterval,
      title: title,
      confirmLabel: confirmLabel,
    ),
  );
}

class _TimePickerContent extends StatefulWidget {
  const _TimePickerContent({
    required this.initial,
    required this.use24h,
    required this.minuteInterval,
    required this.title,
    required this.confirmLabel,
  });

  final TimeOfDay initial;
  final bool use24h;
  final int minuteInterval;
  final String title;
  final String confirmLabel;

  @override
  State<_TimePickerContent> createState() => _TimePickerContentState();
}

class _TimePickerContentState extends State<_TimePickerContent> {
  late int _hour24;
  late int _minuteIndex;
  late int _minuteCount;

  @override
  void initState() {
    super.initState();
    _hour24 = widget.initial.hour;
    _minuteCount = 60 ~/ widget.minuteInterval;
    _minuteIndex = (widget.initial.minute / widget.minuteInterval)
        .round()
        .clamp(0, _minuteCount - 1);
  }

  TimeOfDay get _time =>
      TimeOfDay(hour: _hour24, minute: _minuteIndex * widget.minuteInterval);

  bool get _isPm => _hour24 >= 12;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    final media = MediaQuery.of(context);
    final text = Theme.of(context).textTheme;
    final radius = Radius.circular(context.d3Shape.xl);
    final scaler = media.textScaler;
    final rowExtent = (scaler.scale(22) * 1.3 + D3Spacing.s8).clamp(
      D3Spacing.s48,
      120.0,
    );
    final visibleRows = media.size.height < 640 || scaler.scale(1) > 1.3
        ? 3
        : 5;
    final surface = colors.surfaceContainerLow;
    final previewColor = d3EnsureContrast(colors.primary, surface);

    final hourLabels = widget.use24h
        ? List.generate(24, (i) => i.toString().padLeft(2, '0'))
        : List.generate(12, (i) => '${i == 0 ? 12 : i}');
    final minuteLabels = List.generate(
      _minuteCount,
      (i) => (i * widget.minuteInterval).toString().padLeft(2, '0'),
    );

    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      label: widget.title,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: media.size.height * 0.92),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: radius),
          child: Material(
            color: surface,
            child: Padding(
              padding: EdgeInsets.only(bottom: media.viewPadding.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 6),
                    child: Center(
                      child: ExcludeSemantics(
                        child: Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: colors.outline.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: D3Spacing.s16,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: D3Spacing.s8),
                            child: Text(
                              widget.title,
                              textAlign: TextAlign.center,
                              style: text.titleMedium?.copyWith(
                                color: colors.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: D3Spacing.s12,
                            ),
                            child: Semantics(
                              liveRegion: true,
                              label: d3FormatTime(_time, use24h: widget.use24h),
                              excludeSemantics: true,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  d3FormatTime(_time, use24h: widget.use24h),
                                  key: const ValueKey('d3-time-preview'),
                                  maxLines: 1,
                                  style: text.displaySmall?.copyWith(
                                    color: previewColor,
                                    fontWeight: FontWeight.w600,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: rowExtent * visibleRows,
                            child: Row(
                              children: [
                                Expanded(
                                  child: _Wheel(
                                    key: const ValueKey('d3-wheel-hour'),
                                    label: 'Hour',
                                    labels: hourLabels,
                                    initialIndex: widget.use24h
                                        ? _hour24
                                        : _hour24 % 12,
                                    extent: rowExtent,
                                    surface: surface,
                                    onChanged: (i) => setState(() {
                                      _hour24 = widget.use24h
                                          ? i
                                          : i + (_isPm ? 12 : 0);
                                    }),
                                  ),
                                ),
                                Expanded(
                                  child: _Wheel(
                                    key: const ValueKey('d3-wheel-minute'),
                                    label: 'Minute',
                                    labels: minuteLabels,
                                    initialIndex: _minuteIndex,
                                    extent: rowExtent,
                                    surface: surface,
                                    onChanged: (i) =>
                                        setState(() => _minuteIndex = i),
                                  ),
                                ),
                                if (!widget.use24h)
                                  Expanded(
                                    child: _Wheel(
                                      key: const ValueKey('d3-wheel-period'),
                                      label: 'AM or PM',
                                      labels: const ['AM', 'PM'],
                                      initialIndex: _isPm ? 1 : 0,
                                      extent: rowExtent,
                                      surface: surface,
                                      onChanged: (i) => setState(() {
                                        _hour24 =
                                            _hour24 % 12 + (i == 1 ? 12 : 0);
                                      }),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: D3Spacing.s8),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      D3Spacing.s16,
                      D3Spacing.s8,
                      D3Spacing.s16,
                      D3Spacing.s12,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, D3Spacing.s48),
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: D3Spacing.s12),
                        Expanded(
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(0, D3Spacing.s48),
                            ),
                            onPressed: () => Navigator.of(context).pop(_time),
                            child: Text(widget.confirmLabel),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One snapping wheel, exposed to assistive tech as an adjustable value.
class _Wheel extends StatefulWidget {
  const _Wheel({
    super.key,
    required this.label,
    required this.labels,
    required this.initialIndex,
    required this.extent,
    required this.surface,
    required this.onChanged,
  });

  final String label;
  final List<String> labels;
  final int initialIndex;
  final double extent;
  final Color surface;
  final ValueChanged<int> onChanged;

  @override
  State<_Wheel> createState() => _WheelState();
}

class _WheelState extends State<_Wheel> {
  late final FixedExtentScrollController _controller;
  final FocusNode _focus = FocusNode(skipTraversal: false);
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, widget.labels.length - 1);
    _controller = FixedExtentScrollController(initialItem: _index);
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _step(int delta) {
    final target = (_index + delta).clamp(0, widget.labels.length - 1);
    if (target == _index) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.jumpToItem(target);
    } else {
      _controller.animateToItem(
        target,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    final text = Theme.of(context).textTheme;
    final band = Color.alphaBlend(colors.primaryContainer, widget.surface);
    final selectedColor = d3EnsureContrast(colors.onPrimaryContainer, band);
    final idleColor = d3EnsureContrast(colors.onSurfaceVariant, widget.surface);
    final n = widget.labels.length;
    final value = widget.labels[_index];

    return Semantics(
      container: true,
      label: widget.label,
      value: value,
      increasedValue: _index < n - 1 ? widget.labels[_index + 1] : value,
      decreasedValue: _index > 0 ? widget.labels[_index - 1] : value,
      onIncrease: _index < n - 1 ? () => _step(1) : null,
      onDecrease: _index > 0 ? () => _step(-1) : null,
      excludeSemantics: true,
      child: Focus(
        focusNode: _focus,
        onKeyEvent: (node, event) {
          if (event is KeyUpEvent) return KeyEventResult.ignored;
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            _step(1);
            return KeyEventResult.handled;
          }
          if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            _step(-1);
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            IgnorePointer(
              child: Container(
                key: const ValueKey('d3-wheel-band'),
                height: widget.extent,
                margin: const EdgeInsets.symmetric(horizontal: D3Spacing.s4),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: context.d3Shape.circularMd,
                  border: _focus.hasFocus
                      ? Border.all(color: colors.primary, width: 2)
                      : null,
                ),
              ),
            ),
            ListWheelScrollView.useDelegate(
              controller: _controller,
              itemExtent: widget.extent,
              physics: const FixedExtentScrollPhysics(),
              diameterRatio: 2.4,
              perspective: 0.002,
              overAndUnderCenterOpacity: 0.7,
              onSelectedItemChanged: (i) {
                if (i == _index) return;
                HapticFeedback.selectionClick();
                setState(() => _index = i);
                widget.onChanged(i);
              },
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: n,
                builder: (context, i) => Center(
                  child: Text(
                    widget.labels[i],
                    maxLines: 1,
                    style: text.titleLarge?.copyWith(
                      fontSize: 22,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      fontWeight: i == _index
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: i == _index ? selectedColor : idleColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
