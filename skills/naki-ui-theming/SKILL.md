---
name: naki-ui-theming
description: Configure, extend, review, and troubleshoot Naki UI themes, design tokens, text styles, dimensions, decorations, and component schemes. Use for package:naki_ui/theme.dart, NakiThemeProvider, ThemeConfig, LightThemeData, DarkThemeData, ColorSeed, theme switching, context.themeTokens, or Naki styling models.
metadata:
  version: "1.0.1"
  author: "makanakidev"
---

# Naki UI theming

Build request-safe, context-aware themes that work in light, dark, and system modes.

## Import public APIs

```dart
import 'package:naki_ui/naki_ui.dart';
import 'package:naki_ui/theme.dart';
```

`naki_ui.dart` supplies components and framework enums. `theme.dart` supplies providers, theme configuration, styling models, text styles, and context extensions. Never import from `package:naki_ui/src/...`.

## Follow this workflow

1. Decide whether the change belongs to root theme configuration, a local themed subtree, reusable CSS, or one runtime-derived style.
2. Configure the root through `NakiApp` or one `NakiThemeProvider.fromConfig`.
3. Build immutable `LightThemeData` and `DarkThemeData` values from the smallest relevant seed schemes.
4. Read active values from `context.themeTokens` or semantic context color shortcuts inside `build`.
5. Use plain `NakiThemeProvider` only for a deliberate local mode override.
6. Keep interactive theme controls in client-capable code because cache and system-theme behavior require browser APIs.
7. Check contrast, focus visibility, light/dark parity, system mode, and server/client consistency.

## Preserve theme correctness

- Treat the nearest `NakiThemeProvider` as the source of active theme state.
- Do not use `Tokens.current` as application state. It is a compatibility fallback; prefer `context.themeTokens`.
- Do not introduce mutable global theme configuration. Construct `ThemeConfig` per application or request.
- Do not nest configured providers. Use `NakiApp` for root configuration or one explicit `NakiThemeProvider.fromConfig`.
- Prefer semantic tokens—text, surface, border, success, warning, error—over hard-coded colors.
- Prefer `ColorSeed`, typography, spacing, border, elevation, radius, and component schemes over raw custom properties.
- Use typed values such as `Dim`, `EdgeInsets`, `BorderData`, `BorderRadiusData`, `BoxDecoration`, and `TextStyle` where an API supports them.
- Put stable reusable styles in CSS rules; reserve component `styles` or inline styling for values that truly vary at runtime.

## Route to the right reference

- Read [theme-api.md](references/theme-api.md) for the exported type map and import boundaries.
- Read [configuration.md](references/configuration.md) for root themes, local overrides, token access, and mode controls.
- Read [styling-models.md](references/styling-models.md) for typed dimensions, decorations, inputs, and text styles.
- Read [token-reference.md](references/token-reference.md) for seed selection and component-token guidance.

## Verify proportionately

Format and analyze changed Dart code. Test light, dark, and system modes, nested provider lookup, cached mode restoration, and any changed CSS output. Review text and non-text contrast, focus states, disabled and error states, overlay barriers, reduced-motion behavior, and forced-colors behavior for custom CSS.
