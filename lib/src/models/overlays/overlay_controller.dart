part of 'index.dart';

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
    for (final listener in List<VoidCallback>.of(_listeners)) {
      if (_listeners.contains(listener)) listener();
    }
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
