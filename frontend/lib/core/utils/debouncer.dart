import 'dart:async';
import 'package:flutter/foundation.dart';

/// A utility class for debouncing API calls or expensive operations
class Debouncer {
  /// Returns a new function that is a debounced version of the given function.
  /// The returned function will delay invoking [function] until after [duration]
  /// has elapsed since the last time the debounced function was invoked.
  static Debounceable<S, T> debounce<S, T>(
    Debounceable<S?, T> function, {
    Duration duration = const Duration(milliseconds: 500),
  }) {
    DebounceTimer? debounceTimer;

    return (T parameter) async {
      if (debounceTimer != null && !debounceTimer!.isCompleted) {
        debounceTimer!.cancel();
      }
      debounceTimer = DebounceTimer(duration: duration);
      try {
        await debounceTimer!.future;
      } on CancelException {
        return null;
      }
      return function(parameter);
    };
  }
}

/// Type definition for a function that can be debounced
typedef Debounceable<S, T> = Future<S?> Function(T parameter);

/// Internal timer class for debouncing
class DebounceTimer {
  DebounceTimer({this.duration = const Duration(milliseconds: 500)}) {
    _timer = Timer(duration, _onComplete);
  }

  final Duration duration;
  late final Timer _timer;
  final Completer<void> _completer = Completer<void>();

  void _onComplete() {
    _completer.complete();
  }

  Future<void> get future => _completer.future;

  bool get isCompleted => _completer.isCompleted;

  void cancel() {
    _timer.cancel();
    _completer.completeError(const CancelException());
  }
}

/// Exception thrown when a debounced operation is cancelled
class CancelException implements Exception {
  const CancelException();
}
