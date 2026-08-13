import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';
import 'package:d3_ui/d3_ui.dart';

/// Wraps a previewed widget in the same [MaterialApp] + [D3AppTheme] shell
/// the example app uses, so D3 components render with their real tokens
/// instead of stock Material defaults.
///
/// material_ui 1.0.0 does not ship a concrete [PreviewThemeData] subtype for
/// `Preview.theme`, so theming goes through `Preview.wrapper` instead.
Widget _d3Wrapper(Widget child) {
  return MaterialApp(
    theme: D3AppTheme.light(),
    darkTheme: D3AppTheme.dark(),
    home: Scaffold(body: Center(child: child)),
  );
}

/// [Preview] preconfigured with the D3 theme wrapper and light/dark variants.
final class D3Preview extends MultiPreview {
  const D3Preview({required this.name, this.group = 'Default'});

  final String name;
  final String group;

  @override
  List<Preview> get previews => const [
        Preview(brightness: Brightness.light),
        Preview(brightness: Brightness.dark),
      ];

  @override
  List<Preview> transform() {
    return super.transform().map((preview) {
      final builder = preview.toBuilder()
        ..name = '$name — ${preview.brightness!.name}'
        ..group = group
        ..wrapper = _d3Wrapper;
      return builder.build();
    }).toList();
  }
}

@D3Preview(name: 'Filled', group: 'D3Button')
Widget d3ButtonFilledPreview() {
  return D3Button(label: 'Continue', onPressed: () {});
}

@D3Preview(name: 'Variants', group: 'D3Button')
Widget d3ButtonVariantsPreview() {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      D3Button(label: 'Filled', variant: D3ButtonVariant.filled, onPressed: () {}),
      const SizedBox(height: 8),
      D3Button(label: 'Tonal', variant: D3ButtonVariant.tonal, onPressed: () {}),
      const SizedBox(height: 8),
      D3Button(label: 'Outlined', variant: D3ButtonVariant.outlined, onPressed: () {}),
      const SizedBox(height: 8),
      D3Button(label: 'Ghost', variant: D3ButtonVariant.ghost, onPressed: () {}),
      const SizedBox(height: 8),
      D3Button(label: 'Danger', variant: D3ButtonVariant.danger, onPressed: () {}),
    ],
  );
}

@D3Preview(name: 'Sizes', group: 'D3Button')
Widget d3ButtonSizesPreview() {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      D3Button(label: 'Extra small', size: D3ButtonSize.xs, onPressed: () {}),
      const SizedBox(height: 8),
      D3Button(label: 'Small', size: D3ButtonSize.sm, onPressed: () {}),
      const SizedBox(height: 8),
      D3Button(label: 'Medium', size: D3ButtonSize.md, onPressed: () {}),
      const SizedBox(height: 8),
      D3Button(label: 'Large', size: D3ButtonSize.lg, onPressed: () {}),
      const SizedBox(height: 8),
      D3Button(label: 'Extra large', size: D3ButtonSize.xl, onPressed: () {}),
    ],
  );
}

@D3Preview(name: 'Icon leading', group: 'D3Button')
Widget d3ButtonLeadingIconPreview() {
  return D3Button(
    label: 'Delete',
    variant: D3ButtonVariant.danger,
    leadingIcon: Icons.delete_outline,
    onPressed: () {},
  );
}

@D3Preview(name: 'Loading', group: 'D3Button')
Widget d3ButtonLoadingPreview() {
  return D3Button(
    label: 'Continue',
    buttonState: D3ButtonState.loading,
    loadingLabel: 'Saving…',
    onPressed: () {},
  );
}

@D3Preview(name: 'Disabled', group: 'D3Button')
Widget d3ButtonDisabledPreview() {
  return const D3Button(label: 'Continue', onPressed: null);
}

@D3Preview(name: 'Full width', group: 'D3Button')
Widget d3ButtonFullWidthPreview() {
  return SizedBox(
    width: 320,
    child: D3Button(label: 'Continue', isFullWidth: true, onPressed: () {}),
  );
}

@D3Preview(name: 'Icon only', group: 'D3Button')
Widget d3ButtonIconOnlyPreview() {
  return D3Button.icon(icon: Icons.add, onPressed: () {});
}
