part of 'index.dart';

/// A singleton registry of snackbar controllers used to keep
/// track of all the snackbars in the application.
class SnackbarRegistry {
  static OverlayController? _currentController;

  /// Notifies the registry that a snackbar has opened and
  /// automatically closes any previously active snackbar.
  ///
  /// Pass `deferClose: true` when called during component
  /// mount/build (`initState` / `didUpdateComponent`) so
  /// closing the previous snackbar runs after the current
  /// build pass finishes.
  static void onOpen(
    OverlayController controller, {
    bool deferClose = false,
  }) {
    final previous = _currentController;
    _currentController = controller;

    if (previous != null && previous != controller) {
      if (deferClose) {
        Future.microtask(previous.close);
      } else {
        previous.close();
      }
    }
  }

  /// Notifies the registry that a snackbar has closed.
  static void onClose(OverlayController controller) {
    if (_currentController == controller) _currentController = null;
  }

  /// Closes the snackbar that is currently open, if any.
  static void closeCurrent() => _currentController?.close();
}
