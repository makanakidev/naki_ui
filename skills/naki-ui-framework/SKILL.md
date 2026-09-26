---
name: naki-ui-framework
description: Use when implementing, reviewing, or troubleshooting Naki UI behavior with package:naki_ui/framework.dart, including platform detection, lifecycle mixins, browser listeners, gestures, input events, overlay and scroll controllers, animation curves, scrolling models, shared data models, enums, and debounce utilities.
metadata:
  version: "1.0.2"
  author: "makanakidev"
---

# Naki UI Framework

Use Naki UI's public behavioral APIs while keeping browser resources, state, and controller ownership predictable.

## Import the framework API

```dart
import 'package:jaspr/jaspr.dart';
import 'package:naki_ui/framework.dart';
```

Add `package:naki_ui/naki_ui.dart` for visual components and `package:naki_ui/theme.dart` for styling models. Never import `package:naki_ui/src/...` from application code.

## Follow the workflow

1. Find the API group in [api-map.md](references/api-map.md).
2. Decide whether the resource is owned by component state, an ancestor, or an application service.
3. Create owned controllers, observers, and listener registries once, outside `build`.
4. Register DOM-dependent behavior after rendering and only in a client environment.
5. Replace registrations when their controller, element, or source changes.
6. Remove listeners and dispose owned resources before calling `super.dispose()` unless the API documents another order.
7. Keep values passed into `@client` components serializable when using static or server rendering.
8. Test mounting, updates, repeated registration, and disposal as well as the visible interaction.

## Respect lifecycle contracts

- Mix `NakiStatefulMixin<T>` into `State<T>` when setup requires the rendered DOM. Override `afterRender`, return a cleanup callback, and call `refreshAfterRender()` when a DOM-bound dependency changes.
- Use `NakiStatelessMixin` only for stateless post-render behavior whose cleanup can be replaced whenever the component updates.
- Treat `BrowserLifecycleListeners` as browser-only. Configure callbacks, call `register()`, and always call `dispose()`.
- Guard direct browser operations with the runtime conditions appropriate to the application's Jaspr mode.

Read [lifecycle-and-browser.md](references/lifecycle-and-browser.md) for complete patterns.

## Own controllers deliberately

- Let Naki scrolling components attach and detach supplied `ScrollController` and `PageController` instances.
- Dispose controllers created by the current state. Do not dispose controllers supplied by an ancestor.
- Use `OverlayController` for dialog, drawer, sheet, snackbar, and related open state. `OverlayState` is only a static convenience wrapper around a controller.
- Remove listeners from shared controllers when the listening component is disposed.

Read [controllers.md](references/controllers.md) for overlay, scrolling, paging, physics, grid, and table examples.

## Prefer typed events and models

- Configure interactions with `Gestures`, `GestureRecognizer`, and `InputEvents` rather than untyped event maps when the API supports them.
- Add semantics and keyboard behavior when a gesture makes a non-control interactive.
- Use `DropdownItem`, `SEO`, calendar models, `BottomNavigationBarItem`, table models, and grid delegates rather than parallel application-specific shapes at the component boundary.
- Use a stable tag with static `NakiDebounce.run`, and cancel that tag when the owning feature is disposed.

## Platform detection and environment queries

Access device, browser, and viewport information safely across both client and server (SSR / SSG) environments:

```dart
import 'package:naki_ui/framework.dart';

final platform = PlatformData();

// Device & OS detection
final isApple = platform.isiOS || platform.isMacOS;
final isMobile = platform.isMobile;
final isDesktop = platform.isDesktop;
final deviceName = platform.device; // 'iPhone', 'iPad', 'MacOS', 'Windows', 'Android', 'Linux'

// PWA & Browser environment
final isPWA = platform.isPWA; // Running as an installed Progressive Web App
final isMobileBrowser = platform.isMobileBrowser; // Mobile browser (not running as standalone PWA)

// Viewport dimensions & locale
final width = platform.width;
final height = platform.height;
final locale = platform.language; // e.g. 'en'

// URL & Base Origin
final currentPath = platform.currentUrl; // e.g. '/dashboard'
final baseOrigin = platform.baseUrl; // e.g. 'https://example.com'
```

Read [events-models-and-utilities.md](references/events-models-and-utilities.md) for examples and the public enum map.

## Verify

Format and analyze every Dart change. Add focused tests for cleanup, listener replacement, controller navigation, event mapping, debounce cancellation, and server/client boundary behavior where applicable.
