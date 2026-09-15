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
  sideBar: const Drawer.sidebar(
    semanticLabel: 'Section navigation',
    child: NakiText('Sections'),
  ),
  body: const OrdersPage(),
  floatingActionButton: Button.text('New order', onTap: createOrder),
  bottomNavigationBar: navigationBar,
)
```

Use `drawer` for modal navigation and `sideBar` for persistent navigation. Descendants can obtain `ScaffoldState` with `Scaffold.maybeOf(context)` and call `openDrawer`, `closeDrawer`, or `toggleDrawer`. Supply page-specific `SEO` when metadata differs from the application root.
