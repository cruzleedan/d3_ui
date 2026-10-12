import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// Popup dropdowns: empty, selected, helper text, error and disabled.
class DropdownFieldVariantsExample extends StatelessWidget {
  const DropdownFieldVariantsExample({super.key});

  static const _sizes = ['Small', 'Medium', 'Large'];

  Widget _field({
    required String label,
    String? initialValue,
    String? helperText,
    String? errorText,
    bool isEnabled = true,
    IconData? prefixIcon,
  }) {
    return D3DropdownField<String, String>(
      label: label,
      items: _sizes,
      itemLabel: (s) => s,
      itemValue: (s) => s,
      initialValue: initialValue,
      hintText: 'Choose one',
      helperText: helperText,
      errorText: errorText,
      isEnabled: isEnabled,
      prefixIcon: prefixIcon,
      onChanged: (_) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16,
      children: [
        _field(label: 'Size'),
        _field(
          label: 'T-shirt size',
          initialValue: 'Medium',
          prefixIcon: Icons.straighten_rounded,
          helperText: 'You can change this later.',
        ),
        _field(label: 'Size', errorText: 'Pick a size'),
        _field(label: 'Size', initialValue: 'Large', isEnabled: false),
      ],
    );
  }
}
