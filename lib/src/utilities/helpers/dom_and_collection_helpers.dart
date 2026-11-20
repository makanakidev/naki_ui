part of 'index.dart';

/// Listens for taps outside the element [anchor] returns.
///
/// Safari only sends `document` a click on a plain element when that element
/// listens for it, and a scrolling touch ends without a pointerup.
StreamSubscription<Event> listenTapOutside(
  Element? Function() anchor,
  void Function(Event event) onTap,
) => const EventStreamProvider<Event>('pointerup')
    .forTarget(document, useCapture: true)
    .listen((event) {
      if (!event.composedPath().toDart.contains(anchor())) onTap(event);
    });

/// Whether [a] and [b] hold equal elements in the same order.
/// Two nulls are equal.
bool listEquals<T>(List<T>? a, List<T>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null || a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Whether [a] and [b] hold equal values under the same keys.
/// Two nulls are equal.
bool mapEquals<K, V>(Map<K, V>? a, Map<K, V>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null || a.length != b.length) return false;
  for (final key in a.keys) {
    if (!b.containsKey(key) || b[key] != a[key]) return false;
  }
  return true;
}

/// Builds a DOM id from an explicit id, or allocates one from the root
/// [NakiDomIdScope]. Generated ids never depend on labels, values, or other
/// nullable content and are stable across matching server/client renders.
String nakiDomId(BuildContext context, String prefix, {String? id}) {
  final explicit = nakiExplicitDomId(prefix, id);
  if (explicit != null) return explicit;

  final scope = NakiDomIdScope.maybeOf(context);
  if (scope == null) {
    final randomId = (Random.secure().nextInt(9000) + 100).toString();
    return nakiStableKey(prefix, id ?? randomId);
  }

  return scope.registry.resolve(context, prefix);
}

/// Normalizes a caller-provided id without allocating an automatic id.
String? nakiExplicitDomId(String prefix, String? id) {
  final explicit = id?.trim();
  if (explicit.isNullOrEmpty) return null;

  final cleaned = explicit!.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '-');
  return '${prefix}_$cleaned';
}

/// Builds a deterministic non-DOM key for caches and storage.
String nakiStableKey(String prefix, String source) {
  final normalized = source.trim();
  if (normalized.isEmpty) return prefix;

  var hash = 0;
  for (final codeUnit in normalized.codeUnits) {
    hash = (hash * 31 + codeUnit) & 0xffffffff;
  }

  return '${prefix}_${hash.toRadixString(16).padLeft(8, '0')}';
}

/// Callback function that gets executed after the component
/// is fully rendered in DOM (does nothing in server side).
void onComponentRendered(VoidCallback action) {
  if (kIsWeb) window.requestAnimationFrame(action.toJS);
}

/// Download image and save as DataURL to local storage for offline use
Future<void> cacheImage(String src, [String? baseUrl]) async {
  // use the complete URL to derive a stable cache key and avoid suffix
  // collisions between unrelated image hosts and paths.
  final id = nakiStableKey('image', src);

  src = normaliseLink(src, baseUrl);

  if (kIsWeb && src.startsWith('http') && NakiStorage.get<String>(id) == null) {
    try {
      final res = await window.fetch(src.toJS).toDart;

      if (res.ok) {
        final blob = await res.blob().toDart;
        final reader = FileReader();

        reader.onLoadEnd.listen((_) {
          if (reader.result != null) {
            final data = reader.result.dartify();

            if (data is String && data.length <= 2 * 1024 * 1024) {
              NakiStorage.set(id, data);
              debugPrint('Image cached: $src');
            } else {
              debugPrint('Image "$src" cache skipped: payload exceeds 2MB');
            }
          }
        });

        reader.readAsDataURL(blob);
      }
    } catch (e) {
      debugPrint('Failed to cache image:\n$e');
    }
  }
}

/// Print `content` to console in debug mode (or when `force` is set to true)
void debugPrint(dynamic content, [bool force = false]) {
  if (kDebugMode || force) print(content);
}
