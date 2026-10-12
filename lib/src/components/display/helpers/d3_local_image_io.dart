import 'dart:io';

import 'package:material_ui/material_ui.dart';

/// See `d3_local_image.dart`.
Widget d3LocalImage(
  String path, {
  double? width,
  double? height,
  BoxFit? fit,
  ImageErrorWidgetBuilder? errorBuilder,
}) {
  return Image.file(
    File(path),
    width: width,
    height: height,
    fit: fit,
    errorBuilder: errorBuilder,
  );
}
