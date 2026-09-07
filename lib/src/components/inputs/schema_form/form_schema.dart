import 'package:d3_ui/d3_ui.dart';

/// A whole schema-driven form: an ordered list of fields plus a version
/// stamp a caller can use to decide when a locally cached copy is stale.
class FormSchema {
  const FormSchema({
    required this.screenId,
    required this.version,
    required this.fields,
  });

  final String screenId;
  final int version;
  final List<FieldSchema> fields;

  factory FormSchema.fromJson(Map<String, dynamic> json) => FormSchema(
    screenId: json['screenId'] as String,
    version: json['version'] as int,
    fields: (json['fields'] as List<dynamic>)
        .map((f) => FieldSchema.fromJson(f as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'screenId': screenId,
    'version': version,
    'fields': fields.map((f) => f.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) {
    if (other is! FormSchema) return false;
    if (other.screenId != screenId || other.version != version) return false;
    if (other.fields.length != fields.length) return false;
    for (var i = 0; i < fields.length; i++) {
      if (other.fields[i] != fields[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(screenId, version, Object.hashAll(fields));
}
