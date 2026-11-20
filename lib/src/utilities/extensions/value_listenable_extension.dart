part of 'index.dart';

/// Extension on [ValueListenable] for reactive component rebuilds.
extension ValueListenableExtension<T> on ValueListenable<T> {
  /// Rebuilds a component based on listenable's value changes.
  ///
  /// Example:
  /// ```dart
  /// final counter = ValueNotifier(0);
  /// counter.rebuild((value) => Text(value.toString()));
  /// ```
  Component rebuild(Component Function(T value) builder) {
    return ValueListenableBuilder(
      listenable: this,
      builder: (_, value) => builder(value),
    );
  }
}
