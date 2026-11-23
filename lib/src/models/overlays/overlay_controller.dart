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

/// An [OverlayController] that captures a typed [result] before closing.
///
/// Used by imperative overlay functions (`showDialog`,
/// `showModalBottomSheet`, `showDatePicker`, `showTimePicker`, etc.)
/// and resolved by `Navigator.pop(context, result)`.
class OverlayResultController<T> extends OverlayController {
  /// Result passed when closing this overlay.
  T? result;

  /// Creates a new [OverlayResultController].
  OverlayResultController({super.isOpen = true});

  /// Records [value] (when compatible with [T]) and closes the overlay.
  void closeWith([Object? value]) {
    if (value == null) {
      result = null;
    } else if (value is T) {
      result = value as T?;
    } else {
      throw ArgumentError.value(
        value,
        'result',
        'Expected $T? when popping overlay',
      );
    }
    close();
  }
}

/// An [OverlayController] bound to a custom close callback for declarative
/// overlays (`Dialog`, `BottomSheet`, modal `Drawer`) so `Navigator.pop`
/// triggers the overlay's own close handler.
class OverlayCallbackController extends OverlayController {
  final VoidCallback _onClose;

  /// Creates an [OverlayCallbackController] delegating
  /// [close] to [_onClose].
  OverlayCallbackController(this._onClose, {super.isOpen = true});

  @override
  void close() {
    _onClose();
  }
}
