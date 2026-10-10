import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:d3_ui/d3_ui.dart';

/// A coupon-shaped card: rounded outline with a semicircular notch on each
/// side and a dashed tear line across the middle. The top half holds a
/// [leading] icon and [title]; the bottom half holds up to two short lines.
///
/// Fixed at [baseHeight] × [width] at normal text size and grows with the
/// system text scale rather than clipping.
class D3TicketCard extends StatelessWidget {
  const D3TicketCard({
    super.key,
    required this.title,
    this.leading = Icons.sell,
    this.primaryLine,
    this.secondaryLine,
    this.onTap,
    this.width = 180,
    this.baseHeight = 80,
    this.notchRadius = 10,
  });

  final String title;
  final IconData leading;
  final String? primaryLine;
  final String? secondaryLine;
  final VoidCallback? onTap;
  final double width;
  final double baseHeight;
  final double notchRadius;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    final scale = math.max(1.0, MediaQuery.textScalerOf(context).scale(1));
    return CustomPaint(
      painter: D3TicketPainter(
        borderColor: colors.outline,
        notchRadius: notchRadius,
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: baseHeight * scale,
          width: width,
          // Keep text clear of the notches.
          padding: EdgeInsets.symmetric(
            horizontal: notchRadius + 4,
            vertical: 4,
          ),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(leading, size: 16),
                    const SizedBox(width: 4),
                    Expanded(
                      // Two lines: a long headline ("₱199 · Latte and a slice of
                      // cake") should read in full on the card, not as "…".
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          height: 1.15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (primaryLine != null)
                        Text(
                          primaryLine!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        ),
                      if (secondaryLine != null && secondaryLine!.isNotEmpty)
                        Text(
                          secondaryLine!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Paints the [D3TicketCard] outline, notches and dashed tear line.
class D3TicketPainter extends CustomPainter {
  const D3TicketPainter({
    required this.borderColor,
    this.borderWidth = 1,
    this.notchRadius = 10,
    this.cornerRadius = 12,
  });

  final Color borderColor;
  final double borderWidth;
  final double notchRadius;
  final double cornerRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final base = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(cornerRadius),
        ),
      );
    final notches = Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(0, size.height / 2),
          radius: notchRadius,
        ),
      )
      ..addOval(
        Rect.fromCircle(
          center: Offset(size.width, size.height / 2),
          radius: notchRadius,
        ),
      );
    canvas.drawPath(
      Path.combine(PathOperation.difference, base, notches),
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth
        ..isAntiAlias = true,
    );

    final line = Paint()
      ..color = borderColor.withValues(alpha: 0.4)
      ..strokeWidth = 1.5;
    const dash = 5.0;
    const gap = 4.0;
    final y = size.height / 2;
    for (var x = notchRadius; x < size.width - notchRadius; x += dash + gap) {
      canvas.drawLine(Offset(x, y), Offset(x + dash, y), line);
    }
  }

  @override
  bool shouldRepaint(covariant D3TicketPainter old) =>
      old.borderColor != borderColor ||
      old.borderWidth != borderWidth ||
      old.notchRadius != notchRadius ||
      old.cornerRadius != cornerRadius;
}
