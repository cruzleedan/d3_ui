import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

import '../example_card.dart';
import '../scope.dart';

/// The Theme page: the tokens of the running theme, read live, so it always
/// shows the current brand and mode.
class ThemePage extends StatelessWidget {
  const ThemePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    final status = context.d3Status;
    final shape = context.d3Shape;
    final scope = ShowcaseScope.of(context);
    final spec = scope.brandThemes[scope.brand.id]?.spec;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return ExamplePage(
      title: 'Theme',
      summary: '${scope.brand.label}, ${dark ? 'dark' : 'light'}. '
          '${spec == null ? 'These are d3_ui\'s defaults.' : 'Built from a design-token file${spec.kit == null ? '' : ' (kit ${spec.kit})'} with D3ThemeSpec.'}',
      importLine: spec == null
          ? "import 'package:d3_ui/d3_ui.dart';"
          : "final spec = D3ThemeSpec.parse(json);\nMaterialApp(theme: spec.lightTheme(), darkTheme: spec.darkTheme());",
      examples: [
        ExampleCard(
          title: 'Colours',
          description: 'D3ColorTokens: read with context.d3Colors.',
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _swatch(context, 'primary', colors.primary, colors.onPrimary),
              _swatch(context, 'surface', colors.surface, colors.onSurface),
              _swatch(context, 'card', colors.surfaceContainerLow,
                  colors.onSurface),
              _swatch(
                  context, 'muted', colors.surfaceVariant, colors.onSurface),
              _swatch(context, 'error', colors.error, colors.onError),
              _swatch(context, 'outline', colors.outline, colors.onSurface),
              _swatch(
                  context, 'divider', colors.outlineVariant, colors.onSurface),
            ],
          ),
        ),
        ExampleCard(
          title: 'Status colours',
          description: 'D3StatusTokens: read with context.d3Status.',
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _statusBadge('Success', status.success),
              _statusBadge('Warning', status.warning),
              _statusBadge('Destructive', status.destructive),
              _statusBadge('Neutral', status.neutral),
            ],
          ),
        ),
        ExampleCard(
          title: 'Shape',
          description:
              'D3ShapeTokens: read with context.d3Shape. Cards use lg, sheets and dialogs xl.',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _radius(context, 'xs', shape.xs),
              _radius(context, 'sm', shape.sm),
              _radius(context, 'md', shape.md),
              _radius(context, 'lg', shape.lg),
              _radius(context, 'xl', shape.xl),
            ],
          ),
        ),
        ExampleCard(
          title: 'Components follow',
          description:
              'Nothing here is styled by hand: switch the brand and watch.',
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              D3Button(label: 'Primary', onPressed: () {}),
              D3Button(
                label: 'Tonal',
                variant: D3ButtonVariant.tonal,
                onPressed: () {},
              ),
              D3Button(
                label: 'Danger',
                variant: D3ButtonVariant.danger,
                onPressed: () {},
              ),
              const D3Chip(label: 'Selected', selected: true),
              const SizedBox(
                width: 220,
                child: D3Card(
                    title: 'A card',
                    subtitle: 'Uses the card colour, radius and outline'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _swatch(BuildContext context, String name, Color color, Color on) {
    return Container(
      width: 104,
      height: 64,
      padding: const EdgeInsets.all(8),
      alignment: Alignment.bottomLeft,
      decoration: BoxDecoration(
        color: color,
        borderRadius: context.d3Shape.circularMd,
        border:
            Border.all(color: context.d3Colors.outline.withValues(alpha: 0.5)),
      ),
      child: Text(name, style: TextStyle(fontSize: 12, color: on)),
    );
  }

  Widget _statusBadge(String label, D3StatusColor c) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.tint,
        borderRadius: D3Radius.circularFull,
        border: Border.all(color: c.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        child: Text(
          label,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w500, color: c.text),
        ),
      ),
    );
  }

  Widget _radius(BuildContext context, String name, double radius) {
    final colors = context.d3Colors;
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            border: Border.all(color: colors.primary),
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
        const SizedBox(height: 4),
        Text('$name ${radius.toStringAsFixed(0)}',
            style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant)),
      ],
    );
  }
}
