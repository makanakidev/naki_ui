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

Use `drawer` for modal navigation and `sideBar` for persistent navigation. Descendants can obtain `ScaffoldState` with `Scaffold.maybeOf(context)` and call `openDrawer`, `closeDrawer`, or `toggleDrawer`. Supply page-specific `SEO` when metadata differs from the application root.

## `BottomNavigationBarType` Enum Variants

| Enum Variant | Description |
| --- | --- |
| `BottomNavigationBarType.frostedGlass` | The bottom navigation bar has an iOS-style frosted glass effect, is elevated, centered on the screen, and has a smaller width than the screen width. |
| `BottomNavigationBarType.floating` | The bottom navigation bar is elevated, centered on the screen, and has a smaller width than the screen width. |
| `BottomNavigationBarType.fixed` | The bottom navigation bar is fixed to the bottom of the screen and has the full width of the screen. |
