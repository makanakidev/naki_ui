part of 'index.dart';

/// Provides one request-local style registry to the complete themed tree.
class NakiStyleScope extends InheritedComponent {
  const NakiStyleScope({required this.registry, required super.child});

  final NakiStyleRegistry registry;

  static NakiStyleScope? of(BuildContext context) =>
      context.dependOnInheritedComponentOfExactType<NakiStyleScope>();

  @override
  bool updateShouldNotify(NakiStyleScope oldComponent) =>
      registry != oldComponent.registry;
}
