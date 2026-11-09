import 'package:jaspr/dom.dart' show Styles;
import 'package:jaspr/jaspr.dart';

import '../framework/inherited.dart';
import '../utilities/constants.dart';
import '../utilities/extensions.dart';

// /////////////////////////////////////////////////////////////////////////////
// OVERLAY CONTROLLER & UTILITIES
// /////////////////////////////////////////////////////////////////////////////

/// A singleton registry of snackbar controllers used to keep
/// track of all the snackbars in the application.
class SnackbarRegistry {
  static OverlayController? _currentController;

  /// Notifies the registry that a snackbar has opened and automatically
  /// closes any previously active snackbar.
  static void onOpen(OverlayController controller) {
    if (_currentController != null && _currentController != controller) {
      closeCurrent();
    }
    _currentController = controller;
  }

  /// Notifies the registry that a snackbar has closed.
  static void onClose(OverlayController controller) {
    if (_currentController == controller) _currentController = null;
  }

  /// Closes the snackbar that is currently open, if any.
  static void closeCurrent() => _currentController?.close();
}

/// Controls an overlay component (Dialog, Drawer, BottomSheet,
/// Snackbar, Tooltip, Alert), managing its open/closed visibility
/// state and listener notifications.
class OverlayController {
  bool _isOpen;

  /// Creates a new [OverlayController].
  OverlayController({bool isOpen = false}) : _isOpen = isOpen;

  /// Whether the target overlay is currently open / visible.
  bool get isOpen => _isOpen;

  /// Stores listener callbacks for state change notifications.
  final List<VoidCallback> _listeners = [];

  /// Adds a listener callback triggered on state changes.
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  /// Removes a registered listener callback.
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  /// Notifies all registered listeners of a state change.
  void notifyListeners() {
    for (final listener in List<VoidCallback>.of(_listeners)) {
      if (_listeners.contains(listener)) listener();
    }
  }

  /// Opens / shows the target overlay.
  void open() {
    if (!_isOpen) {
      _isOpen = true;
      notifyListeners();
    }
  }

  /// Closes / hides the target overlay.
  void close() {
    if (_isOpen) {
      _isOpen = false;
      notifyListeners();
    }
  }

  /// Toggles the overlay between open and closed states.
  void toggle() {
    if (_isOpen) {
      close();
    } else {
      open();
    }
  }

  /// Clears all registered listeners.
  void dispose() {
    _listeners.clear();
  }
}

// /////////////////////////////////////////////////////////////////////////////
// OPEN / CLOSE UTILITIES
// /////////////////////////////////////////////////////////////////////////////

/// Utility class for controlling overlay components
class OverlayState {
  /// Opens the overlay bound to the provided [controller].
  static void open(OverlayController controller) {
    controller.open();
  }

  /// Closes the overlay bound to the provided [controller].
  static void close(OverlayController controller) {
    controller.close();
  }

  /// Toggles the open/closed state of the overlay bound to [controller].
  static void toggle(OverlayController controller) {
    controller.toggle();
  }

  /// Shows the overlay bound to [controller].
  static void show(OverlayController controller) {
    controller.open();
  }

  /// Hides the overlay bound to [controller].
  static void hide(OverlayController controller) {
    controller.close();
  }
}

// /////////////////////////////////////////////////////////////////////////////
// OVERLAY SCOPE & REGION
// /////////////////////////////////////////////////////////////////////////////

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
    return !_canRegister ? component.child : const .empty();
  }
}

// /////////////////////////////////////////////////////////////////////////////
// OVERLAY HOST
// /////////////////////////////////////////////////////////////////////////////

/// Renders the overlays shown with `showSnackbar` and `showDialog` next to
/// its [child], so they keep the theme and `Scaffold` context of the place
/// they are shown from.
///
/// `NakiApp` and `Scaffold` include one; the closest one shows the overlay.
class OverlayHost extends StatefulComponent {
  /// The content the overlays are shown next to.
  final Component child;

  /// Creates an [OverlayHost] around [child].
  const OverlayHost({super.key, required this.child});

  /// The closest [OverlayHostState] above [context], if any.
  static OverlayHostState? maybeOf(BuildContext context) =>
      context.dependOnInheritedComponentOfExactType<_OverlayHostScope>()?.state;

  @override
  State<OverlayHost> createState() => OverlayHostState();
}

class OverlayHostState extends State<OverlayHost> {
  final _entries = <int, Component>{};
  int _nextId = 0;

  /// Shows [overlay] until [controller] closes, then removes it once its
  /// [exitDuration] exit animation has played.
  ///
  /// [onClosed] runs once, as soon as [controller] closes.
  void show(
    Component overlay, {
    required OverlayController controller,
    Duration exitDuration = const Duration(milliseconds: 200),
    VoidCallback? onClosed,
  }) {
    final id = _nextId++;

    void listener() {
      if (controller.isOpen) return;

      controller.removeListener(listener);
      onClosed?.call();

      Future.delayed(exitDuration, () {
        if (mounted) setState(() => _entries.remove(id));
      });
    }

    controller.addListener(listener);

    setState(() {
      _entries[id] = OverlayEntryScope(
        key: ValueKey('naki-overlay-$id'),
        controller: controller,
        child: overlay,
      );
    });
  }

  @override
  Component build(BuildContext context) {
    return _OverlayHostScope(
      state: this,
      child: .fragment([
        component.child,
        // portal for modals
        const OverlayRegion(),
        // injected snackbars and modals
        .element(
          tag: 'naki-overlay-host',
          styles: const Styles(raw: {'display': 'contents'}),
          children: _entries.values.toList(),
        ),
      ]),
    );
  }
}

class _OverlayHostScope extends InheritedComponent {
  final OverlayHostState state;

  const _OverlayHostScope({required this.state, required super.child});

  @override
  bool updateShouldNotify(_OverlayHostScope oldComponent) =>
      state != oldComponent.state;
}

/// Hands the controller of an overlay shown by an [OverlayHost] to the
/// `Snackbar` or `Dialog` inside it, so they need no controller of their own.
class OverlayEntryScope extends InheritedComponent {
  /// Controller of the overlay below this scope.
  final OverlayController controller;

  /// Creates an [OverlayEntryScope].
  const OverlayEntryScope({
    super.key,
    required this.controller,
    required super.child,
  });

  /// The controller of the overlay [context] belongs to, if it was shown by
  /// an [OverlayHost].
  static OverlayController? maybeOf(BuildContext context) => context
      .dependOnInheritedComponentOfExactType<OverlayEntryScope>()
      ?.controller;

  @override
  bool updateShouldNotify(OverlayEntryScope oldComponent) =>
      controller != oldComponent.controller;
}

/// {@template naki_ui.overlay_region}
/// A component that acts as a DOM portal container where all active [OverlayScope]
/// child components (modals, dialogs, drawers, tooltips) are rendered.
///
/// > **Note:** `NakiApp` and `Scaffold` automatically include an `OverlayRegion`.
/// > You only need to declare this manually if you are building a custom
/// > application shell without `NakiApp` or `Scaffold`.
/// {@endtemplate}
class OverlayRegion extends StatelessComponent {
  /// {@macro naki_ui.overlay_region}
  const OverlayRegion({super.key});

  @override
  Component build(BuildContext context) {
    return _OverlayScopeRegistry.notifier.rebuild((map) {
      return .fragment([
        for (final entry in map.entries)
          .wrapElement(key: ValueKey(entry.key), child: entry.value),
      ]);
    });
  }
}
