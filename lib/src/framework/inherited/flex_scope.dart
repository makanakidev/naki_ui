part of 'index.dart';

/// {@template FlexScope}
/// An inherited component created by flex containers such as [Row]
/// or [Column] to provide layout scope information to descendant
/// components.
/// {@endtemplate}
class FlexScope extends InheritedComponent {
  /// Whether the flex container is scrollable.
  final bool scrollable;

  /// {@macro FlexScope}
  const FlexScope({required super.child, this.scrollable = false});

  /// Finds the nearest [FlexScope] instance in the component tree.
  /// This scans the component tree upwards from the component [context]
  /// until it finds an instance of [FlexScope].
  ///
  /// If no [FlexScope] is found, it returns `null`.
  static FlexScope? of(BuildContext context) {
    return context.dependOnInheritedComponentOfExactType<FlexScope>();
  }

  @override
  bool updateShouldNotify(FlexScope oldComponent) =>
      scrollable != oldComponent.scrollable;
}
