# Public theme API

## Entrypoints

Use only public package imports:

```dart
import 'package:naki_ui/naki_ui.dart';
import 'package:naki_ui/theme.dart';
```

`package:naki_ui/theme.dart` exports the theme provider and configuration, styling models, text styles, and context extensions. Component APIs and theme enums such as `ThemeMode` remain available through `package:naki_ui/naki_ui.dart`.

## Providers and configuration

- `NakiThemeProvider`: selects or inherits a mode for a subtree.
- `NakiThemeProvider.fromConfig`: creates one configured application theme root.
- `InheritedTheme`: propagated theme state; normally consume it through context extensions.
- `ThemeConfig`: immutable root configuration with `initialMode`, `cacheThemeMode`, `lightThemeData`, and `darkThemeData`.
- `LightThemeData`, `DarkThemeData`: mode-specific seed sets plus custom CSS variables.

`NakiApp` accepts the equivalent root properties `themeMode`, `cacheThemeMode`, `lightTheme`, and `darkTheme`.

## Seed schemes

- `ColorSeed`: brand, semantic, text, surface, focus, hover, disabled, and status colors.
- `TypographyScheme`: font stack, font scale, and weights.
- `SpacingScheme`: global padding and margin sizes.
- `BorderScheme`: border color and normal, hover, focus, and error widths.
- `ElevationScheme`: default and sized shadow colors.
- `RadiusScheme`: small, medium, large, and shape radii.
- `ComponentScheme`: component-specific token overrides.

All schemes are selective. Omitted fields retain the mode's Naki defaults.

## Styling value objects

- Dimensions and geometry: `Dim`, `EdgeInsets`, `BorderRadiusData`, `SizeConstraints`, `PositionData`.
- Decoration: `BorderData`, `BorderSideData`, `BoxDecoration`, `Shadow`, `Filter`, `Gradient`.
- Forms and states: `InputDecoration`, `ComponentStatesColor`, `SegmentedInputStyle`.
- Typography: `TextStyle`, `DefaultTextStyle`.

## Context access

Inside `build`, the `BuildContext` extension provides:

- `themeMode` and `themeTokens`;
- `toggleTheme()` and `setTheme(mode)`;
- semantic color shortcuts for brand, text, surfaces, borders, statuses, controls, overlays, navigation, tables, and scrollbars;
- `withOpacity(color, opacity)`.

Context lookup records the inherited dependency and rebuilds the consumer when the nearest theme changes.

## Token boundary

The concrete token object is returned by `context.themeTokens`, but it is not necessary to name its type or import internal token files:

```dart
final tokens = context.themeTokens;
final primary = tokens.primaryColor.color!;
```

Never add a `package:naki_ui/src/...` import to reach token internals. `Tokens.current` is only the fallback used when no provider exists, not mutable active application state.
