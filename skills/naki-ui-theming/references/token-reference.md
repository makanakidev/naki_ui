# Theme seed and token reference

## Choose the narrowest seed

| Intent | Seed | Examples |
| --- | --- | --- |
| Brand and semantic palette | `ColorSeed` | primary, background, text, surfaces, focus, error, success, warning, info |
| Type scale | `TypographyScheme` | font family, size scale, label and validation sizes, weights |
| Global spacing scale | `SpacingScheme` | small, medium, and large padding and margin |
| Borders | `BorderScheme` | color and normal, hover, focus, error widths |
| Shadows | `ElevationScheme` | default, small, medium, and large shadow colors |
| Shape | `RadiusScheme` | small, medium, large, and general shape radii |
| Individual component defaults | `ComponentScheme` | inputs, buttons, overlays, navigation, tables, scrolling |

Each seed supports `copyWith` for deriving a closely related configuration. Prefer constructing immutable data once instead of rebuilding large theme objects inside component `build` methods.

## Build a coordinated theme

```dart
const brandLight = LightThemeData(
  colorSeed: ColorSeed(
    primary: Color('#1d4ed8'),
    backgroundColor: Color('#f8fafc'),
    baseTextColor: Color('#0f172a'),
    surfaceVariantColor: Color('#ffffff'),
    focusBorderColor: Color('#2563eb'),
    errorColor: Color('#b91c1c'),
  ),
  typography: TypographyScheme(
    fontFamily: ['Inter', 'system-ui', 'sans-serif'],
    fontSizeMd: Dim.rem(1),
    fontWeightSemiBold: 600,
  ),
  spacing: SpacingScheme(
    paddingMd: Dim.rem(1),
    marginMd: Dim.rem(1),
  ),
  borderWidth: BorderScheme(
    borderColor: Color('#cbd5e1'),
    focusBorderWidth: Dim.px(2),
  ),
  radius: RadiusScheme(
    radiusMd: Dim.rem(0.625),
  ),
  component: ComponentScheme(
    buttonHeight: Dim.rem(2.75),
    inputHeight: Dim.rem(2.75),
    snackbarBorderRadius: Dim.rem(0.625),
  ),
);
```

Mirror the semantic intent in `DarkThemeData`; do not mechanically reuse light surface, border, and text colors.

## Component scheme groups

`ComponentScheme` covers these related groups:

- Text and inputs: maximum lines, input height, input text, label, input font, field background and hover.
- Buttons and dropdowns: colors, sizes, menu surface, option size and padding.
- Feedback and progress: spinner, slider, switch, and radio values.
- Navigation and scrolling: app bar, bottom navigation, carousel, grid gap, and scrollbar values.
- Data display: table header surface, hover surface, and borders.
- Overlays and notices: snackbar, banner, tooltip, popover, dialog, drawer, and bottom-sheet colors, radii, and dimensions.

Use component seeds for systematic defaults. Use component constructor properties for a meaningful one-off exception.

## Semantic token consumption

Prefer context shortcuts for frequently used colors:

```dart
final brand = context.primaryColor;
final foreground = context.textColor;
final surface = context.surfaceColor;
final border = context.borderColor;
final danger = context.errorColor;
final success = context.successColor;
```

For other values, infer the active token object:

```dart
final tokens = context.themeTokens;
final controlHeight = tokens.inputHeight;
final tooltipSurface = tokens.tooltipBgColor.color!;
```

## Review checklist

- Primary content and controls meet contrast requirements in both modes.
- Error, warning, success, selected, disabled, hover, and focus states remain distinct without relying on color alone.
- Focus indicators remain visible on every surface.
- Overlay foregrounds, surfaces, borders, and barriers work together.
- System mode follows preference changes and does not flash an unrelated theme during hydration.
- Custom CSS variables have valid names and mode-specific values where necessary.
