# Lifecycle and browser behavior

## Run work after rendering

Use `NakiStatefulMixin` when setup needs a mounted DOM node or browser state.

```dart
class Panel extends StatefulComponent {
  final OverlayController controller;

  const Panel({required this.controller, super.key});

  @override
  State<Panel> createState() => _PanelState();
}

class _PanelState extends State<Panel> with NakiStatefulMixin<Panel> {
  void handleControllerChange() {
    if (mounted) setState(() {});
  }

  @override
  FutureOr<VoidCallback?> afterRender(BuildContext context) {
    final controller = component.controller;
    controller.addListener(handleControllerChange);
    return () => controller.removeListener(handleControllerChange);
  }

  @override
  void didUpdateComponent(Panel oldComponent) {
    super.didUpdateComponent(oldComponent);
    if (oldComponent.controller != component.controller) {
      refreshAfterRender();
    }
  }

  @override
  Component build(BuildContext context) {
    return NakiText('Open: ${component.controller.isOpen}');
  }
}
```

Import `dart:async` for `FutureOr`. Capture the resource used during setup so cleanup removes the listener from the old instance after an update.

## Use NakiStatelessMixin

Use the stateless mixin only when the component has no mutable state but needs post-render setup:

```dart
class AutofocusRegion extends StatelessComponent with NakiStatelessMixin {
  const AutofocusRegion({super.key});

  @override
  FutureOr<VoidCallback?> afterRender(BuildContext context) {
    focusPrimaryControl();
    return releaseFocusResources;
  }

  @override
  Component build(BuildContext context) => const NakiText('Ready');
}
```

The mixin runs on the client after rendering and replaces cleanup when the stateless component updates.

## Observe browser lifecycle

```dart
class _StatusState extends State<Status> {
  final lifecycle = BrowserLifecycleListeners();

  @override
  void initState() {
    super.initState();
    lifecycle.whenVisible = refreshData;
    lifecycle.whenInactive = pausePolling;
    lifecycle.whenConnectivityChanged = handleConnectivity;
    lifecycle.whenSystemThemeChanged = handleSystemTheme;
    lifecycle.whenResized = (height, width, orientation) {
      handleViewport(width, height, orientation);
    };
    lifecycle.register();
  }

  @override
  void dispose() {
    lifecycle.dispose();
    super.dispose();
  }
}
```

Other callbacks cover close, orientation change, page freeze, and resume. Call `observeIdleState` for inactivity and `unobserveIdleState` when stopping it.

## Observe a component

Use a global node key or stable ID:

```dart
lifecycle.observeComponentSize(
  (height, width, orientation) {
    updatePanelLayout(width, height, orientation);
  },
  id: 'analytics-panel',
);

lifecycle.observeComponentVisibility(
  (visible) => setChartActive(visible),
  id: 'analytics-panel',
);
```

Call the matching unobserve method when observation ends early; `dispose()` removes all remaining observers. Use `MediaQueryProvider` when descendant components need inherited responsive data rather than callback-driven state.
