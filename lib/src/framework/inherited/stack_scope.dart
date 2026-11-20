part of 'index.dart';

/// {@template StackScope}
/// An inherited component created by [Stack] that provides layout
/// and state information to descendant components.
/// {@endtemplate}
class StackScope extends InheritedComponent {
  /// {@macro StackScope}
  const StackScope({required super.child});

  /// Finds the nearest [StackScope] instance in the component tree.
  /// This scans the component tree upwards from the component [context]
  /// until it finds an instance of [StackScope].
  ///
  /// If no [StackScope] is found, it returns `null`.
  static StackScope? of(BuildContext context) =>
      context.dependOnInheritedComponentOfExactType<StackScope>();

  @override
  bool updateShouldNotify(StackScope oldComponent) => false;
}
