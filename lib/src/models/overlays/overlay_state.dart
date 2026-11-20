part of 'index.dart';

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
