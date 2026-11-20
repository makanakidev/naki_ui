part of 'index.dart';

/// {@template AppScope}
/// An inherited component created by [NakiApp] that provides layout
/// and state information to descendant components.
/// {@endtemplate}
class AppScope extends InheritedComponent {
  /// {@macro AppScope}
  AppScope({required super.child});

  /// Finds the nearest [AppScope] instance in the component tree.
  /// This scans the component tree upwards from the component [context]
  /// until it finds an instance of [AppScope].
  ///
  /// If no [AppScope] is found, it returns `null`.
  static AppScope? of(BuildContext context) =>
      context.dependOnInheritedComponentOfExactType<AppScope>();

  @override
  bool updateShouldNotify(AppScope oldComponent) => false;
}
