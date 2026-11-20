part of 'index.dart';

/// {@template ScaffoldScope}
/// An inherited component created by [Scaffold] that provides layout
/// and state information to descendant components.
/// {@endtemplate}
class ScaffoldScope extends InheritedComponent {
  /// The [ScaffoldState] of the enclosing scaffold.
  final ScaffoldState state;

  /// {@macro ScaffoldScope}
  const ScaffoldScope({required super.child, required this.state});

  /// Finds the nearest [ScaffoldScope] instance in the component tree.
  /// This scans the component tree upwards from the component [context]
  /// until it finds an instance of [ScaffoldScope].
  ///
  /// If no [ScaffoldScope] is found, it returns `null`.
  static ScaffoldScope? of(BuildContext context) =>
      context.dependOnInheritedComponentOfExactType<ScaffoldScope>();

  @override
  bool updateShouldNotify(ScaffoldScope oldComponent) =>
      state != oldComponent.state;
}
