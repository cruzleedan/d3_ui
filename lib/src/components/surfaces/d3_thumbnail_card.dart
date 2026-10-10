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
    this.footer,
    this.trailing,
    this.onTap,
    this.thumbnailSize = 64,
    this.showThumbnailWithoutImage = false,
    this.highlightQuery,
  });

  final String title;

  /// Rendered through [D3Image], which shows its own placeholder when null.
  final String? imageUrl;
  final String? description;

  /// Short highlighted line under the description (e.g. a promotion).
  final String? badge;

  /// Optional last line under the badge (e.g. an allergen warning).
  final Widget? footer;
  final Widget? trailing;
  final VoidCallback? onTap;
  final double thumbnailSize;

  /// By default a card with no [imageUrl] is text-only — no placeholder tile
  /// is reserved. Set true to keep [D3Image]'s own placeholder.
  final bool showThumbnailWithoutImage;

  /// When non-empty, matches of this text in [title] are emphasised (for
  /// search results), using [D3SearchAnchor.highlight].
  final String? highlightQuery;

  Widget _title(BuildContext context) {
    final query = highlightQuery;
    if (query == null || query.trim().isEmpty) return Text(title);
    return Text.rich(
      D3SearchAnchor.highlight(
        text: title,
        query: query.trim(),
        style: DefaultTextStyle.of(context).style,
        highlightColor: context.d3Colors.primary,
      ),
    );
  }

  bool get _hasThumbnail =>
      showThumbnailWithoutImage || (imageUrl != null && imageUrl!.isNotEmpty);

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
              if (_hasThumbnail) ...[
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
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _title(context),
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
                    if (footer != null)
                      Padding(
                        padding: const EdgeInsets.only(top: D3Spacing.s4),
                        child: footer!,
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
