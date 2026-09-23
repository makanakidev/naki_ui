# Responsive components

Assume the public imports from `references/imports-and-conventions.md`.

## ResponsiveBuilder

Render different component hierarchies across discrete standard breakpoints, or conditionally show a component at a single breakpoint tier.

```dart
ResponsiveBuilder(
  mobile: const Banner(
    severity: BannerType.info,
    primary: NakiText('Download our native mobile application for a faster experience.'),
  ),
)
```

Alternatively, supply `breakpoint` together with `child` to conditionally render only at a specific tier:

```dart
ResponsiveBuilder(
  breakpoint: BreakPoint.md,
  child: const Banner(
    severity: BannerType.info,
    primary: NakiText('Get our mobile app for a better experience.'),
  ),
)
```

Usage notes:

- Either provide `breakpoint` and `child`, or provide at least one breakpoint-specific slot (`mobile`, `largerMobile`, `tablet`, `laptop`, `desktop`).
- Breakpoints map directly to discrete CSS media query ranges:
  - `mobile` / `BreakPoint.xs`: `<= 480px` (`.br-xs`)
  - `largerMobile` / `BreakPoint.sm` / `BreakPoint.largerPhone`: `480.02px` to `576px` (`.br-sm`)
  - `tablet` / `BreakPoint.md` / `BreakPoint.tablet`: `576.02px` to `768px` (`.br-md`)
  - `laptop` / `BreakPoint.lg` / `BreakPoint.laptop`: `768.02px` to `1024px` (`.br-lg`)
  - `desktop` / `BreakPoint.xl` / `BreakPoint.desktop`: `>= 1024.02px` (`.br-xl`)
- Styles are registered in the `head` of the document. No client-side JavaScript execution or hydration is required for visibility toggling.
- ResponsiveBuilder wraps elements directly with CSS classes using `.wrapElement()`, avoiding superfluous wrapper DOM nodes.

## BreakPointWrapper

Conditionally display a component within custom pixel thresholds (`minWidth`, `maxWidth`, or both).

```dart
BreakPointWrapper(
  minWidth: 640,
  maxWidth: 1024,
  child: const Card(
    child: NakiText('Visible only on viewports between 640px and 1024px wide.'),
  ),
)
```

Usage notes:

- At least one of `minWidth` or `maxWidth` must be provided.
- When both `minWidth` and `maxWidth` are specified, `minWidth` must be strictly less than `maxWidth`.
- Automatically injects scoped media query styles into the document `<head>` with deterministic IDs (e.g., `m640x1024`, `m640`, `x1024`), ensuring duplicate breakpoint wrappers share identical CSS definitions without style collision.

## BreakPoint

Enum representing standard screen dimension categories.

| Value           | Getter Alias             | Pixels   | CSS Class |
| :-------------- | :----------------------- | :------- | :-------- |
| `BreakPoint.xs` | `BreakPoint.mobile`      | `480.0`  | `br-xs`   |
| `BreakPoint.sm` | `BreakPoint.largerPhone` | `576.0`  | `br-sm`   |
| `BreakPoint.md` | `BreakPoint.tablet`      | `768.0`  | `br-md`   |
| `BreakPoint.lg` | `BreakPoint.laptop`      | `1024.0` | `br-lg`   |
| `BreakPoint.xl` | `BreakPoint.desktop`     | `1200.0` | `br-xl`   |

Use `BreakPoint.from(double width)` to programmatically resolve a width value in pixels to its corresponding `BreakPoint` enum instance.

## CSS-Driven vs. Client-Side Observer

| Feature                  | `ResponsiveBuilder` / `BreakPointWrapper`                   | `MediaQueryProvider`                                           |
| :----------------------- | :---------------------------------------------------------- | :------------------------------------------------------------- |
| **Mechanism**            | Pure CSS Media Queries (`@media`)                           | Browser `ResizeObserver` / Window Events                       |
| **SSR / SSG Compatible** | Yes (Zero layout shift, works with pure static generation)  | Requires `@client` hydration                                   |
| **Performance**          | Instant native browser engine switching                     | Microtask / setState callback update                           |
| **Use Case**             | Hiding/showing layout components, adaptive navbars, drawers | Reading dynamic pixel math, canvas drawing, programmatic logic |
