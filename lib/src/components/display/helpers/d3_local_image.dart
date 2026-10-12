/// A local image from a file path, safe on every platform.
///
/// On mobile and desktop this is `Image.file`. In a browser there is no file
/// system, so `Image.file` would throw; there a path that is really a URL
/// (`http`, `https`, `blob:` or `data:`, which is what a browser's file picker
/// hands back) is shown with `Image.network`, and anything else falls back to
/// the caller's `errorBuilder`.
export 'd3_local_image_io.dart'
    if (dart.library.js_interop) 'd3_local_image_web.dart';
