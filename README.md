# Naki UI

Naki UI is a Material-inspired library of 80+ reusable UI components and design
utilities for building fast, responsive web applications with Jaspr.

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

- 🎨 **Design tokens and theming:** Light, dark, and system theme modes, custom
  token overrides, and CSS variable management.
- 📦 **Component library:** Layouts, accordions, cards, buttons, inputs,
  selection controls, overlays, navigation bars, responsive layout builders, and asynchronous builders.
- 🚀 **Built for Jaspr:** Jaspr components with type-safe CSS-in-Dart styling
  and DOM event binding.
- 🧩 **Modular barrel exports:** Separate entry points for UI components,
  theming, and framework utilities.

---

## Installation

Add `naki_ui` to your `pubspec.yaml`:

```yaml
dependencies:
  jaspr: ^0.23.4
  naki_ui: ^1.0.2
```

Then fetch the dependencies:

```shell
dart pub get
```

### Agent skills

Naki UI publishes consumer-facing agent skills with the package. You can globally activate naki_ui CLI using `dart pub global activate naki_ui`, then install skills as follows:

```shell
naki_ui skills --antigravity
naki_ui skills --cursor
naki_ui skills --claude-code

# Or specify with the --agent option:
naki_ui skills --agent antigravity

# Show help and all available options:
naki_ui --help
naki_ui -h
naki_ui skills --help
```

The package provides `naki-ui-fundamentals`, `naki-ui-framework`, and
`naki-ui-theming` skills. The fundamentals skill includes a component index and
detailed usage resources for every exported UI component.

`naki_ui skills` also automatically detects and installs companion Jaspr skills
(`jaspr-fundamentals`, `jaspr-styling`, `jaspr-convert-html`,
`jaspr-pre-rendering-and-hydration`, and `jaspr-js-interop`) if they are missing
from your target agent directory. Use `--no-jaspr` to skip Jaspr skills installation.

<details>
<summary><b>View all supported AI agents & CLI options</b></summary>

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

**Additional CLI Options:**

- `--list` / `-l`: List all available Naki UI skills and their descriptions.
- `--skill <name>`: Install or remove only a specific skill by name (e.g. `naki-ui-theming`).
- `--target <path>`: Custom destination directory for skills.
- `--all`: Install skills for all detected agents in the workspace.
- `--force` / `-f`: Force overwrite existing skills even if unchanged.
- `--dry-run`: Preview changes without modifying the filesystem.
- `--clean` / `--remove`: Remove installed Naki UI skills from the target agent directory.
- `--[no-]jaspr`: Toggle automatic companion Jaspr skills installation (defaults to on).

</details>

---

## Quick start

Wrap your application in `NakiApp`, or use `NakiApp.router` for applications
with multiple routes. It configures design-token injection, document metadata,
routing, and the default theme. Use `NakiThemeProvider` in a descendant subtree
when you need a localized theme override.

> [!IMPORTANT]
> **Understanding `@client` hydration boundaries**
>
> - **When to use `@client`:**
>   - In Jaspr `static` or `server` mode, annotate the uppermost component of an
>     interactive subtree, such as the root `App`, an interactive feature, or a
>     single-page application.
>   - A client boundary is required for browser-side interactivity, including DOM
>     event listeners (`onTap`, `onChange`), interactive overlays (`Dialog`,
>     `Snackbar`, `BottomSheet`, `Drawer`), controller hooks, dynamic theme
>     switching (`context.toggleTheme()`), and single-page routing
>     (`NakiApp.router`).
> - **When not to use `@client`:**
>   - **Static, content-first pages:** Marketing pages, articles, documentation,
>     and non-interactive layouts can render entirely on the server for a zero-JS
>     payload and fast initial paint.
>   - **Descendants of an interactive subtree:** Do not annotate a child when an
>     ancestor already defines the client boundary. Jaspr hydrates the descendant
>     tree from that boundary.
>   - **Server-only asynchronous data loaders:** Components that fetch data before
>     HTML delivery, such as `AsyncStatelessComponent` and `AsyncBuilder`, must
>     remain server-only.
>   - **Components with non-serializable parameters:** Constructor fields that
>     cross the boundary must be serializable, such as primitives, lists, maps,
>     or encodable classes. Do not pass functions or component instances across
>     the boundary.

### 1. Application without routing (`NakiApp`)

```dart
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:naki_ui/framework.dart';
import 'package:naki_ui/naki_ui.dart';
import 'package:naki_ui/theme.dart';

@client // Enables client-side hydration and browser APIs.
class App extends StatelessComponent {
  const App({super.key});

  @override
  Component build(BuildContext context) {
    return NakiApp(
      // Theme configuration and local-storage persistence.
      themeMode: ThemeMode.system,
      cacheThemeMode: true,
      lightTheme: const LightThemeData(
        colorSeed: ColorSeed(primary: Color('#0f766e')),
      ),
      darkTheme: const DarkThemeData(
        colorSeed: ColorSeed(primary: Color('#14b8a6')),
      ),

      // SEO and document metadata.
      seo: const SEO(
        title: 'My Jaspr Application',
        description: 'A modern web application built with Jaspr and Naki UI.',
        keywords: ['jaspr', 'naki_ui', 'material', 'web'],
      ),
      favicon: 'https://example.com/favicon.png',

      home: Scaffold(
        appBar: const AppBar(titleText: 'Naki UI'),
        body: Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 16,
            children: [
              NakiText(
                'Welcome to Naki UI!',
                style: TextStyle(
                  fontSize: Dim.px(28),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Button(
                onTap: () => print('Button tapped!'),
                child: const NakiText('Get Started'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 2. Application with routing (`NakiApp.router`)

```dart
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'package:naki_ui/framework.dart';
import 'package:naki_ui/naki_ui.dart';
import 'package:naki_ui/theme.dart';

@client // Required for client-side single-page routing.
class RoutedApp extends StatelessComponent {
  const RoutedApp({super.key});

  @override
  Component build(BuildContext context) {
    return NakiApp.router(
      // Theme configuration and local-storage persistence.
      themeMode: ThemeMode.system,
      cacheThemeMode: true,
      lightTheme: const LightThemeData(
        colorSeed: ColorSeed(primary: Color('#0f766e')),
      ),
      darkTheme: const DarkThemeData(
        colorSeed: ColorSeed(primary: Color('#14b8a6')),
      ),

      // SEO configuration.
      seo: const SEO(
        title: 'My Routed App',
        description:
            'A single-page application powered by Jaspr Router and Naki UI.',
        keywords: ['jaspr', 'naki_ui', 'spa', 'router'],
      ),

      routes: [
        Route(
          path: '/',
          name: 'home',
          builder: (context, state) => const HomePage(),
        ),
        Route(
          path: '/settings',
          name: 'settings',
          builder: (context, state) => const SettingsPage(),
        ),
      ],
    );
  }
}
```

---

## Library architecture and barrel imports

Naki UI provides three focused entry points for predictable API discovery and
clean code organization.

### 1. UI component barrel

Import all reusable Naki UI components:

```dart
import 'package:naki_ui/naki_ui.dart';
```

This barrel includes Flutter-style compositional components such as `NakiApp`,
`ResponsiveBuilder`, `BreakPointWrapper`, `Card`, `ExpansionPanelList`, `ExpansionPanel`, `ExpansionTile`,
`Button`, `TextField`, `Scaffold`, `Column`, `Row`, `Dialog`, `Dropdown`, `Switch`, and
`ListView`.

### 2. Theme and styling barrel

Import theme providers, theme configuration, styling models, text styles, and
theme-related extensions:

```dart
import 'package:naki_ui/theme.dart';
```

This barrel includes `NakiThemeProvider`, `ThemeConfig`, `EdgeInsets`, `Filter`,
`Gradient` and related styling utilities.

### 3. Framework and utilities barrel

Import low-level framework tools, gesture recognizers, overlay controllers,
animation curves, and extensions:

```dart
import 'package:naki_ui/framework.dart';
```

This barrel includes `PlatformData`, `GestureRecognizer`, `OverlayController`, `DropdownItem`,
`Curves`, `NakiDebounce`, `NakiStatelessMixin`, `NakiStatefulMixin`, and more.

---

## Core component categories

Naki UI provides 80+ components grouped into intuitive categories:

<details open>
<summary><b>📐 Layout and structure</b></summary>

<br>

Build responsive web application layouts:

- `NakiApp`, `Scaffold`, `AppBar`, `Drawer`, `BottomNavigationBar`
- `ResponsiveBuilder`, `BreakPointWrapper`, `MediaQueryProvider`, `Align`, `Expanded`, `Flexible`, `SizedBox`
- `ExpansionPanelList`, `ExpansionPanelList.radio`, `ExpansionTile`
- `Card`, `Card.outlined`, `Card.filled`
- `Column`, `Row`, `Container`
- `Stack`, `Positioned`, `Wrap`, `Padding`, `Margin`, `AspectRatio`, `SafeArea`
- `ColoredBox`, `RotatedBox`

> **Built-in spacing for rows and columns:** `Column` and `Row` support a
> `spacing` parameter (`double`) that applies a uniform CSS gap between children.
> Prefer `Column(spacing: 16, children: [...])` or
> `Row(spacing: 12, children: [...])` instead of inserting `SizedBox` components
> between equally spaced items.

</details>

<details>
<summary><b>🔤 Basics and typography</b></summary>

<br>

Core text formatting, display, and interactive components:

- `NakiText`, `RichText`, `TextSpan`, `ComponentSpan`, `Heading`, `SubHeading`
- `Bold`, `Italic`, `Underline`, `Strikethrough`
- `Icon`, `Image`, `Button`, `GestureDetector`, `Spinner`

</details>

<details>
<summary><b>📝 Inputs and selection controls</b></summary>

<br>

Type-safe form components and selection controls:

- `TextField`, `SegmentedInput`, `FormBuilder`, `AutoCompleteField`, `Label`, `Calendar`
- `Checkbox`, `RadioButton`, `Switch`, `Slider`, `Dropdown`, `DropdownItem`

</details>

<details>
<summary><b>💬 Overlays and feedback</b></summary>

<br>

Interactive modals, alerts, and tooltips:

- `Dialog`, `BottomSheet`, `Banner`, `Snackbar`, `Tooltip`, `Popover`, `OverlayController`

</details>

<details>
<summary><b>📜 Scrolling and data views</b></summary>

<br>

Performance-optimized scrollable containers and data presentation:

- `ListView`, `GridView`, `SingleChildScrollView`, `PageView`
- `CarouselView`, `StaggeredView`, `Table`

`ListView.builder` and `GridView.builder` support deterministic,
incremental rendering for large collections:

```dart
ListView.builder(
  itemCount: 1000,
  initialItemCount: 24,
  loadMoreItemCount: 24,
  itemBuilder: (context, index) => NakiText('Item $index'),
)
```

Set `initialItemCount` to enable lazy batches. Leaving it `null` preserves eager
rendering for backward compatibility. Lazy builders need a bounded, scrollable
viewport. Rendered items remain mounted, so this reduces initial HTML and build
work but does not provide DOM-recycling virtualization. Paginate or use a
dedicated recycler when the fully loaded collection would still be too large for
the browser.

</details>

<details>
<summary><b>⚡ Asynchronous builders and progress</b></summary>

<br>

Handle dynamic data loading and loading state feedback:

- `NakiFutureBuilder`, `NakiStreamBuilder`, `Spinner`

</details>

<details>
<summary><b>🎨 Painting and styling</b></summary>

<br>

Visual transformations and clipping utilities:

- `DecoratedBox`, `Opacity`, `Visibility`, `Transform`
- `ClipRect`, `ClipOval`, `BackdropFilter`

</details>

### Server and static rendering

The package uses `universal_web` for browser APIs shared by client and server
code. In Jaspr `server` or `static` applications, place the uppermost interactive
subtree inside an `@client` component so controls, overlays, controllers, and
asynchronous builders are hydrated. Constructor parameters that cross the client
boundary must remain serializable. Purely visual components can render on the
server without a client boundary.

Automatic DOM IDs are allocated by the nearest `NakiThemeProvider`. Root and
localized providers share a request-scoped, weakly owned registry, keeping IDs
unique without retaining completed render contexts. Identical server and client
trees therefore receive the same generated ID sequence during hydration. Supply
an explicit `id` whenever another document fragment, label, or test needs a
stable public identifier. Components use `GlobalNodeKey` internally for direct
node access so generated IDs are not treated as imperative lookup handles.

---

## Theming and mode switching

`NakiApp` initializes theme configuration and design-token injection at the
application root. Use the `BuildContext` extensions to switch modes, or use
`NakiThemeProvider` to apply a localized theme override to a descendant subtree.

```dart
import 'package:jaspr/jaspr.dart';
import 'package:naki_ui/framework.dart';
import 'package:naki_ui/naki_ui.dart';
import 'package:naki_ui/theme.dart';

// 1. Theme switching with BuildContext extensions.
class ThemeToggleButton extends StatelessComponent {
  const ThemeToggleButton({super.key});

  @override
  Component build(BuildContext context) {
    final currentMode = context.themeMode;

    return Button(
      onTap: context.toggleTheme,
      child: NakiText('Toggle Theme (Current: ${currentMode.name})'),
    );
  }
}

// 2. Localized subtree override with NakiThemeProvider.
class DarkPreviewCard extends StatelessComponent {
  const DarkPreviewCard({super.key});

  @override
  Component build(BuildContext context) {
    return NakiThemeProvider(
      mode: ThemeMode.dark,
      builder: (context) => Card(
        child: NakiText(
          'Forced dark theme subtree',
          style: TextStyle(color: context.textColor),
        ),
      ),
    );
  }
}
```

> **`BuildContext` extensions for theme and token access:**
>
> - `context.toggleTheme()`: Cycles through dark, light, and system modes.
> - `context.setTheme(mode)`: Sets a specific `ThemeMode`.
> - `context.themeMode`: Returns the active `ThemeMode`.
> - `context.themeTokens`: Returns the active, context-local design tokens.
>   `Tokens.current` is only the default source of CSS variable names and
>   fallback values.
> - `context.textColor`, `context.backgroundColor`, `context.surfaceColor`,
>   `context.green`, and `context.red`: Provide type-safe `Color` shortcuts for
>   theme tokens directly on `BuildContext`.

---

## Gesture handling and interaction

Bind clicks, double-clicks, long presses, and pointer events to Jaspr components:

```dart
import 'package:jaspr/jaspr.dart';
import 'package:naki_ui/framework.dart';
import 'package:naki_ui/naki_ui.dart';

class InteractiveCard extends StatelessComponent {
  const InteractiveCard({super.key});

  @override
  Component build(BuildContext context) {
    final gestures = GestureRecognizer(
      onClick: (e) => print('Card clicked'),
      onDoubleClick: (e) => print('Card double clicked'),
      onLongPress: (e) => print('Card long pressed'),
    );

    return GestureDetector(
      gestures: gestures,
      semanticLabel: 'Open interaction details',
      child: const Container(
        child: NakiText('Interact with me'),
      ),
    );
  }
}
```

---

## Segmented input and OTP entry

Handle PINs, verification codes, and one-time passwords with autofocus,
backspace navigation, paste handling, and completion callbacks:

```dart
import 'package:jaspr/jaspr.dart';
import 'package:naki_ui/framework.dart';
import 'package:naki_ui/naki_ui.dart';
import 'package:naki_ui/theme.dart';

class OtpVerificationForm extends StatelessComponent {
  const OtpVerificationForm({super.key});

  @override
  Component build(BuildContext context) {
    return SegmentedInput(
      id: 'otp-verification',
      length: 6,
      type: SegmentedInputType.number,
      decoration: const InputDecoration(
        labelText: 'Enter verification code',
        helperText: 'A six-digit code has been sent to your phone',
      ),
      onChanged: (code) => print('Typing code: $code'),
      onCompleted: (code) => print('Completed OTP code: $code'),
    );
  }
}
```

---

## Responsive layouts and platform detection

Naki UI provides declarative, zero-runtime CSS responsive builders and cross-platform detection utilities.

### 1. Declarative CSS breakpoints with `ResponsiveBuilder`

`ResponsiveBuilder` renders different component hierarchies for discrete screen sizes using pure CSS media queries, ensuring zero layout shift and static SSR compatibility without requiring `@client` hydration:

```dart
import 'package:jaspr/jaspr.dart';
import 'package:naki_ui/naki_ui.dart';

class AdaptiveNavigation extends StatelessComponent {
  const AdaptiveNavigation({super.key});

  @override
  Component build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: const BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: LucideIcons.icon_house, label: 'Home'),
          BottomNavigationBarItem(icon: LucideIcons.icon_search, label: 'Search'),
        ],
      ),
      tablet: const NavigationRail(
        items: [
          NavigationRailItem(icon: LucideIcons.icon_house, label: 'Home'),
          NavigationRailItem(icon: LucideIcons.icon_search, label: 'Search'),
        ],
      ),
      desktop: const HeaderNavigationBar(
        titleText: 'Admin Dashboard',
        actions: [
          Button.text('Overview'),
          Button.text('Reports'),
          Button.text('Settings'),
        ],
      ),
    );
  }
}
```

You can also target a single breakpoint tier:

```dart
ResponsiveBuilder(
  breakpoint: BreakPoint.mobile,
  child: const Banner(
    severity: BannerType.info,
    primary: NakiText('Download our mobile app for a faster experience.'),
  ),
)
```

### 2. Custom pixel ranges with `BreakPointWrapper`

When layouts require arbitrary pixel boundaries, use `BreakPointWrapper` to inject scoped CSS media queries into the document `<head>`:

```dart
BreakPointWrapper(
  minWidth: 640,
  maxWidth: 1024,
  child: const Card(
    child: NakiText('Visible only on viewports between 640px and 1024px wide.'),
  ),
)
```

### 3. Platform and device detection with `PlatformData`

`PlatformData` provides SSR-safe, unified access to OS type, browser environment, mobile/desktop form factor, language, and current URL path:

```dart
import 'package:jaspr/jaspr.dart';
import 'package:naki_ui/framework.dart';
import 'package:naki_ui/naki_ui.dart';

class DeviceGreeting extends StatelessComponent {
  const DeviceGreeting({super.key});

  @override
  Component build(BuildContext context) {
    final platform = PlatformData();

    if (platform.isMobile) {
      return NakiText('Mobile Browser (${platform.isIphone ? "iPhone" : "Android"})');
    }

    if (platform.isDesktop) {
      return NakiText('Desktop App (${platform.isMacOS ? "macOS" : "Windows/Linux"})');
    }

    return NakiText('Language: ${platform.language}');
  }
}
```

### 4. Dynamic observation with `MediaQueryProvider`

For dynamic runtime pixel math or measuring a specific DOM component with a browser `ResizeObserver`, wrap the subtree in `MediaQueryProvider`:

```dart
import 'package:jaspr/jaspr.dart';
import 'package:naki_ui/naki_ui.dart';
import 'package:naki_ui/theme.dart';

@client
class ObservedCard extends StatelessComponent {
  const ObservedCard({super.key});

  @override
  Component build(BuildContext context) {
    return MediaQueryProvider(
      id: 'observed-card',
      builder: (context) {
        final width = MediaQueryProvider.widthOf(context);
        final height = MediaQueryProvider.heightOf(context);
        final orientation = MediaQueryProvider.orientationOf(context);

        String pixels(double? value) =>
            value == null ? 'Measuring…' : value.toPx;

        return Card(
          child: Column(
            spacing: 4,
            children: [
              NakiText('Width: ${pixels(width)}'),
              NakiText('Height: ${pixels(height)}'),
              NakiText('Orientation: ${orientation?.name ?? 'unknown'}'),
            ],
          ),
        );
      },
    );
  }
}
```

> **`MediaQueryProvider` static helpers:**
>
> - `MediaQueryProvider.of(context)`: Returns the active `MediaQueryData`.
> - `MediaQueryProvider.width(context)`: Returns the viewport width in pixels.
> - `MediaQueryProvider.height(context)`: Returns the viewport height in pixels.
> - `MediaQueryProvider.orientation(context)`: Returns the active `Orientation`.
> - `MediaQueryProvider.widthOf(context)`, `MediaQueryProvider.heightOf(context)`,
>   and `MediaQueryProvider.orientationOf(context)`: Return the dimensions and
>   orientation of the observed component identified by `id`.

---

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for
details.
