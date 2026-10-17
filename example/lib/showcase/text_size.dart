/// The system text sizes the showcase can mimic, so a reader can see how
/// every component and label looks when the device's font size is changed
/// (Android: Settings > Display > Font size; iOS: Larger Text).
class ShowcaseTextSize {
  const ShowcaseTextSize(this.scale, this.label);

  final double scale;
  final String label;

  String get percent => '${(scale * 100).round()}%';

  static const ShowcaseTextSize normal = ShowcaseTextSize(1.0, 'Default');

  static const List<ShowcaseTextSize> all = [
    ShowcaseTextSize(0.85, 'Small'),
    normal,
    ShowcaseTextSize(1.15, 'Large'),
    ShowcaseTextSize(1.3, 'Larger'),
    ShowcaseTextSize(1.5, 'Extra large'),
    ShowcaseTextSize(1.75, 'Huge'),
    ShowcaseTextSize(2.0, 'Maximum'),
  ];

  /// The step closest to [scale].
  static ShowcaseTextSize nearest(double scale) => all.reduce(
        (a, b) => (a.scale - scale).abs() <= (b.scale - scale).abs() ? a : b,
      );

  /// `?text=1.5` as a scale; anything unreadable or out of range is ignored.
  static double? parse(String? value) {
    final v = double.tryParse(value ?? '');
    if (v == null || v < 0.5 || v > 3.0) return null;
    return v;
  }

  /// The query value for [scale] (`1.5`, not `1.50`).
  static String format(double scale) => scale
      .toStringAsFixed(2)
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}
