# Framework API map

Import every API in this reference from `package:naki_ui/framework.dart`.

| Area | Public APIs |
| --- | --- |
| Lifecycle | `NakiStatelessMixin`, `NakiStatefulMixin<T>`, `BrowserLifecycleListeners` and lifecycle callback typedefs |
| Animation | `Curves` presets with `build(double)` |
| Events | `Gestures`, `Events`, `GestureRecognizer`, `InputEvents` |
| Overlays | `OverlayController`, `OverlayState` |
| Scrolling | `ScrollController`, `PageController`, `ScrollPhysics` and its concrete variants |
| Grids | `SliverGridDelegateWithFixedCrossAxisCount`, `SliverGridDelegateWithMaxCrossAxisExtent` |
| Tables | `TableBorder`, `TableRow`, `FlexColumnWidth`, `FixedColumnWidth`, `IntrinsicColumnWidth`, `FractionColumnWidth` |
| Shared models | `DropdownItem<T>`, `InlineSpan`, `SEO`, `CalendarDay`, `CalendarMonth`, `BottomNavigationBarItem` |
| Utilities | `NakiDebounce` |
| Enums | Placement, aspect ratio, type style, direction, orientation, decoration, flex, fit, alignment, autofill, baseline, scrolling, carousel, table, theme, feedback, overlay position, segmented input, validation, calendar, brightness, navigation, and file type enums |

The public barrel intentionally hides internal layout mixins, text scopes, snackbar registries, and selected internal enums. Do not bypass that boundary with a `src` import.

## Curves

Available presets include `Curves.easeInOut`, `linear`, `easeIn`, `easeOut`, `easeInOutBack`, `easeOutBack`, `bounceIn`, and `bounceOut`.

```dart
final easedProgress = Curves.easeInOut.build(rawProgress);
```

Pass values in the normalized animation range expected by the consuming API.

## Reference routing

- Lifecycle and browser observers: [lifecycle-and-browser.md](lifecycle-and-browser.md)
- Overlay, scroll, page, physics, grid, and table APIs: [controllers.md](controllers.md)
- Events, data models, enums, and debounce: [events-models-and-utilities.md](events-models-and-utilities.md)
