import 'dart:async';
import 'package:flutter/foundation.dart';

/// Cancels and restarts a delayed callback on each [run] call, collapsing
/// the common "debounce user input" pattern into one reusable timer owner.
///
/// ```dart
/// final _debouncer = D3Debouncer(delay: const Duration(milliseconds: 300));
///
/// void _onTextChanged(String query) {
///   _debouncer.run(() => _search(query));
/// }
///
/// @override
/// void dispose() {
///   _debouncer.cancel();
///   super.dispose();
/// }
/// ```
class D3Debouncer {
  D3Debouncer({required this.delay});

  final Duration delay;
  Timer? _timer;

  /// Cancels any pending callback and schedules [action] to run after [delay].
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// Cancels any pending callback without scheduling a new one.
  void cancel() => _timer?.cancel();
}
