part of 'index.dart';

/// Hands the controller of an overlay shown by an [OverlayHost] to the
/// `Snackbar` or `Dialog` inside it, so they need no controller of their own.
class OverlayEntryScope extends InheritedComponent {
  /// Controller of the overlay below this scope.
  final OverlayController controller;

  /// Creates an [OverlayEntryScope].
  const OverlayEntryScope({
    super.key,
    required this.controller,
    required super.child,
  });

  /// The controller of the overlay [context] belongs to, if it was shown by
  /// an [OverlayHost].
  static OverlayController? maybeOf(BuildContext context) => context
      .dependOnInheritedComponentOfExactType<OverlayEntryScope>()
      ?.controller;

  @override
  bool updateShouldNotify(OverlayEntryScope oldComponent) =>
      controller != oldComponent.controller;
}
