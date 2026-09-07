import 'package:d3_ui/d3_ui.dart';

/// The set of scalar field widgets a [FieldSchema] can describe.
///
/// Deliberately scoped to simple, prop-driven d3_ui inputs. Anything that
/// needs real code — file pickers, camera capture, multi-step flows like
/// receipt OCR — stays a hand-written widget composed alongside a
/// [FormSchema]-driven form, not expressed as a field type here.
enum FieldType {
  text,
  decimal,
  date,
  dropdown,
  toggle,

  /// A row of 2–4 mutually exclusive options, rendered via
  /// [D3SegmentedControl]. Values are [FieldOption.value] strings, same as
  /// [dropdown].
  segmentedButton,
}
