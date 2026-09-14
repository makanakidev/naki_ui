import 'dart:async';

/// Internal data model for holding the callback
/// and active timer for a debounced operation.
class _NakiDebounceData {
  /// The callback to execute when the timer fires.
  void Function() callback;

  /// The active timer for this operation.
  Timer timer;

  _NakiDebounceData(this.callback, this.timer);
}

/// [NakiDebounce] provides utility methods for debouncing function executions.
///
/// This is useful for rate-limiting operations that are triggered frequently,
/// such as text field input events or window resizing.
///
/// ### Example
/// ```dart
/// NakiDebounce.run(
///   'user-input-debounce',
///   Duration(milliseconds: 300),
///   () {
///     print('Triggered after 300ms of inactivity');
///   },
/// );
/// ```
class NakiDebounce {
  static final Map<String, _NakiDebounceData> _operations = {};

  /// Schedules the execution of [onExecute] after [duration].
  ///
  /// If another call to [run] with the same [tag] occurs
  /// within [duration], the previous scheduled execution
  /// is cancelled and the new one is scheduled.
  ///
  /// If [duration] is [Duration.zero], the callback is executed immediately.
  static void run(
    String tag,
    Duration duration,
    void Function() onExecute,
  ) {
    if (duration == Duration.zero) {
      _operations[tag]?.timer.cancel();
      _operations.remove(tag);
      onExecute();
    } else {
      _operations[tag]?.timer.cancel();
      _operations[tag] = _NakiDebounceData(
        onExecute,
        Timer(duration, () => fire(tag)),
      );
    }
  }

  /// Immediately executes the callback associated
  /// with [tag] and cancels its timer.
  ///
  /// Does nothing if there is no active operation for [tag].
  static void fire(String tag) {
    final operation = _operations[tag];
    if (operation == null) return;
    operation.timer.cancel();
    _operations.remove(tag);
    operation.callback();
  }

  /// Cancels the active debounce operation for
  /// [tag] without executing its callback.
  ///
  /// Does nothing if there is no active operation for [tag].
  static void cancel(String tag) {
    final operation = _operations[tag];
    if (operation == null) return;
    operation.timer.cancel();
    _operations.remove(tag);
  }

  /// Cancels all active debounce operations without
  /// executing their callbacks.
  static void cancelAll() {
    // ignore: curly_braces_in_flow_control_structures
    for (final operation in _operations.values) operation.timer.cancel();
    _operations.clear();
  }

  /// Returns the number of active debounce operations
  /// that are currently pending.
  static int get count => _operations.length;
}
