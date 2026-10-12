import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

import '../page_model.dart';
import '../registry.dart';
import '../scope.dart';

/// The landing page: what d3_ui is and where to go next.
class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    final scope = ShowcaseScope.of(context);
    final components =
        showcasePages.where((p) => p.group != ShowcaseGroup.start).length;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 880),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 48),
          children: [
            Text(
              'd3_ui',
              style: TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.w700,
                letterSpacing: -1,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'A Flutter design system: tokens, themes and components that '
              'share one look, and a whole brand theme built from a design-token '
              'file.',
              style: TextStyle(
                fontSize: 17,
                height: 1.45,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                D3Button(
                  label: 'Try the components',
                  trailingIcon: Icons.arrow_forward_rounded,
                  onPressed: () => ShowcaseNav.of(context).open('button'),
                ),
                D3Button(
                  label: 'See the theme',
                  variant: D3ButtonVariant.outlined,
                  onPressed: () => ShowcaseNav.of(context).open('theme'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _fact(context, '$components component pages',
                'Every variant and state, with the code that runs it.'),
            _fact(
                context,
                'Switch the brand',
                'Currently ${scope.brand.label}. The same components restyle '
                    'live from a token file; no component changes.'),
            _fact(
                context,
                'Light and dark',
                'Both themes are first class. Use the Theme control in the '
                    'navigation.'),
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
        padding: const EdgeInsets.all(16),
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
