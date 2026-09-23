---
name: naki-ui-fundamentals
description: Use when building, editing, reviewing, or troubleshooting Jaspr interfaces with Naki UI components, including application setup, layout, text, inputs, selection, overlays, scrolling, painting, responsive behavior, and async rendering through package:naki_ui/naki_ui.dart.
metadata:
  version: "1.0.1"
  author: "makanakidev"
---

# Naki UI Fundamentals

Build interfaces with Naki UI's public component APIs and established composition patterns.

## Start with the public entrypoints

```dart
import 'package:jaspr/dom.dart' hide Padding, Table, Transform, Visibility;
import 'package:jaspr/jaspr.dart';
import 'package:naki_ui/framework.dart';
import 'package:naki_ui/naki_ui.dart';
import 'package:naki_ui/theme.dart';
```

Import `package:jaspr_router/jaspr_router.dart` only when configuring `NakiApp.router`. Never import `package:naki_ui/src/...` from an application.

## Follow the component workflow

1. Identify the UI role and find the component in [component-index.md](references/component-index.md).
2. Read the linked category reference before writing the component. Each reference documents constructors, composition constraints, examples, and common mistakes.
3. Use Naki UI's typed component, framework, and theme APIs before reaching for raw attributes or CSS strings.
4. Return one `Component` from every `build(BuildContext context)` method.
5. Put browser-dependent or interactive subtrees inside the appropriate `@client` boundary when using Jaspr static or server mode.
6. Supply stable keys and IDs where identity, form association, DOM lookup, or controller behavior depends on them.
7. Dispose controllers and listeners created by a state object. Do not dispose resources supplied by an ancestor.
8. Format, analyze, and test the resulting application.

## Apply Jaspr component conventions

Jaspr uses a component-based architecture very similar to Flutter's widgets. Concepts like ui composition, architecture and state management are transferable.

- **StatelessComponent**: For components that don't need mutable state. You must override `Component build(BuildContext context)`.
- **StatefulComponent**: For components with mutable state. Requires an associated `State` class. The state has lifecycle methods like `initState()` and `dispose()`. You must override `Component build(BuildContext context)` in the state class.
- **InheritedComponent**: For propagating context or state efficiently down the component tree.
- Building UIs in Jaspr requires you to return a single `Component` from `build()`.
- You MUST NOT use `Iterable<Component> build(BuildContext context) sync*` (legacy code).
- You MUST use dot-shorthands instead of capitalized component names for fragments and empty nodes:
  - Use `.fragment([...])` (Do NOT use `Fragment([...])` or `fragment([...])`).
  - Use `.empty()` to return an empty space safely.

**Example Usage:**

```dart
import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';
import 'package:naki_ui/naki_ui.dart';

class MyComponent extends StatelessComponent {
  const MyComponent({super.key});

  @override
  Component build(BuildContext context) {
    return .fragment([
      // Use Naki UI components here instead of HTML components
      Container(),
      Card()
    ]);
  }
}
```

## Apply Naki UI conventions

- Pass child lists through `children` and single content through `child`.
- Use `NakiText` for ordinary text and `RichText` with spans for mixed inline content.
- Use `Button` for actions and `Link` for navigation/routing.
- Set `InputDecoration.labelText` on `TextField`, `AutoCompleteField`, `SegmentedInput`, and `Calendar`; these components render and associate `Label` internally.
- Set the built-in `label` property on `Checkbox`, `Switch`, and `RadioButton`. Do not add a duplicate standalone `Label` beside them.
- Reserve standalone `Label` for a custom control without a built-in label API, and match `fieldId` to the rendered native input ID.
- Use builder collection constructors for large or incrementally loaded data sets.
- Constrain nested scroll views explicitly and avoid competing same-axis scroll containers.
- Read active theme values from `context.themeTokens` or context color shortcuts, not from global fallback tokens.
- Prefer semantic labels, visible focus, keyboard behavior, unique IDs, and native form semantics.

## Understand the application boundary

Use `NakiApp` for theme configuration, metadata, default text style, safe-area handling, and an optional application home. Use `NakiApp.router` for router-managed applications. Interactive routing, theme persistence, responsive observation, overlays, and browser lifecycle behavior require client execution.

Read [imports-and-conventions.md](references/imports-and-conventions.md) for complete application, component, hydration, form, styling, and verification examples.

## Load only the component references needed

- Application and responsive setup: [application.md](references/components/application.md)
- Futures and streams: [async.md](references/components/async.md)
- Flex, text, buttons, images, icons, gestures, and banners: [basics.md](references/components/basics.md)
- Rich text and typography helpers: [rich-text.md](references/components/rich-text.md)
- Fields, forms, autocomplete, segmented input, and calendar: [inputs.md](references/components/inputs.md)
- Alignment, sizing, spacing, stacks, cards, and expansion: [layout.md](references/components/layout.md)
- Responsive builder and custom breakpoints: [responsive.md](references/components/responsive.md)
- Dialogs, drawers, sheets, snackbars, tooltips, and popovers: [overlays.md](references/components/overlays.md)
- Opacity, visibility, clipping, decoration, filtering, color, rotation, and transforms: [painting.md](references/components/painting.md)
- App bars, bottom navigation, and scaffold: [scaffold.md](references/components/scaffold.md)
- Lists, grids, pages, carousels, tables, and staggered layouts: [scrolling.md](references/components/scrolling.md)
- Checkbox, switch, slider, radio, and dropdown: [selection.md](references/components/selection.md)

## Verify changes

Run the application's configured checks. Typical commands are:

```sh
dart format <changed-dart-files>
dart analyze
dart test
```

**Important:** When changing hydration, routing, browser lifecycle behavior, overlays, or responsive observation, you must also build or run the Jaspr application.
