// Audit: long labels/values and large system text scale. Each widget is pumped
// at 320 dp wide with long strings at text scales 1, 1.5, 2 and 3, and the
// audit reports render overflows (layout errors) and text that was truncated
// with an ellipsis.
//
// Run: flutter test test/audit/text_scale_audit_test.dart
import 'package:d3_ui/d3_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void _noop() {}

const _long =
    'A very long label that keeps going well past the width of a phone screen';
const _word = 'Supercalifragilisticexpialidocious_Unbreakable_Identifier_12345';

class _Case {
  const _Case(this.name, this.build);
  final String name;
  final Widget Function(BuildContext) build;
}

final _cases = <_Case>[
  for (final size in D3ButtonSize.values)
    _Case(
      'D3Button ${size.name}',
      (_) => D3Button(label: _long, size: size, onPressed: _noop),
    ),
  _Case(
    'D3Button leading icon',
    (_) => D3Button(label: _long, leadingIcon: Icons.add, onPressed: _noop),
  ),
  _Case(
    'D3Button fullWidth',
    (_) => D3Button(label: _long, isFullWidth: true, onPressed: _noop),
  ),
  _Case(
    'D3SplitButton',
    (_) => D3SplitButton(
      label: _long,
      onPressed: _noop,
      items: const [D3SplitButtonItem(label: _long, onPressed: _noop)],
    ),
  ),
  _Case(
    'D3HyperlinkButton',
    (_) => const D3HyperlinkButton(label: _long, onPressed: _noop),
  ),
  _Case('D3Chip', (_) => const D3Chip(label: _long, onTap: _noop)),
  _Case(
    'D3Chip icons',
    (_) => const D3Chip(
      label: _long,
      leadingIcon: Icons.add,
      trailingIcon: Icons.close,
      onTap: _noop,
    ),
  ),
  _Case(
    'D3FilterChipRow',
    (_) => D3FilterChipRow<String>(
      options: const [
        D3FilterOption(value: 'a', label: _long),
        D3FilterOption(value: 'b', label: 'Short'),
      ],
      selected: const {'a'},
      onChanged: (_) {},
    ),
  ),
  _Case(
    'D3Checkbox',
    (_) => D3Checkbox(value: false, label: _long, onChanged: (_) {}),
  ),
  _Case(
    'D3Radio',
    (_) =>
        D3Radio<int>(value: 1, groupValue: 0, label: _long, onChanged: (_) {}),
  ),
  _Case(
    'D3Toggle',
    (_) => D3Toggle(value: true, label: _long, onChanged: (_) {}),
  ),
  _Case(
    'D3SegmentedControl',
    (_) => D3SegmentedControl<int>(
      segments: const [
        D3Segment(value: 1, label: 'Daily and weekly'),
        D3Segment(value: 2, label: 'Monthly'),
        D3Segment(value: 3, label: 'Yearly'),
      ],
      selected: 1,
      onChanged: (_) {},
    ),
  ),
  _Case(
    'D3TextField long label+hint+helper',
    (_) => const D3TextField(
      label: _long,
      hintText: _long,
      helperText: _long,
      initialValue: _long,
    ),
  ),
  _Case(
    'D3TextField long error',
    (_) => const D3TextField(label: 'Name', errorText: _long),
  ),
  _Case(
    'D3TextField unbreakable value',
    (_) => const D3TextField(label: 'Id', initialValue: _word),
  ),
  _Case(
    'D3TextField multiline',
    (_) => const D3TextField(label: 'Notes', initialValue: _long, maxLines: 3),
  ),
  _Case('D3SearchBar', (_) => const D3SearchBar(hint: _long)),
  _Case('D3DateField', (_) => const D3DateField(label: _long)),
  _Case('D3TimeField', (_) => const D3TimeField(label: _long)),
  _Case(
    'D3DropdownField long item',
    (_) => D3DropdownField<String, String>(
      label: _long,
      items: const [_long],
      initialValue: _long,
      itemLabel: (s) => s,
      itemValue: (s) => s,
      onChanged: (_) {},
    ),
  ),
  _Case(
    'D3DecimalField',
    (_) => const D3DecimalField(label: _long, initialValue: 123456789.12),
  ),
  _Case(
    'D3QuantityStepper',
    (_) => D3QuantityStepper(value: 12, onChanged: (_) {}),
  ),
  _Case(
    'D3Slider',
    (_) => D3Slider(value: 0.5, onChanged: (_) {}, label: _long),
  ),
  _Case(
    'D3NavBar',
    (_) => D3NavBar(
      selectedIndex: 0,
      onTabSelected: (_) {},
      items: const [
        D3NavItem(icon: Icons.home, label: 'Home page'),
        D3NavItem(icon: Icons.search, label: 'Search and filter'),
        D3NavItem(icon: Icons.person, label: 'My profile'),
        D3NavItem(icon: Icons.settings, label: 'Settings'),
      ],
    ),
  ),
  _Case(
    'D3ListTile',
    (_) => D3ListTile(
      title: _long,
      subtitle: _long,
      leading: const Icon(Icons.home),
      trailing: const Text('12:30'),
      onTap: _noop,
    ),
  ),
  _Case(
    'D3Card',
    (_) => D3Card(
      title: _long,
      subtitle: _long,
      content: const Text(_long),
      onTap: _noop,
    ),
  ),
  _Case(
    'D3SectionHeader',
    (_) => D3SectionHeader(
      label: _long,
      count: 123,
      trailingIcon: Icons.delete_outline,
      trailingSemanticsLabel: 'Clear',
      onTrailingTap: _noop,
    ),
  ),
  _Case(
    'D3ExpandableSection',
    (_) => const D3ExpandableSection(
      title: _long,
      subtitle: _long,
      child: Text(_long),
    ),
  ),
  _Case(
    'D3Banner',
    (_) => D3Banner(
      message: _long,
      title: _long,
      action: D3BannerAction(label: 'Retry now please', onPressed: _noop),
      onDismiss: _noop,
    ),
  ),
  _Case(
    'D3EmptyState',
    (_) => D3EmptyState(
      icon: Icons.inbox,
      title: _long,
      message: _long,
      action: D3Button(label: _long, onPressed: _noop),
    ),
  ),
  _Case('D3Badge', (_) => const D3Badge.count(123456)),
  _Case('D3Avatar', (_) => const D3Avatar(name: _long)),
];

void main() {
  testWidgets('audit: long text and text scale', (tester) async {
    final report = <String>[];
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    for (final c in _cases) {
      for (final scale in const [1.0, 1.5, 2.0, 3.0]) {
        try {
          await tester.pumpWidget(
            KeyedSubtree(
              key: ValueKey('${c.name}@$scale'),
              child: MaterialApp(
                theme: D3AppTheme.light(),
                builder: (ctx, child) => MediaQuery(
                  data: MediaQuery.of(ctx)
                      .copyWith(textScaler: TextScaler.linear(scale)),
                  child: child!,
                ),
                home: Scaffold(
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Builder(builder: c.build),
                  ),
                ),
              ),
            ),
          );
          await tester.pump(const Duration(milliseconds: 300));
          final ex = tester.takeException();
          if (ex != null) {
            final msg = ex.toString().split('\n').first;
            report.add('OVERFLOW ${c.name} @$scale: $msg');
            continue;
          }
          var cut = 0;
          void walk(RenderObject o) {
            if (o is RenderParagraph && o.didExceedMaxLines) cut++;
            o.visitChildren(walk);
          }

          walk(tester.binding.rootElement!.renderObject!);
          if (cut > 0) report.add('cut      ${c.name} @$scale: $cut text(s)');
        } catch (e) {
          report.add(
            'ERROR    ${c.name} @$scale: ${e.toString().split('\n').first}',
          );
        }
      }
    }
    // ignore: avoid_print
    print('\n=== TEXT SCALE AUDIT ===\n${report.join('\n')}\n');
    expect(report.where((r) => !r.startsWith('cut')), isEmpty);
  });
}
