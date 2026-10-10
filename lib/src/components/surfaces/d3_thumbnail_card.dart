import 'package:material_ui/material_ui.dart';
import 'package:d3_ui/d3_ui.dart';

/// A compact list card: a square thumbnail, a title with an optional
/// description and highlighted [badge], and a [trailing] widget (a price, a
/// chevron). Tapping is optional.
class D3ThumbnailCard extends StatelessWidget {
  const D3ThumbnailCard({
    super.key,
    required this.title,
    this.imageUrl,
    this.description,
    this.badge,
    this.trailing,
    this.onTap,
    this.thumbnailSize = 64,
  });

  final String title;

  /// Rendered through [D3Image], which shows its own placeholder when null.
  final String? imageUrl;
  final String? description;

  /// Short highlighted line under the description (e.g. a promotion).
  final String? badge;
  final Widget? trailing;
  final VoidCallback? onTap;
  final double thumbnailSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(D3Spacing.s8),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: D3Radius.circularXs,
                child: D3Image(
                  url: imageUrl,
                  width: thumbnailSize,
                  height: thumbnailSize,
                  semanticsLabel: title,
                ),
              ),
              const SizedBox(width: D3Spacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title),
                    if (description != null)
                      Text(
                        description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: D3TypeScale.labelSmSize,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    if (badge != null)
                      Padding(
                        padding: const EdgeInsets.only(top: D3Spacing.s4),
                        child: Text(
                          badge!,
                          style: TextStyle(
                            fontSize: D3TypeScale.labelSmSize,
                            fontWeight: FontWeight.w700,
                            color: colors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: D3Spacing.s8),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
