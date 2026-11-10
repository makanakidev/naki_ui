# Naki UI

Naki UI is a Material-inspired library of 80+ components for building fast,
responsive web apps with [Jaspr](https://jaspr.site). If you know Flutter, you
already know most of it: `Scaffold`, `Column`, `ListView`, `showDialog` and
friends work the way you expect, rendered as plain HTML and CSS.

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/makanakidev/naki_ui/main/assets/logo-dark.jpg">
    <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/makanakidev/naki_ui/main/assets/logo-light.jpg">
    <img alt="Naki UI Logo" src="https://raw.githubusercontent.com/makanakidev/naki_ui/main/assets/logo-dark.jpg" width="400">
  </picture>
</p>

<p align="center">
  <a href="https://docs.page/makanakidev/naki_ui"><strong>Documentation</strong></a> &nbsp;&bull;&nbsp;
  <a href="https://makanakidev.github.io/naki_ui"><strong>Live Demo</strong></a>
</p>

## Features

- 🧱 **Flutter-style API:** Compose `Scaffold`, `Column`, `Row`, `Stack`,
  `ListView`, `Card` and 80+ more components with the names and arguments you
  already know.
- 💬 **Overlays without boilerplate:** `showDialog`, `showModalBottomSheet` and
  `showSnackbar` return results like Flutter's, with Flutter-matched
  transitions.
- 🎨 **Theming:** Light, dark and system modes, color seeds, design tokens as
  CSS variables, and a smooth theme switch.
- 🪟 **Glass surfaces:** Frosted and liquid glass navigation bars, glass cards
  and dialogs, with fallbacks for reduced transparency and higher contrast.
- 📱 **Mobile-first:** Every component respects safe areas and Safari's
  collapsing toolbars, and responsive builders work with pure CSS.
- ⚡ **Server and static rendering:** Purely visual components render on the
  server with zero JavaScript; interactive subtrees hydrate under `@client`.

---

## Installation

```yaml
dependencies:
  jaspr: ^0.23.5
  naki_ui: ^1.0.7
```

```shell
dart pub get
```

Naki UI has three entry points:

| Import                           | What it gives you                                                 |
| :------------------------------- | :---------------------------------------------------------------- |
| `package:naki_ui/naki_ui.dart`   | Components and the `show*` overlay functions                      |
| `package:naki_ui/theme.dart`     | Theme data, `TextStyle`, `EdgeInsets`, `Gradient` and styling     |
| `package:naki_ui/framework.dart` | Controllers, gestures, enums, `PlatformData` and lifecycle mixins |

---

## Quick start

Wrap your app in `NakiApp` (or `NakiApp.router` for multiple routes). It sets up
the theme, document metadata and the overlay layer that `showDialog` and
friends render into.

```dart
import 'package:jaspr/dom.dart'; // Color
import 'package:jaspr/jaspr.dart';
import 'package:naki_ui/framework.dart';
import 'package:naki_ui/naki_ui.dart';
import 'package:naki_ui/theme.dart';

@client
class App extends StatelessComponent {
  const App({super.key});

  @override
  Component build(BuildContext context) {
    return NakiApp(
      themeMode: ThemeMode.system,
      lightTheme: const LightThemeData(
        colorSeed: ColorSeed(primary: Color('#0f766e')),
      ),
      seo: const SEO(title: 'My App'),
      home: Scaffold(
        appBar: const AppBar(titleText: 'Naki UI'),
        body: Column(
          spacing: 16,
          children: [
            const Heading('Welcome'),
            Button.text('Get started', onTap: () => print('Tapped')),
          ],
        ),
      ),
    );
  }
}
```

With routing, pass `routes` from `jaspr_router` instead of `home`:

```dart
NakiApp.router(
  routes: [
    Route(path: '/', builder: (context, state) => const HomePage()),
    Route(path: '/settings', builder: (context, state) => const SettingsPage()),
  ],
)
```

> [!IMPORTANT]
> In Jaspr `static` or `server` mode, mark the top of each interactive subtree
> with `@client`. Event handlers, overlays, controllers and theme switching only
> work inside one. Arguments that cross the boundary must be serializable, so
> don't pass functions or components into a `@client` component.

---

## Dialogs, bottom sheets and snackbars

Show an overlay from any `BuildContext` below a `NakiApp` or `Scaffold`. No
controller, no state, and the future completes with the value it closed with:

```dart
// A dialog that returns the button the user picked.
final delete = await showDialog<bool>(
  context: context,
  builder: (context) => Dialog(
    title: 'Delete item?',
    barrierDismissible: true,
    actions: [
      Button.text('Cancel', onTap: () => closeDialog(context, false)),
      Button.text('Delete', onTap: () => closeDialog(context, true)),
    ],
  ),
);

// A modal bottom sheet: the builder returns its content.
final target = await showModalBottomSheet<String>(
  context: context,
  builder: (context) => Column(
    children: [
      Button.text('Messages', onTap: () => closeModalBottomSheet(context, 'messages')),
      Button.text('Mail', onTap: () => closeModalBottomSheet(context, 'mail')),
    ],
  ),
);

// A snackbar. Showing another replaces it; closeSnackbar() closes it early.
showSnackbar(context, const Snackbar(content: NakiText('Saved')));
```

Both futures complete with `null` when the barrier or `Escape` dismisses the
overlay. Pass the builder's `context` to `closeDialog` and
`closeModalBottomSheet`, not the page's.

For an overlay that lives in your component tree, pass an `OverlayController`
instead:

```dart
final controller = OverlayController();

Column(
  children: [
    Button.text('Open', onTap: controller.open),
    Dialog(controller: controller, title: 'Hello'),
  ],
)
```

`Drawer`, `Popover` and `Tooltip` complete the overlay set. Popovers and
tooltips flip and slide to stay on screen and clear of the app bars.

---

## Theming

Pick colors with a seed, then switch modes from anywhere:

```dart
NakiApp(
  themeMode: ThemeMode.system,
  cacheThemeMode: true, // remembers the user's choice
  lightTheme: const LightThemeData(colorSeed: ColorSeed(primary: Color('#0f766e'))),
  darkTheme: const DarkThemeData(colorSeed: ColorSeed(primary: Color('#14b8a6'))),
  home: const HomePage(),
)

// Anywhere below it:
Button.text('Toggle theme', onTap: context.toggleTheme);
context.setTheme(ThemeMode.dark);
final text = context.textColor; // typed shortcuts for theme tokens
```

Wrap a subtree in `NakiThemeProvider` to give it a different theme.

### Glass

```dart
Card.glass(child: NakiText('Frosted card'));

Dialog(controller: controller, glass: true, title: 'Glass dialog');

BottomNavigationBar(
  type: BottomNavigationBarType.liquidGlass, // or frostedGlass
  items: const [
    BottomNavigationBarItem(icon: LucideIcons.icon_house, label: 'Home'),
    BottomNavigationBarItem(icon: LucideIcons.icon_search, label: 'Search'),
  ],
)
```

Tune them with the `glassTint`, `glassRim`, `glassBlur` and
`bottomNavbarGlass*` theme properties. Liquid glass bends the content behind
it in Chromium and falls back to frosted glass elsewhere.

---

## Layout and scrolling

`Column` and `Row` take a `spacing` argument, so you rarely need spacers:

```dart
Column(
  spacing: 16,
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [Heading('Title'), NakiText('Body')],
)
```

`ListView.builder` and `GridView.builder` render large collections in batches:

```dart
ListView.builder(
  itemCount: 1000,
  initialItemCount: 24,
  loadMoreItemCount: 24,
  itemBuilder: (context, index) => NakiText('Item $index'),
)
```

`Scaffold` places its `AppBar`, `BottomNavigationBar`, `Drawer` and `Sidebar`
inside the device's safe areas, and keeps them there while Safari's toolbar
collapses.

---

## Forms and inputs

`TextField`, `FormBuilder`, `AutoCompleteField`, `SegmentedInput` (PINs and
one-time codes), `Checkbox`, `RadioButton`, `Switch`, `Slider`, `Dropdown` and
`Calendar`, all with validation built in. `Calendar` picks dates, times or
ranges:

```dart
Calendar(
  id: 'trip-dates',
  type: CalendarType.range,
  rangeValidator: (days) => days == null ? 'Select your dates' : null,
  onSelectedRange: (days) => print('${days.first} to ${days.last}'),
)
```

---

## Responsive layouts

`ResponsiveBuilder` swaps layouts with CSS media queries, so it renders on the
server with no layout shift:

```dart
ResponsiveBuilder(
  mobile: const MobileNav(),
  tablet: const TabletNav(),
  desktop: const DesktopNav(),
)
```

Use `BreakPointWrapper(minWidth: 640, maxWidth: 1024, child: ...)` for custom
ranges, `MediaQueryProvider` to measure an element, and `PlatformData()` for
the OS, browser and form factor.

---

## Agent skills

Naki UI ships skills that teach coding agents its API. Activate the CLI and
install them for your agent:

```shell
dart pub global activate naki_ui
naki_ui skills --claude-code   # or --cursor, --antigravity, --copilot, ...
```

It installs `naki-ui-fundamentals`, `naki-ui-framework` and `naki-ui-theming`,
plus the companion Jaspr skills (skip them with `--no-jaspr`).

<details>
<summary><b>Supported agents and CLI options</b></summary>

<br>

| Agent              | CLI Flag                    | Option (`--agent`) | Destination Directory |
| :----------------- | :-------------------------- | :----------------- | :-------------------- |
| **Antigravity**    | `--antigravity`             | `antigravity`      | `.agents/skills`      |
| **Cursor**         | `--cursor`                  | `cursor`           | `.cursor/skills`      |
| **Claude Code**    | `--claude-code`, `--claude` | `claude-code`      | `.claude/skills`      |
| **Cline**          | `--cline`                   | `cline`            | `.cline/skills`       |
| **Codex**          | `--codex`                   | `codex`            | `.agents/skills`      |
| **GitHub Copilot** | `--copilot`                 | `copilot`          | `.github/skills`      |
| **Command Code**   | `--command-code`            | `command-code`     | `.commandcode/skills` |
| **OpenCode**       | `--opencode`                | `opencode`         | `.opencode/skills`    |
| **Continue**       | `--continue`                | `continue`         | `.continue/skills`    |
| **Windsurf**       | `--windsurf`                | `windsurf`         | `.windsurf/skills`    |
| **General**        | `--general`, `--generic`    | `general`          | `.agents/skills`      |

- `--list` / `-l`: List the available skills.
- `--skill <name>`: Install or remove one skill.
- `--target <path>`: Install to a custom directory.
- `--all`: Install for every agent detected in the workspace.
- `--force` / `-f`: Overwrite skills even if unchanged.
- `--dry-run`: Preview the changes.
- `--clean` / `--remove`: Remove installed Naki UI skills.
- `--[no-]jaspr`: Install the companion Jaspr skills (on by default).

</details>

---

## Learn more

- [Documentation](https://docs.page/makanakidev/naki_ui): every component, with
  examples.
- [Live demo](https://makanakidev.github.io/naki_ui): the showcase app from
  `example/`.
- [Changelog](CHANGELOG.md)

## License

MIT. See [LICENSE](LICENSE).
