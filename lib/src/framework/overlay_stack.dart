/// Global stack of open, keyboard-interactive overlays (dialogs, drawers,
/// bottom sheets, pickers, menus).
///
/// Only the top-most entry should react to `Escape` and trap `Tab`, so that
/// closing a picker inside a dialog does not also close the dialog.
abstract final class NakiOverlayStack {
  static final List<Object> _entries = [];

  /// Pushes [owner] on top of the stack (moving it if already present).
  static void push(Object owner) {
    _entries.remove(owner);
    _entries.add(owner);
  }

  /// Removes [owner] from the stack.
  static void remove(Object owner) => _entries.remove(owner);

  /// Whether [owner] is the top-most open overlay.
  ///
  /// Owners that never registered are treated as top-most when the stack is
  /// empty, preserving standalone behaviour.
  static bool isTop(Object owner) =>
      _entries.isEmpty ? true : identical(_entries.last, owner);
}
