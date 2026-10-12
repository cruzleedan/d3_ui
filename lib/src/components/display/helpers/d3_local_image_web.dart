import 'package:material_ui/material_ui.dart';

/// See `d3_local_image.dart`.
Widget d3LocalImage(
  String path, {
  double? width,
  double? height,
  BoxFit? fit,
  ImageErrorWidgetBuilder? errorBuilder,
}) {
  final isUrl = RegExp(r'^(https?:|blob:|data:)').hasMatch(path);
  if (isUrl) {
    return Image.network(
      path,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: errorBuilder,
    );
  }
  // No file system in a browser: report the same error a missing file would.
  return Builder(
    builder: (context) =>
        errorBuilder?.call(
          context,
          UnsupportedError('Local files are not available in a browser'),
          StackTrace.current,
        ) ??
        SizedBox(width: width, height: height),
  );
}
