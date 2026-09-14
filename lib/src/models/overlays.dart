import 'package:jaspr/jaspr.dart';

// /////////////////////////////////////////////////////////////////////////////
// OVERLAY CONTROLLER & UTILITIES
// /////////////////////////////////////////////////////////////////////////////

/// A singleton registry of snackbar controllers used to keep
/// track of all the snackbars in the application.
final class SnackbarRegistry {
  static OverlayController? _currentController;

  /// Notifies the registry that a snackbar has opened and automatically
  /// closes any previously active snackbar.
  static void onOpen(OverlayController controller) {
    if (_currentController != null && _currentController != controller) {
      _currentController?.close();
    }

    _currentController = controller;
  }

  /// Notifies the registry that a snackbar has closed.
  static void onClose(OverlayController controller) {
    if (_currentController == controller) _currentController = null;
  }
}

/// Controls an overlay component (Dialog, Drawer, BottomSheet,
/// Snackbar, Tooltip, Alert), managing its open/closed visibility
/// state and listener notifications.
class OverlayController {
  bool _isOpen;

  /// Creates a new [OverlayController].
  OverlayController({bool isOpen = false}) : _isOpen = isOpen;

  /// Whether the target overlay is currently open / visible.
  bool get isOpen => _isOpen;

  /// Stores listener callbacks for state change notifications.
  final List<VoidCallback> _listeners = [];

  /// Adds a listener callback triggered on state changes.
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  /// Removes a registered listener callback.
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  /// Notifies all registered listeners of a state change.
  void notifyListeners() {
    for (final listener in _listeners) listener();
  }

  /// Opens / shows the target overlay.
  void open() {
    if (!_isOpen) {
      _isOpen = true;
      notifyListeners();
    }
  }

  /// Closes / hides the target overlay.
  void close() {
    if (_isOpen) {
      _isOpen = false;
      notifyListeners();
    }
  }

  /// Toggles the overlay between open and closed states.
  void toggle() {
    if (_isOpen) {
      close();
    } else {
      open();
    }
  }

  /// Clears all registered listeners.
  void dispose() {
    _listeners.clear();
  }
}

// /////////////////////////////////////////////////////////////////////////////
// OPEN / CLOSE UTILITIES
// /////////////////////////////////////////////////////////////////////////////

/// Utility class for controlling overlay components
class OverlayState {
  /// Opens the overlay bound to the provided [controller].
  static void open(OverlayController controller) {
    controller.open();
  }

  /// Closes the overlay bound to the provided [controller].
  static void close(OverlayController controller) {
    controller.close();
  }

  /// Toggles the open/closed state of the overlay bound to [controller].
  static void toggle(OverlayController controller) {
    controller.toggle();
  }

  /// Shows the overlay bound to [controller].
  static void show(OverlayController controller) {
    controller.open();
  }

  /// Hides the overlay bound to [controller].
  static void hide(OverlayController controller) {
    controller.close();
  }
}
