import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// A small "?" or "i" button that explains the control or section beside it
/// in a bottom sheet, so a non-obvious setting is documented where it lives
/// instead of in a manual nobody opens.
///
/// ```dart
/// D3InfoButton(
///   title: 'Report layouts',
///   message: 'A layout decides which parts a PDF report includes…',
/// )
/// ```
///
/// The target is the usual 48 dp. [title] doubles as the semantics label, read
/// as "About <title>".
class D3InfoButton extends StatelessWidget {
  const D3InfoButton({
    super.key,
    required this.title,
    required this.message,
    this.extra,
    this.icon = Icons.info_outline,
  });

  final String title;

  /// One short paragraph. Keep it to what the user needs to decide, not a
  /// feature tour.
  final String message;

  /// Optional extra content under [message], for example a short list.
  final Widget? extra;

  final IconData icon;

  /// Opens the same sheet without the button, for callers that trigger it
  /// from their own control.
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    Widget? extra,
  }) {
    return D3BottomSheet.show<void>(
      context,
      title: title,
      snapPoints: const [D3SnapPoint(0.35), D3SnapPoint.half],
      child: _InfoBody(message: message, extra: extra),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 20, color: context.d3Colors.onSurfaceVariant),
      tooltip: 'About $title',
      onPressed: () =>
          show(context, title: title, message: message, extra: extra),
    );
  }
}

class _InfoBody extends StatelessWidget {
  const _InfoBody({required this.message, this.extra});

  final String message;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        D3Spacing.s16,
        D3Spacing.s8,
        D3Spacing.s16,
        D3Spacing.s24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: colors.onSurface),
          ),
          if (extra != null) ...[const SizedBox(height: D3Spacing.s12), extra!],
        ],
      ),
    );
  }
}
