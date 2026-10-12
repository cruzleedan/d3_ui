import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// A form sheet sized to its fields, with a Save action in the header.
class FormSheetBasicExample extends StatefulWidget {
  const FormSheetBasicExample({super.key});

  @override
  State<FormSheetBasicExample> createState() => _FormSheetBasicExampleState();
}

class _FormSheetBasicExampleState extends State<FormSheetBasicExample> {
  String? _saved;

  Future<void> _open() async {
    final name = TextEditingController();
    final note = TextEditingController();
    final canSave = ValueNotifier<bool>(false);
    final bodyKey = GlobalKey();
    name.addListener(() => canSave.value = name.text.trim().isNotEmpty);

    final result = await D3FormSheet.show<String>(
      context,
      title: 'New place',
      subtitle: 'Add it to your list',
      primaryAction: D3FormSheetAction(
        label: 'Save',
        listenable: canSave,
        enabledBuilder: () => canSave.value,
        onPressed: () =>
            D3FormSheet.pop(bodyKey.currentContext!, name.text.trim()),
      ),
      child: Builder(
        key: bodyKey,
        builder: (_) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              D3TextField(label: 'Name', controller: name, isRequired: true),
              const SizedBox(height: 12),
              D3TextField(label: 'Note', controller: note, maxLines: 3),
            ],
          ),
        ),
      ),
    );
    name.dispose();
    note.dispose();
    canSave.dispose();
    if (result != null) setState(() => _saved = result);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        D3Button(label: 'Add place', onPressed: _open),
        const SizedBox(width: 12),
        if (_saved != null) Flexible(child: Text('Saved: $_saved')),
      ],
    );
  }
}
