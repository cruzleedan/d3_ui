import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

import '../page_model.dart';
import '../registry.dart';
import '../scope.dart';
import '../version.dart';

/// The groups shown on the Components page and in its side pane, in order.
const componentGroups = [
  ShowcaseGroup.actions,
  ShowcaseGroup.inputs,
  ShowcaseGroup.display,
  ShowcaseGroup.feedback,
  ShowcaseGroup.navigation,
  ShowcaseGroup.overlays,
  ShowcaseGroup.surfaces,
];

/// Whether [page] is a component (as opposed to Home, Components, Theme or
/// the Patterns app).
bool isComponentPage(ShowcasePage page) => componentGroups.contains(page.group);

/// Every component, by group, as cards you can browse without knowing names.
class ComponentsPage extends StatelessWidget {
  const ComponentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    final nav = ShowcaseNav.of(context);
    final count = showcasePages.where(isComponentPage).length;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1080),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 56),
          children: [
            Text(
              'Components',
              style: TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.w700,
                letterSpacing: -1,
                height: 1.05,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '$count components, each with its variants and states and the '
              'code that runs it. Press Ctrl K (or Cmd K) to search.',
              style: TextStyle(
                fontSize: 17,
                height: 1.45,
                color: colors.onSurfaceVariant,
              ),
            ),
            for (final group in componentGroups) ...[
              Padding(
                padding: const EdgeInsets.only(top: 36, bottom: 14),
                child: Text(
                  group.label,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  const gap = 12.0;
                  final columns = (constraints.maxWidth / 300).floor().clamp(
                        1,
                        4,
                      );
                  final width =
                      (constraints.maxWidth - gap * (columns - 1)) / columns;
                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: [
                      for (final page in showcasePages.where(
                        (p) => p.group == group,
                      ))
                        SizedBox(
                          width: width,
                          child: _ComponentCard(
                            page: page,
                            onTap: () => nav.open(page.id),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
            const SizedBox(height: 40),
            Text(
              ShowcaseVersion.label,
              style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComponentCard extends StatelessWidget {
  const _ComponentCard({required this.page, required this.onTap});

  final ShowcasePage page;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    final shape = context.d3Shape;
    return Material(
      color: colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: shape.circularLg,
        side: BorderSide(
          color: shape.cardBorder ?? colors.outline.withValues(alpha: 0.4),
          width: shape.cardBorderWidth,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: shape.circularLg,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: shape.circularMd,
                ),
                child: Icon(page.icon, size: 22, color: colors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      page.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      page.summary,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
