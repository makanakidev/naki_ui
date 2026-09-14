# Theme configuration recipes

## Configure `NakiApp`

Use the application component when it already owns global setup:

```dart
NakiApp(
  title: 'Storefront',
  themeMode: ThemeMode.system,
  cacheThemeMode: true,
  lightTheme: const LightThemeData(
    colorSeed: ColorSeed(
      primary: Color('#0f766e'),
      backgroundColor: Color('#ffffff'),
      baseTextColor: Color('#17211f'),
    ),
    typography: TypographyScheme(
      fontFamily: ['Inter', 'sans-serif'],
    ),
  ),
  darkTheme: const DarkThemeData(
    colorSeed: ColorSeed(
      primary: Color('#2dd4bf'),
      backgroundColor: Color('#071a18'),
      baseTextColor: Color('#ecfdf5'),
    ),
  ),
  home: const HomePage(),
)
```

Supply both modes when changing brand colors so system-mode users receive a coherent design in either preference.

## Configure a root without `NakiApp`

```dart
NakiThemeProvider.fromConfig(
  configuration: const ThemeConfig(
    initialMode: ThemeMode.system,
    cacheThemeMode: true,
    lightThemeData: LightThemeData(),
    darkThemeData: DarkThemeData(),
  ),
  builder: (context) => const ApplicationShell(),
)
```

There must be only one configured theme root. Do not wrap `NakiApp` in another `NakiThemeProvider.fromConfig`.

## Select a mode for a local subtree

Use the unconfigured constructor for previews or deliberately isolated regions:

```dart
NakiThemeProvider(
  mode: ThemeMode.dark,
  builder: (context) => const CheckoutPreview(),
)
```

This selects the dark data established by the configured root; it does not define a second set of global schemes.

## Consume active theme values

Resolve values during `build`, not in a constructor or global variable:

```dart
@override
Component build(BuildContext context) {
  final tokens = context.themeTokens;

  return Container(
    decoration: BoxDecoration(
      backgroundColor: tokens.surfaceVariantColor.color,
      border: BorderData(color: context.borderColor),
    ),
    child: NakiText(
      'Account',
      style: TextStyle(color: context.textColor),
    ),
  );
}
```

Use a semantic context shortcut when one exists. Use `themeTokens` for dimensions or less common tokens.

## Change the active mode

```dart
Row(
  spacing: 8,
  children: [
    Button.text('Use light', onTap: () => context.setTheme(ThemeMode.light)),
    Button.text('Use dark', onTap: () => context.setTheme(ThemeMode.dark)),
    Button.text('Use system', onTap: () => context.setTheme(ThemeMode.system)),
    Button.outlined('Cycle theme', onTap: context.toggleTheme),
  ],
)
```

Mode changes silently do nothing without a provider ancestor. Cached restoration and system-preference observation depend on browser APIs, so keep controls inside client-capable application code.

## Add a custom CSS property

The `styles` map injects values for its mode:

```dart
const LightThemeData(
  styles: {
    '--app-brand-gradient': 'linear-gradient(135deg, #0f766e, #14b8a6)',
  },
)
```

Use valid CSS custom-property names. Prefer a typed seed when Naki already exposes the concept.
