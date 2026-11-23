part of 'index.dart';

/// Immutable configuration describing a route pushed onto a [Navigator].
class NakiRouteSettings {
  /// Optional route name (e.g. `'/details'`).
  final String? name;

  /// Optional arguments passed to the route.
  final Object? arguments;

  /// Creates route metadata with an optional [name] and [arguments].
  const NakiRouteSettings({this.name, this.arguments});

  /// Returns a copy of this settings object with updated fields.
  NakiRouteSettings copyWith({String? name, Object? arguments}) {
    return NakiRouteSettings(
      name: name ?? this.name,
      arguments: arguments ?? this.arguments,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NakiRouteSettings &&
        other.name == name &&
        other.arguments == arguments;
  }

  @override
  int get hashCode => Object.hash(name, arguments);

  @override
  String toString() => 'NakiRouteSettings(name: $name, arguments: $arguments)';
}
