// Audit: every tappable d3_ui widget must offer a tap region of at least 48x48
// dp (the visual may be smaller). Pumps each widget with semantics on and runs
// Flutter's own tap-target guideline over the accessibility tree.
//
// Run: flutter test test/audit/tap_target_audit_test.dart
import 'package:d3_ui/d3_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void _noop() {}

class _Case {
  const _Case(this.name, this.build, {this.setup});
  final String name;
  final Widget Function(BuildContext) build;
  final Future<void> Function(WidgetTester)? setup;
}

Widget _host(Widget child) => MaterialApp(
  theme: D3AppTheme.light(),
  home: Scaffold(
    // Centred: the guideline skips nodes that touch the screen edge.
    body: Center(child: child),
  ),
);

final _cases = <_Case>[
  // ── actions
  for (final size in D3ButtonSize.values)
    _Case(
      'D3Button ${size.name}',
      (_) => D3Button(label: 'Go', size: size, onPressed: _noop),
    ),
  for (final size in D3ButtonSize.values)
    _Case(
      'D3Button icon-only ${size.name}',
      (_) => D3Button.icon(
        icon: Icons.add,
        size: size,
        onPressed: _noop,
        semanticsLabel: 'Add',
      ),
    ),
  _Case(
    'D3HyperlinkButton',
    (_) => const D3HyperlinkButton(label: 'Learn more', onPressed: _noop),
  ),
  _Case(
    'D3ScrimIconButton default',
    (_) => D3ScrimIconButton(
      icon: Icons.close,
      semanticsLabel: 'Close',
      onTap: _noop,
    ),
  ),
  _Case(
    'D3ScrimIconButton 32',
    (_) => D3ScrimIconButton(
      icon: Icons.close,
      semanticsLabel: 'Close',
      size: 32,
      onTap: _noop,
    ),
  ),
  for (final size in D3ButtonSize.values)
    _Case(
      'D3SplitButton ${size.name}',
      (_) => D3SplitButton(
        label: 'Save',
        size: size,
        onPressed: _noop,
        items: [D3SplitButtonItem(label: 'Other', onPressed: _noop)],
      ),
    ),
  _Case(
    'D3ExpandingFab',
    (_) => D3ExpandingFab(
      actions: [D3FabAction(icon: Icons.edit, label: 'Edit', onPressed: _noop)],
    ),
  ),
  // ── inputs
  _Case('D3Chip outlined', (_) => const D3Chip(label: 'Tag', onTap: _noop)),
  _Case(
    'D3Chip selected',
    (_) => const D3Chip(label: 'Tag', selected: true, onTap: _noop),
  ),
  _Case(
    'D3Chip dismissible',
    (_) => const D3Chip(label: 'Tag', trailingIcon: Icons.close, onTap: _noop),
  ),
  _Case(
    'D3FilterChipRow',
    (_) => D3FilterChipRow<String>(
      options: const [
        D3FilterOption(value: 'a', label: 'A'),
        D3FilterOption(value: 'b', label: 'B'),
      ],
      selected: const {'a'},
      onChanged: (_) {},
    ),
  ),
  _Case(
    'D3Checkbox',
    (_) => D3Checkbox(value: false, label: 'Agree', onChanged: (_) {}),
  ),
  _Case(
    'D3Checkbox no label',
    (_) => D3Checkbox(value: true, semanticsLabel: 'Agree', onChanged: (_) {}),
  ),
  _Case(
    'D3Radio',
    (_) =>
        D3Radio<int>(value: 1, groupValue: 0, label: 'One', onChanged: (_) {}),
  ),
  _Case(
    'D3Toggle',
    (_) => D3Toggle(value: true, label: 'Wi-Fi', onChanged: (_) {}),
  ),
  _Case(
    'D3Toggle no label',
    (_) => D3Toggle(value: true, semanticsLabel: 'Wi-Fi', onChanged: (_) {}),
  ),
  _Case(
    'D3SegmentedControl',
    (_) => D3SegmentedControl<int>(
      segments: const [
        D3Segment(value: 1, label: 'A'),
        D3Segment(value: 2, label: 'B'),
      ],
      selected: 1,
      onChanged: (_) {},
    ),
  ),
  _Case(
    'D3SegmentedControl icons',
    (_) => D3SegmentedControl<int>(
      segments: const [
        D3Segment(value: 1, icon: Icons.grid_view, semanticsLabel: 'Grid'),
        D3Segment(value: 2, icon: Icons.list, semanticsLabel: 'List'),
      ],
      selected: 1,
      onChanged: (_) {},
    ),
  ),
  _Case(
    'D3TextField password',
    (_) => const SizedBox(
      width: 320,
      child: D3TextField(label: 'Password', obscureText: true),
    ),
  ),
  _Case('D3SearchBar', (_) => const SizedBox(width: 320, child: D3SearchBar())),
  _Case(
    'D3SearchBar readOnly',
    (_) =>
        SizedBox(width: 320, child: D3SearchBar(readOnly: true, onTap: _noop)),
  ),
  _Case(
    'D3DateField',
    (_) => const SizedBox(width: 320, child: D3DateField(label: 'Date')),
  ),
  _Case(
    'D3TimeField',
    (_) => const SizedBox(width: 320, child: D3TimeField(label: 'Time')),
  ),
  _Case(
    'D3DropdownField',
    (_) => SizedBox(
      width: 320,
      child: D3DropdownField<String, String>(
        label: 'Size',
        items: const ['S', 'M'],
        itemLabel: (s) => s,
        itemValue: (s) => s,
        onChanged: (_) {},
      ),
    ),
  ),
  _Case(
    'D3DecimalField',
    (_) => const SizedBox(
      width: 320,
      child: D3DecimalField(label: 'Price', initialValue: 1),
    ),
  ),
  _Case('D3Rating interactive', (_) => D3Rating(value: 3, onChanged: (_) {})),
  _Case(
    'D3Rating compact',
    (_) => D3Rating(value: 3, onChanged: (_) {}, size: 18),
  ),
  _Case(
    'D3Slider',
    (_) => SizedBox(
      width: 320,
      child: D3Slider(value: 0.5, onChanged: (_) {}, label: 'Vol'),
    ),
  ),
  _Case(
    'D3QuantityStepper',
    (_) => D3QuantityStepper(value: 1, onChanged: (_) {}),
  ),
  _Case(
    'D3QuantityStepper compact',
    (_) => D3QuantityStepper(value: 1, onChanged: (_) {}, compact: true),
  ),
  _Case('D3OtpField', (_) => const SizedBox(width: 340, child: D3OtpField())),
  // ── navigation
  _Case(
    'D3NavBar',
    (_) => SizedBox(
      width: 360,
      child: D3NavBar(
        selectedIndex: 0,
        onTabSelected: (_) {},
        items: const [
          D3NavItem(icon: Icons.home, label: 'Home'),
          D3NavItem(icon: Icons.search, label: 'Find'),
          D3NavItem(icon: Icons.person, label: 'Me'),
        ],
      ),
    ),
  ),
  _Case(
    'D3NavBar centre action',
    (_) => SizedBox(
      width: 360,
      child: D3NavBar(
        selectedIndex: 0,
        onTabSelected: (_) {},
        centerAction: D3NavBarCenterAction(
          icon: Icons.add,
          onPressed: _noop,
          semanticsLabel: 'New',
        ),
        items: const [
          D3NavItem(icon: Icons.home, label: 'Home'),
          D3NavItem(icon: Icons.search, label: 'Find'),
        ],
      ),
    ),
  ),
  _Case(
    'D3NavRail',
    (_) => SizedBox(
      height: 400,
      child: D3NavRail(
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        items: const [
          D3NavItem(icon: Icons.home, label: 'Home'),
          D3NavItem(icon: Icons.search, label: 'Find'),
        ],
      ),
    ),
  ),
  _Case('D3TabBar', (_) => const SizedBox(width: 360, child: _TabsHost())),
  // ── surfaces / display
  _Case(
    'D3ListTile',
    (_) => SizedBox(
      width: 360,
      child: D3ListTile(title: 'Row', onTap: _noop),
    ),
  ),
  _Case(
    'D3ListTile compact',
    (_) => SizedBox(
      width: 360,
      child: D3ListTile(title: 'Row', minHeight: 32, onTap: _noop),
    ),
  ),
  _Case(
    'D3Card',
    (_) => SizedBox(
      width: 300,
      child: D3Card(content: const Text('Hi'), onTap: _noop),
    ),
  ),
  _Case(
    'D3SectionHeader action',
    (_) => SizedBox(
      width: 360,
      child: D3SectionHeader(
        label: 'Saved',
        count: 3,
        trailingIcon: Icons.delete_outline,
        trailingSemanticsLabel: 'Clear',
        onTrailingTap: _noop,
      ),
    ),
  ),
  _Case(
    'D3ExpandableSection',
    (_) => const SizedBox(
      width: 360,
      child: D3ExpandableSection(title: 'More', child: Text('x')),
    ),
  ),
  _Case(
    'D3Banner action+dismiss',
    (_) => SizedBox(
      width: 360,
      child: D3Banner(
        message: 'Hi',
        action: D3BannerAction(label: 'Retry', onPressed: _noop),
        onDismiss: _noop,
      ),
    ),
  ),
  _Case('D3InfoTip', (_) => const D3InfoTip(message: 'Help')),
  _Case(
    'D3MenuButton',
    (_) => const D3MenuButton(entries: [D3MenuItem(label: 'One')]),
  ),
  _Case(
    'D3EmptyState action',
    (_) => SizedBox(
      width: 360,
      child: D3EmptyState(
        icon: Icons.inbox,
        title: 'None',
        action: D3Button(label: 'Add', onPressed: _noop),
      ),
    ),
  ),
  _Case('D3Avatar', (_) => const D3Avatar(name: 'Ana Reyes')),
];

class _TabsHost extends StatefulWidget {
  const _TabsHost();
  @override
  State<_TabsHost> createState() => _TabsHostState();
}

class _TabsHostState extends State<_TabsHost>
    with SingleTickerProviderStateMixin {
  late final TabController c = TabController(length: 2, vsync: this);
  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      D3TabBar(controller: c, tabs: const [Text('One'), Text('Two')]);
}

void main() {
  testWidgets('audit: tap targets', (tester) async {
    final handle = tester.ensureSemantics();
    final failures = <String>[];
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    for (final c in _cases) {
      try {
        await tester.pumpWidget(
          KeyedSubtree(
            key: ValueKey(c.name),
            child: _host(Builder(builder: c.build)),
          ),
        );
        await tester.pump(const Duration(milliseconds: 300));
        final result = await androidTapTargetGuideline.evaluate(tester);
        if (!result.passed) {
          final reason = (result.reason ?? '')
              .split('\n')
              .where((l) => l.contains('expected tap target'))
              .map(
                (l) => l.replaceAll(RegExp(r'SemanticsNode#\d+\(.*?\): '), ''),
              )
              .join(' | ');
          failures.add('FAIL ${c.name}: $reason');
        }
      } catch (e) {
        failures.add('ERROR ${c.name}: ${e.toString().split('\n').first}');
      }
    }
    handle.dispose();
    // ignore: avoid_print
    print(
      '\n=== TAP TARGET AUDIT (${_cases.length} cases) ===\n${failures.isEmpty ? 'all pass' : failures.join('\n')}\n',
    );
    // The guideline measures a text input's editable-text node (24 dp) rather
    // than the field's gesture box, so these three are covered by explicit
    // hit-test tests in widget_input_tap_targets_test.dart instead.
    const textInputs = {
      'D3TextField password',
      'D3SearchBar',
      'D3DecimalField',
    };
    expect(
      failures.where((f) => !textInputs.any((n) => f.startsWith('FAIL $n:'))),
      isEmpty,
    );
  });
}
