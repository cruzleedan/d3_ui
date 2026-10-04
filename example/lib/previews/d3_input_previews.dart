import 'package:d3_ui/d3_ui.dart';
import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';

@Preview(
    name: 'Input targets and decimal slots',
    group: 'Inputs',
    size: Size(360, 760))
Widget inputTargetsPreview() => MaterialApp(
      theme: D3AppTheme.light(),
      home: const Scaffold(body: SingleChildScrollView(child: InputExamples())),
    );

@Preview(
    name: 'Input targets and decimal slots — dark',
    group: 'Inputs',
    size: Size(360, 760))
Widget inputTargetsDarkPreview() => MaterialApp(
      theme: D3AppTheme.dark(),
      home: const Scaffold(body: SingleChildScrollView(child: InputExamples())),
    );

class InputExamples extends StatefulWidget {
  const InputExamples({super.key});

  @override
  State<InputExamples> createState() => _InputExamplesState();
}

class _InputExamplesState extends State<InputExamples> {
  bool _enabled = true;
  bool _checked = false;
  String _unit = 'kg';
  String _currency = 'USD';

  @override
  Widget build(BuildContext context) {
    final tokens = context.d3InputTokens;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          D3Toggle(
              value: _enabled,
              label: 'Enable amount actions',
              onChanged: (v) => setState(() => _enabled = v)),
          const SizedBox(height: 12),
          const D3DecimalField(
            label: 'Decorative icons',
            initialValue: 12.5,
            prefixIcon: Icons.payments_outlined,
            suffixIcon: Icons.info_outline,
            helperText: 'Icon properties display icons without actions.',
          ),
          const SizedBox(height: 12),
          D3DecimalField(
            label: 'Amount ($_currency)',
            initialValue: 25,
            isEnabled: _enabled,
            helperText: 'Widget slots provide labeled 48 dp actions.',
            prefixWidget: IconButton(
              tooltip: 'Change currency',
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              onPressed: _enabled
                  ? () => setState(
                      () => _currency = _currency == 'USD' ? 'PHP' : 'USD')
                  : null,
              icon: Icon(Icons.currency_exchange, size: tokens.iconSize),
            ),
            suffixWidget: IconButton(
              tooltip: 'Amount details',
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              onPressed: _enabled
                  ? () => showDialog<void>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Amount details'),
                          content: Text(
                              'Enter an amount in $_currency with up to two decimal places.'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Close'))
                          ],
                        ),
                      )
                  : null,
              icon: Icon(Icons.info_outline, size: tokens.iconSize),
            ),
          ),
          const SizedBox(height: 12),
          const D3SearchBar(hint: 'Type to show the clear action'),
          const SizedBox(height: 12),
          D3Checkbox(
              value: _checked,
              label: 'Include tax',
              onChanged: (v) => setState(() => _checked = v)),
          D3Radio<String>(
              value: 'kg',
              groupValue: _unit,
              label: 'Kilograms',
              onChanged: (v) => setState(() => _unit = v)),
          D3Radio<String>(
              value: 'lb',
              groupValue: _unit,
              label: 'Pounds',
              onChanged: (v) => setState(() => _unit = v)),
          D3SegmentedControl<String>(
            segments: const [
              D3Segment(value: 'kg', label: 'Kilograms'),
              D3Segment(value: 'lb', label: 'Pounds')
            ],
            selected: _unit,
            onChanged: (v) => setState(() => _unit = v),
          ),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: [
            D3Chip(
                label: 'Tax',
                selected: _checked,
                onTap: () => setState(() => _checked = !_checked)),
            const D3Chip(label: 'Static badge'),
          ]),
          const D3TextField(
              label: 'Reference',
              tooltip: 'An optional reference for this amount.'),
        ],
      ),
    );
  }
}
