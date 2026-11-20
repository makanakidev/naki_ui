part of 'index.dart';

/// Provides one request-local DOM id registry to the complete themed tree.
class NakiDomIdScope extends InheritedComponent {
  const NakiDomIdScope({required this.registry, required super.child});

  final NakiDomIdRegistry registry;

  static NakiDomIdScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedComponentOfExactType<NakiDomIdScope>();

  @override
  bool updateShouldNotify(NakiDomIdScope oldComponent) =>
      registry != oldComponent.registry;
}
