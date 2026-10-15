import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

import '../aurora_hero.dart';
import '../home_collage.dart';
import '../registry.dart';
import '../scope.dart';
import '../version.dart';
import 'components_page.dart';

/// Home: a large heading and call to action on the aurora, beside a collage of
/// live d3_ui widgets that follow the brand and theme.
class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = ShowcaseScope.of(context);
    final appTheme = Theme.of(context);
    // The hero is a night sky in every theme: its text and buttons use the
    // brand's dark theme; the collage on top of it uses the active theme, like
    // app screens on a dark background.
    final nightTheme = scope.brandThemes[scope.brand.id]!.dark;
    final night = nightTheme.extension<D3TokensExtension>()!.colors;
    final components = showcasePages.where(isComponentPage).length;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1240),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 56),
          children: [
            ClipRRect(
              borderRadius: context.d3Shape.circularXl,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 1060;
                  final text = Theme(
                    data: nightTheme,
                    child: _HeroText(
                      night: night,
                      components: components,
                      wide: wide,
                    ),
                  );
                  // Its own layer: the aurora repaints every frame and must not drag
                  // the collage's picture along with it.
                  final collage = RepaintBoundary(
                      child: Theme(
                    data: appTheme,
                    child: HomeCollage(
                      clipHeight: wide ? 500 : null,
                      singleColumn: !wide,
                    ),
                  ));
                  return AuroraHero(
                    night: night,
                    shaded: !scope.embed,
                    child: wide
                        ? Padding(
                            padding: const EdgeInsets.fromLTRB(48, 56, 40, 0),
                            child: SizedBox(
                              height: 560,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(flex: 5, child: text),
                                  const SizedBox(width: 40),
                                  Expanded(flex: 6, child: collage),
                                ],
                              ),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                text,
                                const SizedBox(height: 28),
                                collage,
                              ],
                            ),
                          ),
                  );
                },
              ),
            ),
            const SizedBox(height: 28),
            LayoutBuilder(
              builder: (context, constraints) {
                final cards = [
                  _fact(
                    context,
                    '$components components',
                    'Every variant and state, with the code that runs it.',
                  ),
                  _fact(
                    context,
                    'Switch the brand',
                    'Currently ${scope.brand.label}. The same components '
                        'restyle live from a token file.',
                  ),
                  _fact(
                    context,
                    'Light and dark',
                    'Both themes are first class. Use the theme button in '
                        'the rail.',
                  ),
                ];
                if (constraints.maxWidth < 720) {
                  return Column(children: [for (final c in cards) c]);
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < cards.length; i++) ...[
                      if (i > 0) const SizedBox(width: 14),
                      Expanded(child: cards[i]),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 22),
            Text(
              ShowcaseVersion.label,
              style: TextStyle(
                fontSize: 12,
                color: context.d3Colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fact(BuildContext context, String title, String body) {
    final colors = context.d3Colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: context.d3Shape.circularLg,
          border: Border.all(
            color: context.d3Shape.cardBorder ??
                colors.outline.withValues(alpha: 0.4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(body, style: TextStyle(color: colors.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

/// The heading, sentence and buttons on the night sky.
class _HeroText extends StatelessWidget {
  const _HeroText({
    required this.night,
    required this.components,
    required this.wide,
  });

  final D3ColorTokens night;
  final int components;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final nav = ShowcaseNav.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'd3_ui',
          style: TextStyle(
            fontSize: wide ? 88 : 56,
            fontWeight: FontWeight.w700,
            letterSpacing: wide ? -3 : -1.5,
            height: 1.0,
            color: night.onSurface,
          ),
        ),
        SizedBox(height: wide ? 20 : 14),
        Text(
          'A Flutter design system: tokens, themes and $components components '
          'that share one look, and restyle from a token file.',
          style: TextStyle(
            fontSize: wide ? 21 : 17,
            height: 1.45,
            color: night.onSurface,
          ),
        ),
        SizedBox(height: wide ? 32 : 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            D3Button(
              label: 'Try the components',
              size: D3ButtonSize.lg,
              trailingIcon: Icons.arrow_forward_rounded,
              onPressed: () => nav.open('components'),
            ),
            D3Button(
              label: 'See the theme',
              size: D3ButtonSize.lg,
              variant: D3ButtonVariant.outlined,
              onPressed: () => nav.open('theme'),
            ),
          ],
        ),
      ],
    );
  }
}
