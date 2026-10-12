import 'package:d3_ui/d3_ui.dart';
import 'package:material_ui/material_ui.dart';

/// Shows a page from a deferred library: the code for the page group is fetched
/// the first time one of its pages is opened, so the first load carries only
/// the shell, the Overview and the Theme page.
class DeferredPage extends StatefulWidget {
  const DeferredPage({super.key, required this.load, required this.builder});

  /// A deferred library's `loadLibrary`.
  final Future<void> Function() load;
  final WidgetBuilder builder;

  @override
  State<DeferredPage> createState() => _DeferredPageState();
}

class _DeferredPageState extends State<DeferredPage> {
  late Future<void> _loading = widget.load();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loading,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            !snapshot.hasError) {
          return widget.builder(context);
        }
        if (snapshot.hasError) {
          return D3EmptyState(
            icon: Icons.cloud_off_rounded,
            title: 'Could not load this page',
            message: 'Check your connection and try again.',
            action: D3Button(
              label: 'Try again',
              onPressed: () => setState(() => _loading = widget.load()),
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
