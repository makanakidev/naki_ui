part of 'index.dart';

// /////////////////////////////////////////////////////////////////////////////
// OVERLAY CONTROLLER & UTILITIES
// /////////////////////////////////////////////////////////////////////////////

/// A singleton registry of snackbar controllers used to keep
/// track of all the snackbars in the application.
class SnackbarRegistry {
  static OverlayController? _currentController;

  /// Notifies the registry that a snackbar has opened and automatically
  /// closes any previously active snackbar.
  static void onOpen(OverlayController controller) {
    if (_currentController != null && _currentController != controller) {
      closeCurrent();
    }
    _currentController = controller;
  }

  /// Notifies the registry that a snackbar has closed.
  static void onClose(OverlayController controller) {
    if (_currentController == controller) _currentController = null;
  }

  /// Closes the snackbar that is currently open, if any.
  static void closeCurrent() => _currentController?.close();
}
