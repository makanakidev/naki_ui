# Scaffold components

## AppBar

Create a page header with leading navigation, title, and actions.

```dart
AppBar(
  titleText: 'Orders',
  leading: Button.icon(
    LucideIcons.icon_menu,
    attributes: const {'aria-label': 'Open navigation'},
    onTap: () => Scaffold.maybeOf(context)?.openDrawer(),
  ),
  actions: [
    Button.icon(
      LucideIcons.icon_search,
      attributes: const {'aria-label': 'Search orders'},
      onTap: openSearch,
    ),
  ],
)
```

Use either `titleText` with `titleStyle` or a custom `title` component. Keep icon actions labeled. Set `removeShadow` for a flat header.

Inside `Scaffold.appBar`, `fixed` (default `true`) pins the bar to the top and starts the body below it; `fixed: false` lets it scroll away with the page. `blurBackground` (default `true`) gives a pinned bar a translucent, frosted background and is ignored when `fixed` is `false`. Both are ignored outside `Scaffold.appBar`.

```dart
Scaffold(
  appBar: const AppBar(titleText: 'Article', fixed: false),
  body: const ArticleBody(),
)
```

## BottomNavigationBar

Display two or more primary destinations.

```dart
BottomNavigationBar(
  selectedIndex: currentIndex,
  type: BottomNavigationBarType.fixed,
  items: const [
    BottomNavigationBarItem(
      icon: LucideIcons.icon_house,
      label: 'Home',
      tooltip: 'Open home',
    ),
    BottomNavigationBarItem(
      icon: LucideIcons.icon_settings,
      label: 'Settings',
      tooltip: 'Open settings',
    ),
  ],
  onTap: (index) => setState(() => currentIndex = index),
)
```

At least two items are required. Every item needs `label` or `labelComponent`; keep labels visible unless another accessible name remains available. Treat `selectedIndex` as controlled state and update navigation in `onTap`.

## Scaffold

Compose the page shell.

```dart
Scaffold(
  seo: const SEO(
    title: 'Orders',
    description: 'Review recent customer orders.',
  ),
  appBar: AppBar(
    titleText: 'Orders',
    leading: Button.text(
      'Menu',
      onTap: () => Scaffold.maybeOf(context)?.openDrawer(),
    ),
  ),
  drawer: const Drawer(
    semanticLabel: 'Primary navigation',
    child: NakiText('Navigation'),
  ),
  sideBar: const Sidebar(
    semanticLabel: 'Section navigation',
    child: NakiText('Sections'),
  ),
  body: const OrdersPage(),
  floatingActionButton: Button.text('New order', onTap: createOrder),
  bottomNavigationBar: BottomNavigationBar(
    items: const [
      BottomNavigationBarItem(
        icon: LucideIcons.icon_house,
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: LucideIcons.icon_settings,
        label: 'Settings',
      ),
    ],
    currentIndex: _currentIndex,
    type: BottomNavigationBarType.floating,
    onTap: (index) => setState(() => _currentIndex = index),
  ),
)
```

Use `Drawer` for modal navigation and `Sidebar` for persistent navigation. Descendants can obtain `ScaffoldState` with `Scaffold.maybeOf(context)` and call `openDrawer`, `closeDrawer`, or `toggleDrawer`. Supply page-specific `SEO` when metadata differs from the application root.

The body ends above the bottom navigation bar by default. Set `extendBody: true` to scroll content behind a floating or frosted-glass bar.

A vertical scroll view that is the body's direct child, or a page of a `PageView` body, adds the app bar and bottom bar heights to its own `padding`, so its content scrolls behind the bars and still ends clear of them. Any other body keeps the bars' heights as body padding, so nothing is hidden behind them.

### Frosted glass

`BottomNavigationBarType.frostedGlass` blurs the content behind a pill-shaped bar, adds a light rim and depth, and slides a glass droplet between its equally wide tiles. Scroll content behind it with `extendBody: true` to see the effect.

Tune the material with these `ComponentScheme` fields or their CSS variables:

| `ComponentScheme` field    | CSS variable                         | Default                |
| -------------------------- | ------------------------------------ | ---------------------- |
| `bottomNavbarGlassTint`    | `--naki-bottom-navbar-glass-tint`    | `15%` (`30%` in dark)  |
| `bottomNavbarGlassRim`     | `--naki-bottom-navbar-glass-rim`     | `100%` (`40%` in dark) |
| `bottomNavbarGlassDroplet` | `--naki-bottom-navbar-glass-droplet` | `0%` (`50%` in dark)   |
| `bottomNavbarGlassBlur`    | `--naki-bottom-navbar-glass-blur`    | `5px`                  |

The bar falls back to a solid or near-opaque surface for `prefers-reduced-transparency`, `prefers-contrast: more` and `forced-colors`.

### Liquid glass

`BottomNavigationBarType.liquidGlass` is a frosted glass bar that bends the content behind its edges and selection droplet using an SVG displacement filter:

```dart
BottomNavigationBar(
  type: BottomNavigationBarType.liquidGlass,
  items: items,
)
```

`bottomNavbarGlassRefraction` on `ComponentScheme` scales the displacement in percent. The default is `100`, and `0` leaves the bar frosted. It is a theme value rather than a CSS variable because an SVG filter cannot read one.

Refraction needs a Chromium browser. Other browsers, server-rendered markup and the accessibility fallbacks above show the frosted glass bar. While refraction runs, the filter replaces `bottomNavbarGlassBlur`. Prefer it for a single bar: the filter redraws on every scroll frame.

## `BottomNavigationBarType` Enum Variants

| Enum Variant                           | Description                                                                                                                                          |
| -------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| `BottomNavigationBarType.frostedGlass` | The bottom navigation bar has an iOS-style frosted glass effect, is elevated, centered on the screen, and has a smaller width than the screen width. |
| `BottomNavigationBarType.liquidGlass`  | A `frostedGlass` bar that refracts the content behind its edges and selection droplet in Chromium browsers.                                          |
| `BottomNavigationBarType.floating`     | The bottom navigation bar is elevated, centered on the screen, and has a smaller width than the screen width.                                        |
| `BottomNavigationBarType.fixed`        | The bottom navigation bar is fixed to the bottom of the screen and has the full width of the screen.                                                 |
