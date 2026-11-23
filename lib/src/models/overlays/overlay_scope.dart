part of 'index.dart';

/// A singleton registry for managing overlay scopes.
class _OverlayScopeRegistry {
  /// A notifier that holds all active overlay scopes.
  static final ValueNotifier<Map<String, Component>> notifier = ValueNotifier(
    {},
  );

  static final Map<String, Component> _activeScopes = {};
  static bool _scheduled = false;

  /// Registers a scope with the registry.
  static void register(String id, Component child) {
    if (kIsServer) return;
    _activeScopes[id] = child;
    _notify();
  }

  /// Unregisters a scope from the registry.
  static void unregister(String id) {
    if (kIsServer) return;
    _activeScopes.remove(id);
    _notify();
  }

  static void _notify() {
    if (_scheduled) return;
    _scheduled = true;
    Future.microtask(() {
      _scheduled = false;
      notifier.value = Map.of(_activeScopes);
    });
  }
}

/// {@template naki_ui.overlay_scope}
/// A component that registers its [child] with [_OverlayScopeRegistry].
///
/// This component does not render anything itself but allows its [child]
/// to be rendered in a different part of the DOM tree. It is used to
/// scope overlays to a specific part of the application, allowing for
/// better organization and management of overlays.
///
/// Example
/// ```dart
/// OverlayScope(
///   id: 'my-scope',
///   child: MyComponent(),
/// );
/// ```
/// {@endtemplate}
class OverlayScope extends StatefulComponent {
  final Component child;
  final String id;

  /// {@macro naki_ui.overlay_scope}
  const OverlayScope({
    super.key,
    required this.child,
    required this.id,
  });

  @override
  State<OverlayScope> createState() => _OverlayScopeState();
}

class _OverlayScopeState extends State<OverlayScope> {
  // determines if there is an AppBar or Scaffold ancestor
  bool _canRegister = false;

  @override
  void initState() {
    super.initState();

    _canRegister =
        AppScope.of(context) != null || ScaffoldScope.of(context) != null;

    if (_canRegister) {
      _OverlayScopeRegistry.register(component.id, component.child);
    }
  }

  @override
  void dispose() {
    if (_canRegister) _OverlayScopeRegistry.unregister(component.id);
    super.dispose();
  }

  @override
  void didUpdateComponent(OverlayScope oldComponent) {
    super.didUpdateComponent(oldComponent);

    if (!_canRegister) {
      _canRegister =
          AppScope.of(context) != null || ScaffoldScope.of(context) != null;
    }

    if (!_canRegister) return;

    if (oldComponent.id != component.id) {
      _OverlayScopeRegistry.unregister(oldComponent.id);
      _OverlayScopeRegistry.register(component.id, component.child);
    } else if (oldComponent.child != component.child) {
      _OverlayScopeRegistry.register(component.id, component.child);
    }
  }

  @override
  Component build(BuildContext context) {
    return !_canRegister ? component.child : const SizedBox();
  }
}
