import 'package:material_ui/material_ui.dart';

/// Caches [MediaQuery] values in [didChangeDependencies] instead of reading
/// them on every [State.build] call — avoids repeated `InheritedWidget`
/// lookups for widgets (like a positioned tooltip overlay) that only need
/// screen metrics to react to actual size/orientation changes, not rebuilds.
mixin D3FieldMediaQueryCacheMixin<T extends StatefulWidget> on State<T> {
  late double cachedScreenWidth;
  late double cachedScreenHeight;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final size = MediaQuery.sizeOf(context);
    cachedScreenWidth = size.width;
    cachedScreenHeight = size.height;
  }
}
