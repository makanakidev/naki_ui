# Application and responsive components

Assume the public imports from `references/imports-and-conventions.md`. Add `package:jaspr_router/jaspr_router.dart` for routing.

## NakiApp

Use `NakiApp` once at the application root. It configures document metadata, theme state, default text styling, safe-area behavior, and the home component.

```dart
@client
class App extends StatelessComponent {
  const App({super.key});

  @override
  Component build(BuildContext context) {
    return NakiApp(
      title: 'Acme Portal',
      locale: 'en',
      themeMode: ThemeMode.system,
      cacheThemeMode: true,
      lightTheme: const LightThemeData(),
      darkTheme: const DarkThemeData(),
      seo: const SEO(
        title: 'Acme Portal',
        description: 'Manage your Acme account.',
      ),
      home: const Scaffold(
        appBar: AppBar(titleText: 'Acme'),
        body: NakiText('Dashboard'),
      ),
    );
  }
}
```

Provide either `home` or `pageBuilder`:
- **`home`**: Use when the root component is self-contained or `const` (e.g. `home: const Scaffold(...)`), and does not need immediate access to `BuildContext` provided by `NakiApp`'s inner `NakiThemeProvider` during instantiation.
- **`pageBuilder`**: Use `pageBuilder: (context, child)` when the root view itself needs direct access to `context` (such as reading `context.themeTokens`, toggling themes via `context.toggleTheme` in the top app bar, or wrapping the visual tree in application-specific providers).

Put `NakiApp` below an `@client` boundary when using browser APIs, theme persistence, or client-side navigation.

## NakiApp.router

Use the named constructor for router-managed pages.

```dart
NakiApp.router(
  title: 'Acme Portal',
  basePath: '/',
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
  errorPage: const PageNotFound(),
)
```

The `basePath` must start with `/`. Include the router returned to `builder` when supplying a custom router wrapper. Client-side SPA navigation requires a hydrated boundary; server-driven multipage routing can render without client navigation.

## PageNotFound

Use the default fallback directly or customize its text.

```dart
const PageNotFound(
  errorTitle: 'Page unavailable',
  errorText: 'Check the address or return to the dashboard.',
)
```

Pass it to `NakiApp.router.errorPage` when the standard route fallback needs product-specific copy.

## MediaQueryProvider

Use this client-side provider to expose viewport width, height, and orientation to descendants.

```dart
MediaQueryProvider(
  builder: (context) {
    final width = MediaQueryProvider.width(context) ?? 0;
    final orientation =
        MediaQueryProvider.orientation(context) ?? Orientation.unknown;

    return NakiText('$width px — ${orientation.name}');
  },
)
```

Initial values can be unavailable before the browser observer reports a size. Handle `null` or use `MediaQueryProvider.of(context)` for the complete `MediaQueryData` object.

To observe a component rather than the viewport, provide a unique `id`. The provider wraps and measures the component returned by the builder:

```dart
MediaQueryProvider(
  id: 'account-panel-observer',
  builder: (context) {
    final width = MediaQueryProvider.widthOf(context) ?? 0;

    return Container(
      blockBox: true,
      child: NakiText('Panel width: $width px'),
    );
  },
)
```

Do not set a conflicting ID on the returned component. Use `widthOf`, `heightOf`, and `orientationOf` only for a provider configured with `id`.

## MediaQueryData

`MediaQueryData` is the inherited component installed by `MediaQueryProvider`. Normally read it instead of constructing it:

```dart
final media = MediaQueryProvider.of(context);
final width = media?.width?.value;
final height = media?.height?.value;
final orientation = media?.orientation ?? Orientation.unknown;
```

Construct `MediaQueryData` directly only when implementing a compatible custom provider and preserving its `isComponent` meaning.
