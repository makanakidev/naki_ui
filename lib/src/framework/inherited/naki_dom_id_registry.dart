part of 'index.dart';

/// Allocates hydration-stable DOM ids within a root theme tree.
final class NakiDomIdRegistry {
  // Expando keeps component contexts weakly referenced, so unmounted
  // trees do not accumulate in long-lived applications.
  final Expando<Map<String, String>> _ids = Expando('nakiDomIds');
  int _nextId = 0;

  String resolve(BuildContext owner, String prefix) {
    final ownerIds = _ids[owner] ??= <String, String>{};
    return ownerIds.putIfAbsent(
      prefix,
      () => '${prefix}_nakidom_${(_nextId++).toRadixString(36)}',
    );
  }
}
