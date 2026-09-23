# Platform Data and Environment Queries

## PlatformData Overview

`PlatformData` provides a unified, SSR-safe API to query browser environment, operating system, device form factor, screen dimensions, and URL metadata across both client and server environments.

```dart
import 'package:naki_ui/framework.dart';

// Uses ambient browser window/location on web, or default server values on SSR
final platform = PlatformData();
```

`PlatformData` automatically resolves to the client-side implementation on web browsers and the server-side implementation during SSR/SSG pre-rendering or testing.

### Constructor Parameters

The constructor accepts optional override parameters, which is particularly useful for server-side rendering, testing, or custom URL resolution:

```dart
final customPlatform = PlatformData(
  baseUrl: 'https://example.com',
  currentUrl: '/settings',
  userAgent: 'Mozilla/5.0...',
  width: 1440,
  height: 900,
  language: 'en',
);
```

| Parameter    | Type      | Default (Client)         | Default (Server)               | Description                         |
| ------------ | --------- | ------------------------ | ------------------------------ | ----------------------------------- |
| `baseUrl`    | `String?` | `window.location.origin` | `'/'`                          | Base URL origin of the application  |
| `currentUrl` | `String?` | Path without `baseUrl`   | `'/'`                          | Current URL path with leading slash |
| `userAgent`  | `String?` | `navigator.userAgent`    | `''`                           | User agent header string            |
| `width`      | `int?`    | `window.innerWidth`      | `0`                            | Viewport width in pixels            |
| `height`     | `int?`    | `window.innerHeight`     | `0`                            | Viewport height in pixels           |
| `language`   | `String?` | `navigator.language`     | `Platform.localeName` / `'en'` | Preferred locale or language code   |

## Properties and Capabilities

### Operating System and Device

```dart
// Operating system checks
final isApple = platform.isiOS || platform.isMacOS;
final isWindows = platform.isWindows;
final isAndroid = platform.isAndroid;
final isMac = platform.isMacOS;
final isIos = platform.isiOS;
final isIphone = platform.isIphone;
final isIpad = platform.isiPad;

// Form factor classification
final isMobile = platform.isMobile;
final isTablet = platform.isTablet;
final isDesktop = platform.isDesktop;

// Human-readable device string ('iPhone', 'iPad', 'MacOS', 'Windows', 'Android', 'Linux', 'PC', 'Server')
final deviceName = platform.device;

// Underlying platform / OS name
final platformName = platform.name;
```

### Application and Browser Environment

```dart
// PWA (standalone display mode) vs mobile browser
final isPWA = platform.isPWA;
final isMobileBrowser = platform.isMobileBrowser; // true when mobile and not running as PWA

// User agent string
final userAgent = platform.userAgent;
```

### Viewport and Localization

```dart
// Viewport dimensions (pixels)
final screenWidth = platform.width;
final screenHeight = platform.height;

// Language code (e.g. 'en')
final currentLanguage = platform.language;
```

### URLs and Origins

```dart
// Base origin (e.g. 'https://example.com' on web, or '/' on server)
final baseUrl = platform.baseUrl;

// Current path relative to baseUrl (always starts with leading '/')
final currentPath = platform.currentUrl;
```

### Serialization

```dart
// Map of all platform properties
final jsonMap = platform.toJson();

// JSON-encoded string representation
final jsonString = platform.toString();
```

## Common Usage Patterns

### 1. Platform-adaptive Keyboard Shortcuts and UI

```dart
import 'package:jaspr/jaspr.dart';
import 'package:naki_ui/framework.dart';
import 'package:naki_ui/naki_ui.dart';

class SearchShortcutHint extends StatelessComponent {
  const SearchShortcutHint({super.key});

  @override
  Component build(BuildContext context) {
    final platform = PlatformData();

    if (platform.isMobile) {
      return const NakiText('Tap search icon');
    }

    final modifierKey = platform.isMacOS ? '⌘' : 'Ctrl';
    return NakiText('Press $modifierKey+K to search');
  }
}
```

### 2. Conditional PWA Install Prompt

```dart
class PwaPromotionBanner extends StatelessComponent {
  const PwaPromotionBanner({super.key});

  @override
  Component build(BuildContext context) {
    final platform = PlatformData();

    // Show promotional banner only for mobile users not yet using the standalone PWA
    if (platform.isMobileBrowser) {
      return const Banner(
        severity: BannerType.info,
        primary: NakiText('Install this app on your home screen for quick offline access.'),
      );
    }

    return .empty();
  }
}
```

### 3. Device Type Adaptations

```dart
class DeviceTypeLayout extends StatelessComponent {
  const DeviceTypeLayout({
    required this.iosView,
    required this.androidView,
    required this.windowsView,
    super.key,
  });

  final Component iosView;
  final Component androidView;
  final Component windowsView;

  @override
  Component build(BuildContext context) {
    final platform = PlatformData();

    if (platform.isiOS) {
      return iosView;
    }

    if (platform.isAndroid) {
      return androidView;
    }

    return windowsView;
  }
}
```

## Best Practices

- Use `PlatformData` instead of raw `window` or `document` checks so components can render safely on the server without throwing `NoSuchMethodError` or unsupported errors.
- Combine `PlatformData.isMobileBrowser` with banners or dialogs for PWA installation prompts.
- Do not import `package:naki_ui/src/stub/...` directly; always import `package:naki_ui/framework.dart`.
